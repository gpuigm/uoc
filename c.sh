#!/bin/bash

#Nom i cognom de l'alumne: Gabriel Puig Martín
#Usuari de la UOC de l'alumne: gpuigm
#Data: 23/12/2023


# Inicialitzem les variables per als totals
total_students=0
total_semesters=0
total_subjects=0

# Comprovem que els dos primers paràmetres estan definits
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: mandatory parameter not found"
    exit 1
fi

# Comprovem que els dos primers paràmetres són fitxers existents
if [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "Error: mandatory parameter is not a valid file"
    exit 1
fi

# Definim les edats per defecte si no s'han especificat
if [ -z "$3" ] && [ -z "$4" ]; then
    ages=("18-29" "30-39" "40-49" "50-99")
else
    # Si els paràmetres 3 i 4 estan definits, comprovem que són nombres naturals
    if ! [[ "$3" =~ ^[0-9]+$ ]] || ! [[ "$4" =~ ^[0-9]+$ ]]; then
        echo "Error: invalid data type when defining age range"
        exit 1
    fi

    # Si només hi ha tres paràmetres o el valor del tercer paràmetre és major que el del quart, mostrem un error
    if [ -z "$4" ] || [ "$3" -gt "$4" ]; then
        echo "Error: invalid age range"
        exit 1
    fi

    ages=("$3-$4")
fi

# Obtenim l'any actual
CURRENT_YEAR=$(date +%Y)

# Realitzem un join entre els fitxers en base al camp "id"
joined_data=$(join -t ';' -1 1 -2 1 <(sort -t ';' -k1,1 "$2") <(sort -t ';' -k1,1 "$1"))

# Per a cada rang d'edat, calculem les estadístiques
for age in "${ages[@]}"; do
    IFS='-' read -ra RANGE <<< "$age"
    LOWER=${RANGE[0]}
    UPPER=${RANGE[1]}

    total_num_students=$(awk -F';' '{students[$1]++} END {print length(students)}' $2)
    filtered_data=$(echo "$joined_data" | awk -F';' -v lower=$LOWER -v upper=$UPPER -v year=$CURRENT_YEAR 'NR > 1 && $5 == "1" && (year-$4 >= lower && year-$4 <= upper)')
    total_filtered_students=$(echo "$filtered_data" | awk -F';' '{values[$1]++} END {print length(values)}') 

    # Si no hi ha graduats per a aquest rang d'edat, mostrem un avís i continuem amb la següent iteració
    if [ "$total_filtered_students" -eq 1 ]; then
        echo "Warning: no records found for $age age range"
        continue
    fi

    # Calculem el percentatge de graduats respecte al total
    PERCENTAGE=$(awk -v total_filtered_students=$total_filtered_students -v total_num_students=$total_num_students 'BEGIN {printf "%.3f", (total_filtered_students / (total_num_students)) * 100}')

    # Calculem les mitjanes
    UNIQUE_SEMESTERS=$(echo "$filtered_data" | awk -F';' '{values[$7]++} END {print length(values)}')

    AVG_SEMESTERS=$(echo "$filtered_data" | awk -F';' -v unique_semesters=$UNIQUE_SEMESTERS '{semesters[$1,$7]++} END {total = 0; for (id_semester in semesters) {total++} printf "%.3f\n", total/unique_semesters}')

    AVG_SUBJECTS=$(echo "$filtered_data" | awk -F';' -v unique_semesters=$UNIQUE_SEMESTERS '{subjects[$1,$7]++} END {total = 0; for (id_semester in subjects) {total += subjects[id_semester]} print total/unique_semesters}')

    # Imprimim els resultats
    if [ "$age" == "50-99" ]; then
        echo "Alumni (N=$total_filtered_students) >=50: $PERCENTAGE%, semester: $AVG_SEMESTERS, subject: $AVG_SUBJECTS"
    else
        echo "Alumni (N=$total_filtered_students) $age: $PERCENTAGE%, semester: $AVG_SEMESTERS, subject: $AVG_SUBJECTS"
    fi

    # Sumem als totals
    total_students=$((total_students + total_filtered_students))
    total_semesters=$(awk -v total_semesters=$total_semesters -v avg_semesters=$AVG_SEMESTERS -v total_filtered_students=$total_filtered_students 'BEGIN {print total_semesters + (avg_semesters * total_filtered_students)}')
    total_subjects=$(awk -v total_subjects=$total_subjects -v avg_subjects=$AVG_SUBJECTS -v total_filtered_students=$total_filtered_students 'BEGIN {print total_subjects + (avg_subjects * total_filtered_students)}')
done

# Després del bucle, calculem les mitjanes totals
if [ $total_students -ne 0 ]; then
    total_avg_semesters=$(awk -v total_semesters=$total_semesters -v total_students=$total_students 'BEGIN {printf "%.3f", total_semesters / total_students}')
    total_avg_subjects=$(awk -v total_subjects=$total_subjects -v total_students=$total_students 'BEGIN {printf "%.3f", total_subjects / total_students}')
# I mostrem els resultats
    echo "Alumni (Total=$total_students) semester: $total_avg_semesters, subject: $total_avg_subjects"
fi

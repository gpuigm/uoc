#!/bin/bash
#Nom i cognom de l'alumne: Gabriel Puig Mart°n
#Usuari de la UOC de l'alumne: gpuigm
#Data: 23/12/2023

# Comprovaci¢ de par?metres
# Si no hi ha almenys dos par?metres, es mostra un missatge d'error i s'acaba l'script
if [[ $# -lt 2 ]]; then
    echo "Error: mandatory parameter not found"
    exit 1
fi

# Si els fitxers proporcionats no existeixen, es mostra un missatge d'error i s'acaba l'script
if [[ ! -f $1 ]] || [[ ! -f $2 ]]; then
    echo "Error: mandatory parameter is not a valid file"
    exit 1
fi

# Assignatura (opcional)
# Aquesta variable contindr? el codi de l'assignatura si s'ha proporcionat
subject=$3

# Processament dels fitxers CSV
# Aquesta part de l'script utilitza awk per processar els fitxers CSV
awk -F";" -v subject="$subject" '
BEGIN {
    total = 0
    fail = 0
    male_fail = 0
    female_fail = 0
    subject_exists = 0
}
FNR==NR {
    if ($3 == "M" || $3 == "F") gender[$1] = $3
    next
}
{
    # Processament del segon fitxer CSV (marks_PS.csv)
    # Si s`ha proporcionat un codi d`assignatura i no coincideix amb l`assignatura actual, es salta a la segÅent l°nia
    if (subject != "" && $3 != subject) next
	# Si s`ha proporcionat un codi d`assignatura i coincideix amb l`assignatura actual, es marca que l`assignatura existeix
    if (subject != "" && $3 == subject) subject_exists = 1
	# Si l`estudiant ha susp?s, s`incrementen les variables corresponents
    if ($4 == "SU" || $4 == "NP") {
        fail++
        if (gender[$1] == "M") male_fail++
        if (gender[$1] == "F") female_fail++
    }
	# S`incrementa el total d`estudiants
    total++
}
END {
	# Si s`ha proporcionat un codi d`assignatura i no existeix, es mostra un missatge d`error i s`acaba l`script
    if (subject != "" && subject_exists == 0) {
        print "Error: subject does not exist"
        exit 1
    }
    printf "Percentage of failures by females for %s: %.2f%%\n", (subject=="" ? "all subjects" : "subject " subject), (female_fail/total)*100
	printf "Percentage of failures by males for %s: %.2f%%\n", (subject=="" ? "all subjects" : "subject " subject), (male_fail/total)*100
    printf "Percentage of failures for %s (Total): %.2f%%\n", (subject=="" ? "all subjects" : "subject " subject), (fail/total)*100
}' $2 $1

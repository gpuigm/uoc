#!/bin/bash
#Nom i cognom de l'alumne: Gabriel Puig Martín
#Usuari de la UOC de l'alumne: gpuigm
#Data: 23/12/2023

# URL de descàrrega: https://raw.githubusercontent.com/gpuigm/uoc/main/dataset_practica_2023_2024_s1.zip
# Obtenim l'URL des de l'entrada.


url=$1

# Primer, comprovem si l'entrada és una URL vàlida.
if [[ $url =~ ^https?:// ]]; then
  # Si és vàlida, descarreguem l'arxiu ZIP amb wget.
  wget --no-check-certificate -O archivo.zip "$(printf '%s' "$url")" > /dev/null 2>&1
else
  cat <<< "Error: L'URL proporcionada no és vàlida."
  exit 1
fi

# Comprovar si s'ha descarregat un arxiu ZIP.
if [ ! -f "./archivo.zip" ]; then
  cat <<< "Error: No s'ha pogut descarregar cap arxiu ZIP de l'URL proporcionada."
  exit 1
fi

# Si tot ha anat bé fins ara, descomprimim l'arxiu ZIP i esborra'l.
unzip -o "./archivo.zip" > /dev/null 2>&1
rm -rf archivo.zip > /dev/null 2>&1



# Ara, per a cada arxiu CSV, farem el següent:
for csv in ./*.csv
do
  # Calculem la firma digital MD5.
  md5=$(md5sum "$csv" | awk '{ print $1 }')

  # Obtenim el nom de l'arxiu sense l'extensió.
  csvname=$(basename "$csv" .csv)

  # Determinem la codificació de caràcters.
  charset=$(file -i "$csv" | sed -n 's/.*charset=\(.*\)/\1/p')

  # Contem el nombre de registres.
  records=$(wc -l < "$csv")

  # Contem el nombre de columnes.
  columns=$(head -1 "$csv" | tr ';' '\n' | wc -l)

  # Imprimim la informació obtinguda.
  cat <<< "MD5: $md5"
  cat <<< "Nom de l'arxiu: $csvname"
  cat <<< "Codificació de caràcters: $charset"
  cat <<< "Nombre total de registres: $records"
  cat <<< "Nombre total de columnes: $columns"

  # Per a cada columna, obtenim el nom i el tipus de dades.

IFS=';' read -r -a array <<< "$(head -1 "$csv")"
  for index in "${!array[@]}"
  do
    column=${array[index]}
    type=$(awk -F';' -v col=$((index+1)) '{print $col}' "$csv" | awk '
    {
      if ($0 + 0 == $0) {
        printf("%s\n", (int($0) == $0) ? "integer" : "float")
      } else {
        printf("string\n")
      }
    }' | sort -u | grep -v string)
    if [[ $type == "" ]]; then
      if grep -Pq '^(\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2})$' <(awk -F';' -v col=$((index+1)) '{print $col}' "$csv"); then
        type="data"
      elif grep -Pq '^(true|false)$' <(awk -F';' -v col=$((index+1)) '{print $col}' "$csv"); then
        type="boolean"
      else
        type="string"
      fi
    fi
    cat <<< "Tipus Columna$((index+1)): $column, $type"
  done



  # Finalment, imprimim un separador abans de passar al següent arxiu CSV.
  cat <<< "                    "
  cat <<< "********************"
  cat <<< "                    "
done

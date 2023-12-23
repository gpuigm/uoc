#!/bin/bash

url=$1

if [[ $url =~ ^https?:// ]]; then
  wget --no-check-certificate -O archivo.zip "$(printf '%s' "$url")" > /dev/null 2>&1
else
  echo "Error: L'URL proporcionada no és vàlida."
  exit 1
fi

if [ ! -f "./archivo.zip" ]; then
  echo "Error: No s'ha pogut descarregar cap arxiu ZIP de l'URL proporcionada."
  exit 1
fi

unzip -o "./archivo.zip" > /dev/null 2>&1
rm -rf archivo.zip > /dev/null 2>&1

for csv in ./*.csv
do
  md5=$(md5sum "$csv" | cut -d' ' -f1)
  csvname=$(basename "$csv" .csv)
  charset=$(file -i "$csv" | sed -n 's/.*charset=\(.*\)/\1/p')
  records=$(wc -l < "$csv")
  columns=$(head -1 "$csv" | tr ';' '\n' | wc -l)

  echo "MD5: $md5"
  echo "Nom de l'arxiu: $csvname"
  echo "Codificació de caràcters: $charset"
  echo "Nombre total de registres: $records"
  echo "Nombre total de columnes: $columns"

  IFS=';' read -r -a array <<< "$(head -1 "$csv")"
  for index in "${!array[@]}"
  do
    column=${array[index]}
    type=$(cut -d';' -f$((index+1)) "$csv" | grep -P '^\d+$' > /dev/null && echo "integer" || echo "string")
    if [[ $type == "string" ]]; then
      type=$(cut -d';' -f$((index+1)) "$csv" | grep -P '^\d+\.\d+$' > /dev/null && echo "float" || echo "string")
    fi
    if [[ $type == "string" ]]; then
      type=$(cut -d';' -f$((index+1)) "$csv" | grep -P '^(\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2})$' > /dev/null && echo "data" || echo "string")
    fi
    if [[ $type == "string" ]]; then
      type=$(cut -d';' -f$((index+1)) "$csv" | grep -P '^(true|false)$' > /dev/null && echo "boolean" || echo "string")
    fi
    echo "Tipus Columna$((index+1)): $column, $type"
  done

  echo "                    "
  echo "********************"
  echo "                    "
done


#Nom i cognoms de l’alumne: Gabriel Puig Martín
#Usuari de la UOC de l’alumne: gpuigm
#Data: 23/12/2023
#Objectiu: Calcular el percentatge d'assignatures suspeses en cada semestre
#Nom i tipus dels camps d’entrada: id (cadena), semester (cadena), course (cadena), mark (cadena)
#Operacions i núm. de línia o línies del codi font on es realitzen: 6-14
#Descripció detallada de les operacions: 
#   Línies 6-14: Aquest bloc de codi s'executa per cada línia del fitxer d'entrada (a excepció de la primera línia, que és la capçalera). 
#   Si la nota de l'assignatura és "SU" o "NP" (indicant que l'assignatura està suspesa), incrementa el comptador de suspesos per aquest semestre en l'array 'fail'. 
#   Independentment de la nota, incrementa el comptador total d'assignatures per aquest semestre en l'array 'total'.
#Nom i tipus dels nous camps generats: fail (array), total (array)
#Descripció dels nous camps generats: 
#   fail: Un array que emmagatzema el nombre d'assignatures suspeses per semestre.
#   total: Un array que emmagatzema el nombre total d'assignatures per semestre.

BEGIN { FS=";" }
FNR > 1 && FILENAME == ARGV[1] {
    if ($4 == "SU" || $4 == "NP") {
        fail[$2]++
    }
    total[$2]++
}
END {
    print "+------------+------------------------+"
    print "| Semestre   | Percentatge de suspesos |"
    print "+------------+------------------------+"
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (i in total) {
        printf "| %-10s | %.2f%%                  |\n", i, (fail[i] / total[i]) * 100
    }
    print "+------------+------------------------+"
}

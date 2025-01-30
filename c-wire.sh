#!/bin/bash
#######################################################
#  File Name: c-wire.sh
#  Author: Asmaa NASSIRI
#  Version: 1.0
#  Usage: ./c-wire.sh
#######################################################

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "Usage: $0 <fichier_CSV> <type_station> <type_consommateur> [id_centrale]"
    echo "Types de station: hvb | hva | lv"
    echo "Types de consommateur: comp | indiv | all"
    exit 1
fi

# Récupération des arguments
CSV_FILE=$1
STATION_TYPE=$2
CONSUMER_TYPE=$3
CENTRALE_ID=${4:-""} # Optionnel

# Vérification de l'existence du fichier CSV
if [ ! -f "$CSV_FILE" ]; then
    echo "Erreur: Le fichier CSV '$CSV_FILE' n'existe pas."
    exit 2
fi


# Vérification de la validité des arguments
if [[ "$STATION_TYPE" != "hvb" && "$STATION_TYPE" != "hva" && "$STATION_TYPE" != "lv" ]]; then
    echo "Erreur: Type de station invalide. Choisir entre hvb, hva ou lv."
    exit 3
fi
if [[ "$CONSUMER_TYPE" != "comp" && "$CONSUMER_TYPE" != "indiv" && "$CONSUMER_TYPE" != "all" ]]; then
    echo "Erreur: Type de consommateur invalide. Choisir entre comp, indiv ou all."
    exit 4
fi
if [[ "$STATION_TYPE" == "hvb" && "$CONSUMER_TYPE" != "comp" ]] || [[ "$STATION_TYPE" == "hva" && "$CONSUMER_TYPE" != "comp" ]]; then
    echo "Erreur: Les stations HV-B et HV-A ne peuvent pas avoir 'all' ou 'indiv' comme type de consommateur."
    exit 5
fi

# Création des dossiers nécessaires
mkdir -p tmp graphs tests
rm -rf tmp/* # Nettoyage des fichiers temporaires

# Compilation du programme C
cd codeC
if [ ! -f "cwire" ]; then
    echo "Compilation du programme C..."
    make clean && make
    if [ $? -ne 0 ]; then
        echo "Erreur: Compilation échouée."
        exit 6
    fi
fi
cd ..

# Filtrage du fichier CSV
echo "Filtrage des données..."
FILTERED_FILE="tmp/data_filtered.csv"
awk -F';' -v stype="$STATION_TYPE" -v ctype="$CONSUMER_TYPE" -v cid="$CENTRALE_ID" '
BEGIN {OFS=":"; print "ID_Station:Capacité:Consommation"}
$1 == cid || cid == "" {
    if ((stype == "hvb" && $2 != "-") || (stype == "hva" && $3 != "-") || (stype == "lv" && $4 != "-")) {
        id = (stype == "hvb") ? $2 : (stype == "hva") ? $3 : $4;
        cap = $7;
        load = (ctype == "comp") ? $8 : (ctype == "indiv") ? $9 : $8 + $9;
        print id, cap, load;
    }
}' "$CSV_FILE" > "$FILTERED_FILE"

# Exécution du programme C
echo "Exécution du programme C..."
codeC/cwire "$FILTERED_FILE"

# Vérification du résultat
if [ $? -ne 0 ]; then
    echo "Erreur: Le programme C a rencontré un problème."
    exit 7
fi

# If option lv all
if [ "$2" = "lv" ] && [ "$3" = "all" ]; then
    output_file="tmp/lv_all_minmax.csv";
    input_file="tests/output.csv" 

    # Extract and filter the data based on consumption (3rd column)
    # Sort by consumption in descending order, get top 10, then sort in ascending order for the bottom 10
    {
    echo "ID_Station:Capacité:Consommation"

    # Get the top 10 stations with the highest consumption
    tail -n +2 "$input_file" | sort -t ":" -k2,2nr | head -n 10
  
    # Get the top 10 stations with the lowest consumption
    tail -n +2 "$input_file" | sort -t ":" -k2,2n | head -n 10
    } > "$output_file"
    echo "Output written to $output_file"
fi

# Génération de graphiques si LV_ALL
if [[ "$STATION_TYPE" == "lv" && "$CONSUMER_TYPE" == "all" ]]; then
    echo "Génération des graphiques avec GnuPlot..."
    gnuplot scripts/plot_lv_all.gnu
fi


echo "Traitement terminé avec succès !"

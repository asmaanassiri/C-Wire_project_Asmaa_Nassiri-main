## Description
Ce projet traite les données de distribution d'électricité à grande échelle à l'aide d'un script shell et 
d'un programme en C. Le script shell est chargé de filtrer et de préparer les données, tandis que le programme 
en C traite les données filtrées à l'aide d'un arbre AVL pour calculer les statistiques de consommation.
## Project Structure
- **c-wire.sh**: Script shell principal pour filtrer les données et traiter le projet.
- **input/**: Contient le fichier de données brutes (data.csv).
- **codeC/**: Contient les fichiers source du programme en C, les fichiers d'en-tête et le Makefile.
- **tmp/**: Fichiers temporaires générés pendant l'exécution du script.
- **graphs/**: Contient les sorties graphiques générées par GnuPlot.
- **tests/**: Contient les données de test et les résultats pour la validation du projet.
- **docs/**: Contient la documentation relative au projet, y compris le fichier PDF de la spécification.

## How to Run
1. Exécuter `c-wire.sh` avec les arguments nécessaires, par exemple.:  
   ```bash
    ./c-wire.sh input/data.csv hva comp 2     

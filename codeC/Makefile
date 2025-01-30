# Définition du compilateur
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2

# Fichiers sources et binaires
SRC = main.c
OBJ = $(SRC:.c=.o)
EXEC = cwire

# Règle principale
all: $(EXEC)

# Compilation de l'exécutable
$(EXEC): $(OBJ)
	$(CC) $(CFLAGS) -o $(EXEC) $(OBJ)

# Compilation des fichiers objets
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Nettoyage des fichiers compilés
clean:
	rm -f $(OBJ) $(EXEC)

# Nettoyage complet
mrproper: clean
	rm -f tests/output.csv
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 256

// Structure d'un noeud AVL
typedef struct AVLNode {
    int id;
    long capacity;
    long consumption;
    struct AVLNode *left, *right;
    int height;
} AVLNode;

// Fonction pour créer un nouveau noeud AVL
AVLNode* createNode(int id, long capacity, long consumption) {
    AVLNode* node = (AVLNode*)malloc(sizeof(AVLNode));
    node->id = id;
    node->capacity = capacity;
    node->consumption = consumption;
    node->left = node->right = NULL;
    node->height = 1;
    return node;
}

// Fonction pour obtenir la hauteur d'un noeud
int getHeight(AVLNode* node) {
    return node ? node->height : 0;
}

// Fonction pour obtenir le facteur d'équilibre
int getBalance(AVLNode* node) {
    return node ? getHeight(node->left) - getHeight(node->right) : 0;
}

// Rotation droite
AVLNode* rotateRight(AVLNode* y) {
    AVLNode* x = y->left;
    AVLNode* T2 = x->right;
    x->right = y;
    y->left = T2;
    y->height = 1 + ((getHeight(y->left) > getHeight(y->right)) ? getHeight(y->left) : getHeight(y->right));
    x->height = 1 + ((getHeight(x->left) > getHeight(x->right)) ? getHeight(x->left) : getHeight(x->right));
    return x;
}

// Rotation gauche
AVLNode* rotateLeft(AVLNode* x) {
    AVLNode* y = x->right;
    AVLNode* T2 = y->left;
    y->left = x;
    x->right = T2;
    x->height = 1 + ((getHeight(x->left) > getHeight(x->right)) ? getHeight(x->left) : getHeight(x->right));
    y->height = 1 + ((getHeight(y->left) > getHeight(y->right)) ? getHeight(y->left) : getHeight(y->right));
    return y;
}

// Insertion dans l'AVL
AVLNode* insertNode(AVLNode* node, int id, long capacity, long consumption) {
    if (!node) return createNode(id, capacity, consumption);
    
    if (id < node->id)
        node->left = insertNode(node->left, id, capacity, consumption);
    else if (id > node->id)
        node->right = insertNode(node->right, id, capacity, consumption);
    else {
        node->consumption += consumption;  // Mise à jour de la consommation
        return node;
    }
    
    node->height = 1 + ((getHeight(node->left) > getHeight(node->right)) ? getHeight(node->left) : getHeight(node->right));
    int balance = getBalance(node);
    
    if (balance > 1 && id < node->left->id)
        return rotateRight(node);
    if (balance < -1 && id > node->right->id)
        return rotateLeft(node);
    if (balance > 1 && id > node->left->id) {
        node->left = rotateLeft(node->left);
        return rotateRight(node);
    }
    if (balance < -1 && id < node->right->id) {
        node->right = rotateRight(node->right);
        return rotateLeft(node);
    }
    return node;
}

// Parcours et écriture des résultats
void writeResults(AVLNode* root, FILE* output) {
    if (!root) return;
    writeResults(root->left, output);
    fprintf(output, "%d:%ld:%ld\n", root->id, root->capacity, root->consumption);
    writeResults(root->right, output);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <fichier_data>\n", argv[0]);
        return 1;
    }
    
    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Erreur ouverture fichier");
        return 2;
    }
    
    char line[MAX_LINE];
    AVLNode* root = NULL;
    fgets(line, MAX_LINE, input);  // Ignorer la première ligne
    
    while (fgets(line, MAX_LINE, input)) {
        int id;
        long capacity, consumption;
        if (sscanf(line, "%d:%ld:%ld", &id, &capacity, &consumption) == 3) {
            root = insertNode(root, id, capacity, consumption);
        }
    }
    fclose(input);
    
    FILE *output = fopen("tests/output.csv", "w");
    if (!output) {
        perror("Erreur écriture fichier");
        return 3;
    }
    fprintf(output, "ID_Station:Capacité:Consommation\n");
    writeResults(root, output);
    fclose(output);
    
    printf("Traitement terminé. Résultats sauvegardés dans tests/output.csv\n");
    return 0;
}

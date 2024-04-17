	
%{
    // PARSER FOR A CNF DIMACS TO CNF CONVERTER
	
	#include<stdio.h>
	#include<ctype.h>
    #include<stdlib.h>

    extern int nlin;
    extern int yylex();
    extern FILE * yyin;
    
    void yyerror (char const *);

    // Struct to hold 2 operands and an operator
    struct node{
        int value;
        char operator;
        struct node *left;
        struct node *right;
    };

    // Create a node with value 0
    struct node *zero;

    // Function to initialize node zero
    void init_zero(){
        zero = malloc(sizeof(struct node));
        zero->value = 0;
        zero->operator = '\0';
        zero->left = NULL;
        zero->right = NULL;
    }

    // Function to print the expression tree in postfix notation
    void print_tree(struct node *root){
        if(root == NULL){
            return;
        }
        print_tree(root->left);
        print_tree(root->right);

        if(root->operator == '\0'){
            /* leaf node */
            printf("%d ", root->value);
        }else{
            /* operator node */
            printf("%c ", root->operator);
        }
    }
    
%}

%union{
    int value;
    char character;
    struct node *node;
}	

%token <value> INT
%token EXPR_END
%token <character> ERROR

%type <node> expr 

%start input    /* specify the start symbol */

/* precedence */
%left '+' '-'
%left '*' '/' '%'
%left UMINUS

%%

input: sentence_list
    |   /* empty */
    ;

sentence_list: sentence_list sentence
    | sentence
    ;

sentence: expr EXPR_END { print_tree($1); printf("\n");}
    | EXPR_END
    | ERROR             { yyerror("Error: Unexpected character"); }
    ;

expr: expr '+' expr         { $$ = malloc(sizeof(struct node)); $$->operator = '+'; $$->left = $1; $$->right = $3; $$->value = 0; }
    | expr '-' expr         { $$ = malloc(sizeof(struct node)); $$->operator = '-'; $$->left = $1; $$->right = $3; $$->value = 0; }
    | expr '*' expr         { $$ = malloc(sizeof(struct node)); $$->operator = '*'; $$->left = $1; $$->right = $3; $$->value = 0; }
    | expr '/' expr         { $$ = malloc(sizeof(struct node)); $$->operator = '/'; $$->left = $1; $$->right = $3; $$->value = 0; }
    | expr '%' expr         { $$ = malloc(sizeof(struct node)); $$->operator = '%'; $$->left = $1; $$->right = $3; $$->value = 0; }
    | '(' expr ')'          { $$ = $2; }
    | '-' expr %prec UMINUS { /* left operand as 0 */ 
                              $$ = malloc(sizeof(struct node)); $$->operator = '-'; $$->left = zero; $$->right = $2; $$->value = 0; }
    | INT                   { $$ = malloc(sizeof(struct node)); $$->value = $1; $$->operator = '\0'; $$->left = NULL; $$->right = NULL; }
    ;

%%
// Called by yyparse on error
void yyerror (char const *s){
    fprintf (stderr, "%s at line %d\n", s, nlin);
} 

// Main function     
int main( int argc, char *argv[] ) {
    if (argc!=2){
        fprintf(stderr,"Usage: %s [file]\n", argv[0]);
        return(1);
    }

    yyin = fopen( argv[ 1 ], "r" );
    if ( yyin == NULL ){
        fprintf (stderr, "Error: Cannot open file %s\n", argv[ 1 ] );
        return(1);
    }
    
    // Initialize node zero
    init_zero();

    // Parse the file
    printf("Parsing file %s...\n", argv[1]);

    if (yyparse() == 0){
        printf("File parsed successfully.\n");
        free(zero);

    }else{
        fprintf(stderr, "Error: File finished unexpectedly.\n");
        free(zero);
    }
    
}

	
%{	
	#include<stdio.h>
	#include<ctype.h>
    #include<stdlib.h>
    #include<string.h>

    extern int nlin;
    extern int yylex();
    extern FILE * yyin;
    
    void yyerror (char const *);

    char* make_unary_proposition(char* prop, char op){
        int len = strlen(prop)+2;
        char* result = malloc(len*sizeof(char));
        sprintf(result, "%c%s", op, prop);

        free(prop);

        return result;
    }

    char* make_binary_proposition(char* prop1, char* prop2, char* op){
        int len = strlen(prop1)+strlen(prop2)+strlen(op)+3;
        char* result = malloc(len*sizeof(char));
        sprintf(result, "%s %s %s", prop1, op, prop2);

        free(prop1);
        free(prop2);

        return result;
    }

    char* transform_implies(char* prop1, char* prop2){
        // A → B ≡ ¬(A) ∨ (B)
        // characters needed + 1 null character
        int len = strlen(prop1)+strlen(prop2)+strlen("!() ∨ )") + 1;
        char* result = malloc(len*sizeof(char));
        sprintf(result, "!(%s) ∨ (%s)", prop1, prop2);

        free(prop1);
        free(prop2);

        return result;
    }

    char* transform_iff(char* prop1, char* prop2){
        // A ↔ B ≡ (A → B) ∧ (B → A) ≡ (¬(A) ∨ (B)) ∧ (¬(B) ∨ (A))
        // characters needed + 1 null character
        int len = 2*strlen(prop1)+2*strlen(prop2)+strlen("(!() ∨ ()) ∧ (!() ∨ ())") + 1;
        char* result = malloc(len*sizeof(char));
        sprintf(result, "(!(%s) ∨ (%s)) ∧ (!(%s) ∨ (%s))", prop1, prop2, prop2, prop1);

        free(prop1);
        free(prop2);

        return result;
    }

    char* add_parenthesis(char* prop){
        int len = strlen(prop)+ strlen("()") + 1;
        char* result = malloc(len*sizeof(char));
        sprintf(result, "(%s)", prop);

        free(prop);
        
        return result;
    }

%}

%union{
    char value;
    char *str;
}	

%token <value> VAR
%token AND OR NOT IMPLIES IFF EOL

%type <str> proposition


%start input    /* specify the start symbol */

/* precedence */
%left  IMPLIES IFF
%left  OR
%left  AND
%right NOT

%%

input: formula_list
    |   /* empty */ 
    ;

formula_list: formula_list formula 
    | formula
    ;

formula: EOL
    | proposition EOL       { printf("Proposition: %s\n", $1); free($1); }
    | error EOL             { printf("Error found in line %d\n", nlin); yyerrok; }  
    ;

proposition: NOT proposition            { $$ = make_unary_proposition($2, '!'); }
    | proposition AND proposition       { $$ = make_binary_proposition($1, $3, "∧"); }
    | proposition OR proposition        { $$ = make_binary_proposition($1, $3, "∨"); }
    | proposition IMPLIES proposition   { $$ = transform_implies($1, $3); }
    | proposition IFF proposition       { $$ = transform_iff($1, $3); }
    | '(' proposition ')'               { $$ = add_parenthesis($2); }
    | VAR                               { $$ = malloc(2 * sizeof(char)); 
                                          sprintf($$, "%c", $1);}
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

    // Parse the file
    printf("Parsing file %s...\n", argv[1]);

    if (yyparse() == 0){
        printf("File parsed successfully.\n");

    }else{
        fprintf(stderr, "Error: File finished unexpectedly.\n");
    }
    
}

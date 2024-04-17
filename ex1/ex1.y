	
%{
    // PARSER FOR A CNF DIMACS TO CNF CONVERTER
	
	#include<stdio.h>
	#include<ctype.h>
    #include<stdlib.h>

    #define MAX 1000

    extern int nlin;
    extern int yylex();
    extern FILE * yyin;
    
    void yyerror (char const *);

    int expected_num_clauses;
    int expected_num_vars;

    int num_clauses = 0;
    int max_var = 0;

    char buffer[MAX];
    size_t pos = 0;

    // Flags for error checking
    int p_cnf_found = 0;
    int clause_end_found = 0;
    
%}

%union{
    int value;
    char character;
}	

%token P_CNF
%token <value> NUM
%token ZERO
%token EOL
%token <character> ERROR

%start input    /* specify the start symbol */

%%

input: problem clause_list {
        printf("\n");
}
    |  problem  
    ;

problem: P_CNF NUM NUM EOL  {
        expected_num_vars = $2;
        expected_num_clauses = $3;
        p_cnf_found = 1;
    }
    ;

clause_list: clause_list clause {
        printf(" ∧ ( %s )", buffer);
    }
    |        clause   {
        printf("( %s )", buffer);
    }
    ;

    clause: literal_list clause_end {
        pos = 0;
        num_clauses++;
        clause_end_found = 1;
    }
    |       clause_end  {
        buffer[pos] = '\0';
        num_clauses++;
        clause_end_found = 1;
    }

clause_end: ZERO EOL
    |       ZERO 
    |       EOL {
        printf(" ...\n");
        yyerror("Clause missing a terminating 0");
        return 1;
    }
    |       ERROR{
        clause_end_found = 1;
        printf(" ...\n");

        char message[50]; 
        sprintf(message, "Unexpected character '%c'", $1);
        yyerror(message);
        return 1;
    }
    ;

literal_list: literal_list NUM  {
    int var = $2;
        if($2 > 0){
            int chars_written = sprintf(buffer + pos, " ∨ p%d", $2);
            pos += chars_written; 
        }else{
            int chars_written = sprintf(buffer + pos, " ∨ !p%d", -$2);
            pos += chars_written;
            var = -$2;
        }

        if(var > expected_num_vars){
            max_var = var;
        }
    }
    |         NUM   {
        int var = $1;
        if($1 > 0){
            int chars_written = sprintf(buffer + pos, "p%d", $1);
            pos += chars_written;
        }else{
            int chars_written = sprintf(buffer + pos, "!p%d", -$1);
            pos += chars_written;
            var = -$1;
        }

        if(var > expected_num_vars){
            max_var = var;
        }
        
        clause_end_found = 0;
    }
    ;

%%
// Called by yyparse on error
void yyerror (char const *s){
    fprintf (stderr, "%s at line %d\n", s, nlin);
} 

// Main function     
int main( int argc, char *argv[] ) {
    if (argc!=2){
        fprintf(stderr,"Usage: %s [file.cnf]\n", argv[0]);
        return(1);
    }

    yyin = fopen( argv[ 1 ], "r" );
    if ( yyin == NULL ){
        fprintf (stderr, "Error: Cannot open file %s\n", argv[ 1 ] );
        return(1);
    }
    
    printf("Parsing file %s...\n", argv[1]);
    if (yyparse() == 0){
        int valid = 1;
        if(num_clauses != expected_num_clauses){
            fprintf(stderr, "Error: The number of clauses %d does not match the expected number of clauses %d.\n", num_clauses, expected_num_clauses);
            valid = 0;
        }

        if(max_var > expected_num_vars){
            fprintf(stderr, "Error: The formula contains a variable %d that is greater than the expected number of variables %d.\n", max_var, expected_num_vars);
            valid = 0;
        }

        if(!valid){
            return 1;
        }

    }else{
        if(!p_cnf_found){
            fprintf(stderr, "Error: The p cnf line is missing or not in the correct format.\n");
            return 1;
        }
        fprintf(stderr, "Error: File finished unexpectedly.\n");
    }
    
}

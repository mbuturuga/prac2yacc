	
%{	
	#include<stdio.h>
	#include<ctype.h>
    #include<stdlib.h>
    #include<stdarg.h>

    extern int nlin;
    extern int yylex();
    extern FILE * yyin;
    
    void yyerror (char const *);

    char* get_string(char* format, ...){
        va_list args;

        va_start(args, format);
        int len = vsnprintf(NULL, 0, format, args) + 1;
        va_end(args);

        char* str = malloc(len);
        va_start(args, format);
        vsnprintf(str, len, format, args);
        va_end(args);

        return str;
    }
%}
%debug

%union{
    char *str;
}	

%token <str> VAR CONST PRED FUNC EOL
%token FORALL EXISTS AND OR NOT IMPLIES IFF 

%type <str> wff atomic_formula term term_list composite_formula formula_list formula


%start input    /* specify the start symbol */

/* precedence */
%left  IMPLIES IFF
%left  OR
%left  AND
%right FORALL EXISTS
%right NOT

%%

input: formula_list
    |   /* empty */ 
    ;

formula_list: formula_list formula
    | formula   // wff is a well-formed formula
    ;

formula: wff EOL                {printf("Correct formula: %s\n", $1);}
    | error EOL                 {printf("Error in line %d\n", nlin-1); yyerrok;}
    ;

wff: EOL
    | atomic_formula               
    | composite_formula            
    ;

composite_formula: FORALL VAR wff       {$$ = get_string("forall %s %s", $2, $3);}
    | EXISTS VAR wff                    {$$ = get_string("exists %s %s", $2, $3);}
    | '(' wff ')'                       {$$ = get_string("(%s)", $2);}
    | NOT wff                           {$$ = get_string("!%s", $2);}
    | wff AND wff                       {$$ = get_string("%s ∧ %s", $1, $3);}
    | wff OR wff                        {$$ = get_string("%s ∨ %s", $1, $3);}
    | wff IMPLIES wff                   {$$ = get_string("%s - > %s", $1, $3);}
    | wff IFF wff                       {$$ = get_string("%s < - > %s", $1, $3);}

atomic_formula: PRED '(' term_list ')'  {$$ = get_string("%s(%s)", $1, $3);}
    ;

term_list: term_list ',' term           {$$ = get_string("%s,%s", $1, $3);}
    | term                              {$$ = get_string("%s", $1);}
    ;

term: VAR                               {$$ = get_string("%s", $1);}
    | CONST                             {$$ = get_string("%s", $1);}
    | FUNC '(' term_list ')'            {$$ = get_string("%s(%s)", $1, $3);}
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

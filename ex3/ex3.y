	
%{
    /*Write a yacc syntax specification that accepts as input an integer arithmetic expression in infix notation and generates as output the equivalent integer arithmetic expression but with any redundant parentheses removed.
    */
	
	#include<stdio.h>
	#include<ctype.h>
    #include<stdlib.h>
    #include<math.h>
    #include<string.h>

    extern int nlin;
    extern int yylex();
    extern FILE * yyin;
    
    void yyerror (char const *);

    #define SIZE 5
    #define NO_OPERATOR -1
    #define NO_EXPR -1
    #define PREC(op) (op == '+' || op == '-' ? 0 : (op == '*' || op == '/' || op == '%' ? 1 : 2))
    
    
    // Array of strings to store all expressions
    char **expressions;
    int *operators;
    int num_expr = 0;
    int array_size = SIZE;

    void init_arrays(){
        expressions = malloc(SIZE*sizeof(char*));
        operators = malloc(SIZE*sizeof(int));
    }
    
    void save_expr(int index1, int index2, char operator){
        // Reallocate memory if necessary
        if (num_expr == array_size){
            expressions = realloc(expressions, 2*array_size*sizeof(char*));
            operators = realloc(operators, 2*array_size*sizeof(int));
            array_size *= 2;
        }
        
        char* expr1 = malloc(strlen(expressions[index1])+3);
        char* expr2 = malloc(strlen(expressions[index2])+3);

        int op1 = operators[index1];
        int op2 = operators[index2];

        // Check if parentheses are needed
        if (op1 != NO_OPERATOR && PREC(op1) < PREC(operator)){
            sprintf(expr1, "(%s)", expressions[index1]);
        }
        else{
            sprintf(expr1, "%s", expressions[index1]);
        }

        if (op2 != NO_OPERATOR && (PREC(op2) < PREC(operator) || (operator == '-' && PREC(op2) == PREC(operator)))){
            sprintf(expr2, "(%s)", expressions[index2]);
        }
        else{
            sprintf(expr2, "%s", expressions[index2]);
        }
        
        char* new_expr = malloc(strlen(expr1)+strlen(expr2)+2);
        sprintf(new_expr, "%s %c %s", expr1, operator, expr2);
        expressions[num_expr] = new_expr;
        operators[num_expr] = operator;
        num_expr++;
        free(expr1);
        free(expr2);
    }

    void save_num_expr(int num){
        if (num_expr == array_size){
            expressions = realloc(expressions, 2*array_size*sizeof(char*));
            operators = realloc(operators, 2*array_size*sizeof(int));
            array_size *= 2;
        }
        char* new_expr = malloc(log10(num)+1);
        sprintf(new_expr, "%d", num);
        expressions[num_expr] = new_expr;
        operators[num_expr] = NO_OPERATOR;  
        num_expr++;
    }

    void save_unary_expr(int index, char operator){
        if (num_expr == array_size){
            expressions = realloc(expressions, 2*array_size*sizeof(char*));
            operators = realloc(operators, 2*array_size*sizeof(int));
            array_size *= 2;
        }
        char* right_expr = malloc(strlen(expressions[index])+3);
        int right_op = operators[index];

        if (right_op != NO_OPERATOR && PREC(right_op) <= PREC(operator)){
            sprintf(right_expr, "(%s)", expressions[index]);
        }
        else{
            sprintf(right_expr, "%s", expressions[index]);
        }

        char* new_expr = malloc(strlen(right_expr)+2);
        sprintf(new_expr, "%c%s", operator, right_expr);
        expressions[num_expr] = new_expr;
        operators[num_expr] = operator;
        num_expr++;
        free(right_expr);
    }

    
    void clean_arrays(){
        for (int i = 0; i < num_expr; i++){
            free(expressions[i]);
        }
        num_expr = 0;
    }

%}
// An expression will be a pointer to a string stored in the array of strings
%union{
    int number;
    int index;
}	

%token <number> INT
%token EXPR_END

%type <index> expr

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


sentence: EXPR_END 
    | expr EXPR_END { printf("%s\n", expressions[$1]); clean_arrays();}
    | error EXPR_END { fprintf(stderr, "Error: Invalid expression at line %d\n", nlin); 
                       clean_arrays(); yyerrok; }
    ;

expr: expr '+' expr                 { $$ = num_expr; save_expr($1, $3, '+'); }
    | expr '-' expr                 { $$ = num_expr; save_expr($1, $3, '-'); }
    | expr '*' expr                 { $$ = num_expr; save_expr($1, $3, '*'); }
    | expr '/' expr                 { $$ = num_expr; save_expr($1, $3, '/'); }
    | expr '%' expr                 { $$ = num_expr; save_expr($1, $3, '%'); }
    | '(' expr ')'                  { $$ = $2; }
    | '-' expr %prec UMINUS         { $$ = num_expr; save_unary_expr($2, '-'); }
    | INT                           { $$ = num_expr; save_num_expr($1); }
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
    init_arrays();
    
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

    free(expressions);
    free(operators);
    
}

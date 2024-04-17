  		
	%{
	
	#include<stdio.h>
	#include<ctype.h>
		
    extern int nlin;
    extern int yylex();
    
    void yyerror (char const *);
	
	%}
	

%start calculadora

%union{int valor;
	}

%token <valor> INT

%left '+' '-'
%left '*' '/' '%'
%left UMENYS        /* precedencia de l'operador unari menys */

%type <valor> expr sentencia calculadora

%%

calculadora	:               sentencia
       			 |          calculadora sentencia
        ;
sentencia  :            '\n'               {;}
                 |      expr '\n'             {printf("%d \n", $1);	}
           		 |    	error '\n'             {fprintf(stderr,"ERROR EXPRESSIO INCORRECTA Línea %d \n", nlin);
                                                    yyerrok;	}
          		 ;
expr  :        '(' expr ')'             {$$ = $2;}
      |        expr '+' expr            {$$ = $1 + $3;}
      |        expr '-' expr            {$$ = $1 - $3;} 
      |        expr '*' expr            {$$ = $1 * $3;}
      |        expr '/' expr            {if ($3)
                                          $$ = $1 / $3;
                                         else
                                          {fprintf(stderr,"Divisio per zero \n");
                                           YYERROR;}
                                        }
      |       expr '%' expr           		{$$ = $1 % $3;}
      |       '-' expr %prec UMENYS   {$$ = - $2;}
      |       INT                {$$ = $1;}
      ;
%%
// Called by yyparse on error

void yyerror (char const *s){
    fprintf (stderr, "%s\n", s);
}
          
int main(){
    return (yyparse());
}

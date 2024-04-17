%{
	#include "calculadora_basica.tab.h"
	int nlin=0;
%}

%option nounput
%option noinput

%option noyywrap


%%
[ \t]+                          ;

[0-9]+                          {	yylval.valor=atoi(yytext);
                               	 	 return(INT);
                                }

\n                             {	nlin++;
                                    return(yytext[0]);
                                }

.                     		 {	return(yytext[0]);	}	/*  Els errors es processaran a nvell sintàctic */


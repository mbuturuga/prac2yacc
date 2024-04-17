%{
    # include "ex1.tab.h"
    int nlin = 1;
%}

%option nounput
%option noinput

%option noyywrap

NUMBER [1-9][0-9]*
WHITESPACE [ \t]

COMMENT c.*\n

%%

{COMMENT}           {   nlin++; /*ignore comments*/ }

{WHITESPACE}        {   /*ignore whitespace*/    }

"p cnf"             {   return P_CNF;   }   

-?{NUMBER}          {   yylval.value=atoi(yytext);
                        return(NUM);    }

0                   {   return ZERO;    }

\n                  {   nlin++; return EOL;    }

.                   {   /* errors handled by the parser, return ERROR and the value */
                        yylval.value=yytext[0];
                        return ERROR;   }


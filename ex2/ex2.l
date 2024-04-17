%{
    # include "ex2.tab.h"
    int nlin = 1;
%}

%option noinput
%option nounput

%option noyywrap

INTEGER     [0-9]+
OPERATOR    [+\-*\/%]
WHITESPACE  [ \t\n]+
COMMENT     #.*\n

%%

{WHITESPACE}    { /* ignore */ }
{COMMENT}       { /* ignore */ nlin++; }
\n              { nlin++; }

{INTEGER}       { yylval.value = atoi(yytext); return INT; }
{OPERATOR}      { return yytext[0]; }
"("             { return yytext[0]; }
")"             { return yytext[0]; }
";"             { return EXPR_END; }
.               { yylval.value = yytext[0]; return ERROR; }

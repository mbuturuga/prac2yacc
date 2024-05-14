
%option nounput
%option noinput
%option noyywrap

%{
# include "ex4.tab.h"
#include <string.h> // for strncpy

int nlin = 1;

%}

VARIABLES   [A-Z]
WHITESPACE  [ \t]+
COMMENT     #.*\n

%%

{WHITESPACE} { /* ignore whitespace */ }
{COMMENT}    { /* ignore comments */ nlin++; }
\n           { nlin++; return EOL; }

{VARIABLES}  { yylval.value = yytext[0]; return VAR; }
∧            { return AND; }
∨            { return OR; }
!            { return NOT; }
"- >"        { return IMPLIES; }
"< - >"      { return IFF; }
"("|")"      { return yytext[0]; }
.            { return yytext[0]; }

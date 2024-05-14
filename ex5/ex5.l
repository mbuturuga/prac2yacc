
%option nounput
%option noinput
%option noyywrap

%{
# include "ex5.tab.h"
#include <string.h> // for strncpy

int nlin = 1;

%}

VARIABLES    [x-z][1-9]+
CONSTANTS    [a-c][1-9]+
PREDICATES   [P-T][1-9]+
FUNCTIONS    [f-g][1-9]+

SEPARATORS   "("|")"|","|";"

WHITESPACE  [ \t]+
COMMENT     #.*\n

%%

{WHITESPACE}  { /* ignore whitespace */ }
{COMMENT}     { /* ignore comments */ nlin++; }
\n            { nlin++; return EOL; }

{VARIABLES}   { yylval.str = malloc( yyleng+1 ); strcpy( yylval.str, yytext ); return VAR; }
{CONSTANTS}   { yylval.str = malloc( yyleng+1 ); strcpy( yylval.str, yytext ); return CONST; }
{PREDICATES}  { yylval.str = malloc( yyleng+1 ); strcpy( yylval.str, yytext ); return PRED; }
{FUNCTIONS}   { yylval.str = malloc( yyleng+1 ); strcpy( yylval.str, yytext ); return FUNC; }

forall       { return FORALL; }
exists       { return EXISTS; }

{SEPARATORS} { return yytext[0]; }

∧            { return AND; }
∨            { return OR; }
!            { return NOT; }
"- >"        { return IMPLIES; }
"< - >"      { return IFF; }
    
.            { return yytext[0]; }


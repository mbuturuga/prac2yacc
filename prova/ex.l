
%option nounput
%option noinput
%option noyywrap

%{
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
\n            { nlin++; }

{PREDICATES}  { printf("PREDICATES: %s\n", yytext); }
.             {;}



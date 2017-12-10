%{
#include <stdio.h>
#include <stdlib.h>
#define YYDEBUG 1
%}

%union {
    int          int_value;
    double       double_value;
}


%token <int_value> INTEGER
%token <double_value> FLOAT
%token ADD SUB MUL DIV SUR LF AND OR XOR
%type <int_value> expr term primary_expr logic

%%
line_list
    : line
    | line_list line
    ;
line
    : logic LF { printf("-> %d\n", $1); }
logic
    : expr
    | logic AND expr { $$ = $1 & $3; }
    | logic OR  expr { $$ = $1 | $3; }
    | logic XOR expr { $$ = $1 ^ $3; }
    ;
expr
    : term
    | expr ADD term { $$ = $1 + $3; }
    | expr SUB term { $$ = $1 - $3; }
    ;
term
    : primary_expr
    | term MUL primary_expr { $$ = $1 * $3; }
    | term DIV primary_expr { $$ = $1 / $3; }
    | term SUR primary_expr { $$ = $1 % $3; }
    ;
primary_expr
    : INTEGER
    ;
%%

int yyerror(char const *str)
{
    extern char *yytext;
    fprintf(stderr, "Syntax Error: %s\n", yytext);
    return 0;
}

int main(void)
{
    extern int yyparse(void);
    extern FILE *yyin;

    yyin = stdin;
    if (yyparse()) {
        fprintf(stderr, "Error Occured!\n");
        exit(1);
    }
}

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
%type <double_value> block expr term number

%%
line_list
    : line
    | line_list line
    ;
line
    : block LF        { printf("-> %f\n", $1); }
    ;
block
    :expr             { $$ = $1; }
    ;
expr
    : term            { $$ = $1; }
    | expr ADD term   { $$ = $1 + $3; }
    | expr SUB term   { $$ = $1 - $3; }
    ;
term
    : number          { $$ = $1; }
    | term MUL number { $$ = $1 * $3; }
    | term DIV number { $$ = $1 / $3; }
    | term SUR number { $$ = (int)$1 % (int)$3; }
    ;
number
    : INTEGER         { $$ = (double)$1; }
    | FLOAT           { $$ = $1; }
    ;
%%

int yyerror(char const *str)
{
    extern char *yytext;
    fprintf(stderr, "Syntax Error: %s\n", yytext);
    return 0;
}

int main(int argc, char* argv[])
{
    extern int yyparse(void);
    extern FILE *yyin;
    if ( argc < 2 ) { yyin = stdin; }
    else            { yyin = fopen(argv[1], "r"); }

    do {
        if (yyparse()) {
            fprintf(stderr, "Error Occured!\n");
            exit(1);
        }
    } while(!feof(yyin));

}

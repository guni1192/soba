%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define YYDEBUG 1

#define VARSIZE 64
#define VARNAMESIZE 64

typedef struct {
    char name[VARNAMESIZE];
    double value;
} variable;

double get_value(char *name);
int var_used = 0;
variable var[VARSIZE] = {NULL, 0};

%}

%union {
    int          int_value;
    double       double_value;
    char         *char_value;
}


%token <int_value> INTEGER
%token <double_value> FLOAT
%token <char_value> VAR
%token ADD SUB MUL DIV SUR LF AND OR XOR EQU
%type <double_value> block expr term number

%%
line_list
    : line
    | line_list line
    ;
line
    : block LF        { printf("%f\n", $1); }
    ;
block
    : expr            { $$ = $1; }
    ;
expr
    : term            { $$ = $1; }
    | VAR EQU expr    { substitution($1, $3); $$ = $3; }
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
    | VAR             { $$ = get_value($1); }
    ;
%%

int search_variable(char *name) {
    for ( int i = 0; i <= var_used; i++ ) {
        puts("yet");
        if ( !strcmp(var[i].name, name) ) { return i; }
    }
    return -1;
}

int substitution(char *name, double value)
{
    int i = search_variable(name);
    if ( i == -1 ) {
        strcpy(var[var_used].name, name);
        var[var_used].value = value;
        var_used++;
    }
    else {
        var[i].value = value;
    }
    return 0;
}

double get_value(char *name)
{
    int i = search_variable(name);
    if ( i != -1 ) { return var[i].value; }
    printf("%s is not definded\n", name);
    return 0.0;
}

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



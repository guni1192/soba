%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define YYDEBUG 1

#define VARSIZE 255
#define VARNAMESIZE 255

typedef struct {
    char *name;
    double value;
} variable;

int var_used = 0;
variable var[VARSIZE];
double get_value(char *name);
int substitution(char *name, double value);

%}

%union {
    int          int_value;
    double       double_value;
    char         *string;
}


%token <int_value> INTEGER
%token <double_value> FLOAT
%token <string> VAR STR
%token LF IF PRINT PRINTLN
%type <double_value> block expr term number if_statement
%type <string> string
%start program

%%
program
    :
    | PRINT block LF    { printf("%f", $2); }
    | PRINTLN block LF  { printf("%f\n", $2); }
    | PRINT string LF   { printf("%s", $2); }
    | PRINTLN string LF { printf("%s\n", $2); }
    | program PRINT block LF    { printf("%f", $3); }
    | program PRINTLN block LF  { printf("%f\n", $3); }
    | program PRINT string LF   { printf("%s", $3); }
    | program PRINTLN string LF { printf("%s\n", $3); }
    | program block LF  { printf("--> %f\n", $2);}
    | string LF         { printf("--> %s\n", $1); }
    | block LF          { printf("--> %f\n", $1);}
    ;
string
    : STR               { $$ = $1; }
    ;
block
    : expr            { $$ = $1; }
    | VAR '=' expr    { substitution($1, $3); $$ = $3; }
    | if_statement    { $$ = $1; }
    ;
if_statement
    : IF expr ':' block     { if ( $2 != 0 ) $$ = $4;
                              else $$ = 0; }
    | block IF expr         { if ( $3 != 0 ) $$ = $1;
                              else $$ = 0; }
    ;
expr
    : term              { $$ = $1; }
    | expr '+' term     { $$ = $1 + $3; }
    | expr '-' term     { $$ = $1 - $3; }
    ;
term
    : number          { $$ = $1; }
    | term '*' number { $$ = $1 * $3; }
    | term '/' number { $$ = $1 / $3; }
    | term '%' number { $$ = (int)$1 % (int)$3; }
    ;
number
    : INTEGER         { $$ = (double)$1; }
    | FLOAT           { $$ = $1; }
    | VAR             { $$ = get_value($1); }
    ;
%%

int search_variable(char *name) {
    for ( int i = 0; i < var_used; i++ ) {
        if ( !strcmp(var[i].name, name) ) { return i; }
    }
    return -1;
}

int substitution(char *name, double value)
{
    int i = search_variable(name);
    if ( i == -1 ) {
        var[var_used].name = strdup(name);
        var[var_used].value = value;
        var_used++;
    }
    else { var[i].value = value; }
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

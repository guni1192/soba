%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define YYDEBUG 1

#define VARSIZE 255

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
%token <string> VAR STR RANGE
%token LF IF PRINT PRINTLN FOR IN TRUE FALSE
%type <int_value> block expr number if_stmt_num
%type <string> string
%start program

%left '+' '-'
%left '*' '/' '%'

%%
program
    :
    | block LF          { printf("--> %d\n", $1); }
    | string LF         { printf("--> %s\n", $1); }
    | program block LF  { printf("--> %d\n", $2); }
    | program string LF { printf("--> %s\n", $2); }
    ;
string
    : STR               { $$ = $1; }
    ;
block
    : expr              { $$ = $1; }
    | if_stmt_num       { $$ = $1; }
    ;
if_stmt_num
    : IF expr ':' block { if ( $2 != 0 ) $$ = $4;
                          else $$ = 0; }
    | block IF expr     { if ( $3 != 0 ) $$ = $3;
                          else $$ = 0; }
    ;

expr
    : number            { $$ = $1; }
    | VAR '=' expr      { substitution($1, $3); $$ = $3; }
    | expr '+' expr     { $$ = $1 + $3; }
    | expr '-' expr     { $$ = $1 - $3; }
    | expr '*' expr     { $$ = $1 * $3; }
    | expr '/' expr     {
          if ( $3 != 0 ){ $$ = $1 / $3; }
          else {
              fprintf(stderr, "Zero divide error!!\n"); 
              $$ = -1;
          }
      }
    | expr '%' expr     { $$ = $1 % $3; }
    ;
number
    : INTEGER           { $$ = (double)$1; }
    | FLOAT             { $$ = $1; }
    | VAR               { $$ = get_value($1); }
    | TRUE              { $$ = 1; }
    | FALSE             { $$ = 0; }
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

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#define YYDEBUG 1

#define VARSIZE 255

typedef struct {
    char *name;
    int value;
} variable;

int var_used = 0;
variable var[VARSIZE];
double get_value(char *name);
int substitution(char *name, int value);
char *to_string(int expr);

%}
%union {
    int          int_value;
    double       double_value;
    char         *string;
}


%token <int_value> INTEGER
%token <double_value> FLOAT
%token <string> VAR STR RANGE
%token
  LF
  PRINT
  PRINTLN
  IF
  FOR
  IN
  TRUE
  FALSE
  op_plus
  op_minus
  op_mult
  op_div
  op_mod
  op_pleq
  op_mieq
  op_mueq
  op_dieq
  op_eq
  op_eqeq
  op_neq
  op_lt
  op_le
  op_gt
  op_ge
  op_colon
  op_scolon
%type <int_value> block expr number if_stmt_num

%type <string> string
%start program

%left op_eqeq op_nep op_lt op_le op_gt op_ge
%left op_plus op_minus
%left op_mult op_div op_mod

%%
program
    :
    | string LF         { printf("--> %s\n", $1); }
    | program string LF { printf("--> %s\n", $2); }
    ;
string
    : STR               { $$ = $1; }
    | VAR op_eq string  { $$ = $3; }
    | block             { 
            char *temp;
            strcpy(temp, to_string($1));
            $$ = temp; 
        }
    ;
block
    : expr              { $$ = $1; }
    | block expr        { $$ = $2; }
    | if_stmt_num       { $$ = $1; }
    ;
if_stmt_num
    : IF expr op_colon block { if ( $2 != 0 ) $$ = $4; else $$ = 0; }
    | block IF expr     { if ( $3 != 0 ) $$ = $3; else $$ = 0; }
    ;
expr
    : number                { $$ = $1; }
    | VAR op_eq expr        { substitution($1, $3); $$ = $3; }
    | expr op_eqeq expr     { $$ = $1 == $3; }
    | expr op_neq expr      { $$ = $1 != $3; }
    | expr op_lt expr       { $$ = $1 < $3; }
    | expr op_le expr       { $$ = $1 <= $3; }
    | expr op_gt expr       { $$ = $1 > $3; }
    | expr op_ge expr       { $$ = $1 >= $3; }
    | expr op_plus expr     { $$ = $1 + $3; }
    | expr op_minus expr    { $$ = $1 - $3; }
    | expr op_mult expr     { $$ = $1 * $3; }
    | expr op_div expr      {
          if ( $3 != 0 ){ $$ = $1 / $3; }
          else {
              fprintf(stderr, "Zero divide error!!\n"); 
              $$ = -1;
          }
      }
    | expr op_mod expr     { $$ = $1 % $3; }
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

int substitution(char *name, int value)
{
    int i = search_variable(name);
    if ( i == -1 ) {
        var[var_used].name = strdup(name);
        if ( isdigit(value) )
        var[var_used].value = value;
        var_used++;
    }
    else { var[i].value = value; }
    return 0;
}

char *to_string(int expr) {
    char temp[255];
    char *p;
    snprintf(temp, 255, "%d", expr);
    p = malloc(sizeof(char) * 255);
    p = temp;
    return p;
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

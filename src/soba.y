%{

#define YYDEBUG 1
#define YYERROR_VERBOSE 1

#include "soba.h"
#include "node.h"

%}

%union {
    node *nd;
    soba_id id;
}


%type<nd> program compstmt
%type<nd> stmt expr condition block cond var primary primary0
%type<nd> stmts args opt_args opt_block f_args map map_args bparam
%type<nd> opt_else opt_elsif
%type<id> identifier

%pure-parser
%parse-param {parser_state *p}
%lex-param {p}

%{
int yylex(YYSTYPE *lval, parser_state *p);
static void yyerror(parser_state *p, const char *s);
%}

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
%type <int_value> block expr number

%type <string> string if_stmt
%start program

%left op_eqeq op_nep op_lt op_le op_gt op_ge
%left op_plus op_minus
%left op_mult op_div op_mod

%%
program     : compstmt { p->lval = $1; }
            ;
compstmt    : stmts opt_terms
            ;
stmts       : { $$ = node_ }
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
    snprintf(temp, 255, "%d", expr);
    return strdup(temp);
}

int get_value(char *name)
{
    int i = search_variable(name);
    if ( i != -1 ) { return var[i].value; }
    printf("%s is not definded\n", name);
    return 0;
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

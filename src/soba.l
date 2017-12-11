/* 定義部 */
%{
#include <stdio.h>
#include "soba.tab.h"

int yywrap(void) {
    return 1;
}
%}

%%

"udon" { fprintf(stderr, "Syntax Error: %s\n", yytext); exit(1); }

"+"       return ADD;
"-"       return SUB;
"*"       return MUL;
"/"       return DIV;
"%"       return SUR;
"="       return EQU;
"\n"      return LF;
"and"     return AND;
"or"      return OR;

[ \t]+      {}

[1-9][0-9]* {
    int temp;
    // 入力から実数を取得
    sscanf(yytext, "%d", &temp);
    yylval.int_value = temp;
    return INTEGER;
}

[0-9]*\.[0-9]* {
    double temp;
    sscanf(yytext, "%lf", &temp);
    yylval.double_value = temp;
    return FLOAT;
}

[a-zA-Z_]+ {
    char *temp;
    sscanf(yytext, "%s", temp);
    yylval.char_value = temp;
    return(VAR);
}


. { fprintf(stderr, "Syntax Error: %s\n", yytext); exit(1); }

%%

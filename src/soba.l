/* 定義部 */
%{
#include <stdio.h>
#include <string.h>
#include "soba.tab.h"

int yywrap(void) {
    return 1;
}
%}

%%

"udon" { fprintf(stderr, "Syntax Error: %s\n", yytext); exit(1); }

[+\-*/%=<>:;]  {
    return yytext[0];
}

"\n"              return LF;
"if"              return IF;
"for"             return FOR;
"in"              return IN;
"print"           return PRINT;
"println"         return PRINTLN;

[ \t]+ {}

\".*\" {
  yytext[strlen(yytext)-1] = '\0';
  yytext = &yytext[1];
  yylval.string = strdup(yytext);
  return STR;
}

[1-9][0-9]\.\.[1-9][0-9] {
    yylval.string = strdup(yytext);
    return RANGE;
}

[1-9]?[0-9]* {
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
    yylval.string = strdup(yytext);
    return(VAR);
}

. { fprintf(stderr, "Syntax Error: %s\n", yytext); exit(1); }

%%

digit	[0-9]
letter	[A-Za-z]

%{
#include <stdio.h>
#include "y.tab.h"
int lineCount=0;
%}
%%



elif {return ELIF;}
else {return ELSE;}
if {return IF;}
\n  {lineCount++;return NEXT_LINE;}
\-?({digit}+)\.({digit}+) {yylval.str=strdup(yytext);return FLOAT;}
\-?({digit}+) {yylval.str=strdup(yytext);return INTEGER;}

\"({letter}|{digit})+\" {yylval.str=strdup(yytext); return STRING;}
{letter}({letter}|{digit})*	{yylval.str=strdup(yytext); return IDENTIFIER;}


">"|"<"|">="|"<="|"=="|"!=" {yylval.str=strdup(yytext);return COMPARE;}
"+"|"-"|"/"|"*" {yylval.str=strdup(yytext);return OPERATOR;}
":" return COLON;
"=" return EQUAL;
(\t|[ ]{4}) return TAB;

. {}

%%

%{
#include "scanType.h"
#include "parser.tab.h" // This has to be the last include

using namespace std;

#define YY_DECL extern "C" int yylex()
#define YYSTYPE int

int line=1;
char *lastToken=(char *)"";
//extern int numErrors;

int setValue(int linenum, int tokenClass, char *svalue) {
    yylval.tinfo.tokenclass = tokenClass;
    yylval.tinfo.linenum = linenum;
    yylval.tinfo.tokenstr = strdup(svalue);
    yylval.tinfo.cvalue = svalue[0];
    yylval.tinfo.nvalue = atoi(svalue);
    yylval.tinfo.svalue = strdup(svalue);

    yylval.tinfo.tokenstr = lastToken = strdup(svalue);

    switch (tokenClass) {

    case NUMCONST:
         // yylval.tinfo.nvalue = hmmmm ..... I don't need this yet, but
         break;

    case OP:
         // yylval.tinfo.cvalue = hmmm..... What should I set it to?
         break;
    }


    return tokenClass;
}

%}

%option noyywrap

letter      [a-zA-Z]
digit    [0-9]
quote    [\']
underbar [_]
letdig      {digit}|{letter}|{underbar}
limitters   [\;\,\(\)\{\}\[\]]
op    [\-\+\*\/\%]
whitespace  [\ \t]
%%
[\(\)]         { return setValue(line, OP, yytext); } // single char tokens

"!="           { return setValue(line, NEQ, yytext); }

"and"          { return setValue(line, AND, yytext); }

^"#DRBC ".*    { return setValue(line, PRECOMPILER, yytext); }

[0-9]+         { return setValue(line, NUMCONST, yytext); }
\n             {  line++; }
{whitespace}+  ;
.              { printf("ERROR(%d): Token error, invalid or misplaced input character: \'%c\'. Character Ignored.\n", line, yytext[0]);}



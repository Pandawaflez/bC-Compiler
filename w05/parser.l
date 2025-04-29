%{
#include "scanType.h"
#include "treeUtils.h"
#include "treeNodes.h"
#include "parser.tab.h" // This has to be the last include
using namespace std;

#define YY_DECL extern "C" int yylex()
#define YYSTYPE int

int line=1;
char *lastToken=(char *)"";
//extern int numErrors;

int setValue(int linenum, int tokenClass, char *svalue) {
    //printf( "|%d) |%s|\n" , linenum , svalue );
    yylval.tokenData = new TokenData;
    yylval.tokenData->tokenclass = tokenClass;
    yylval.tokenData->linenum = linenum;
    yylval.tokenData->tokenstr = strdup(svalue);
    yylval.tokenData->cvalue = svalue[0];
    yylval.tokenData->nvalue = atoi(svalue);
    yylval.tokenData->svalue = strdup(svalue);

    yylval.tokenData->tokenstr = lastToken = strdup(svalue);

    switch (tokenClass) {
      case ID:
         yylval.tokenData->svalue =lastToken;
         break;
      case STRINGCONST:
         yylval.tokenData->nvalue = strlen(svalue)-2;
         yylval.tokenData->svalue = strdup(&svalue[1]);
         yylval.tokenData->svalue[yylval.tokenData->nvalue] = '\0';
         break;
      case '\\' || '*' || '+' || '-' || '=' || 
            ';' || '(' || ')' || '{' || '}' 
            || '<' || '>' || ',' || ':' || 
            '?' || '%' || '[' || ']' || '/':
         yylval.tokenData->cvalue = svalue[0];
         // yylval.tinfo->nvalue = 1;
         break;
      case NUMCONST:
         yylval.tokenData->nvalue = atoi(svalue);
         break;
      case CHARCONST:
         yylval.tokenData->cvalue = svalue[1];
         yylval.tokenData->nvalue = 1;
         //printf("%s\n",svalue);
         if(svalue[1] == '\\'){
            if(svalue[2]=='n'){yylval.tokenData->cvalue = '\n';}
            if(svalue[2]=='0'){yylval.tokenData->cvalue = '\0';}
         }
         break;
      case BOOLCONST:
         if (yylval.tokenData->cvalue == 't') {
            yylval.tokenData->nvalue = 1;
            yylval.tokenData->tokenstr = (char*)"true";
            yylval.tokenData->svalue = (char*)"true";
            //printf("Value is true\n");
         } else {
            yylval.tokenData->nvalue = 0;
            yylval.tokenData->tokenstr = (char*)"false";
            yylval.tokenData->svalue = (char*)"false";
            //printf("Value is false\n");
         }
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
[\(\)\=\-\+\*\/\%\<\>\,\}\:\;\[\]\?\{]         { return setValue(line, yytext[0], yytext); } // single char tokens

"int"          { return setValue(line, INT, yytext); }
"bool"         { return setValue(line, BOOL, yytext); }
"char"         { return setValue(line, CHAR, yytext); }
"break"	       { return setValue(line, BREAK, yytext); }
"do"           { return setValue(line, DO, yytext); }
"else"	       { return setValue(line, ELSE, yytext); }
"by"           { return setValue(line, BY, yytext); }
"true"	       { return setValue(line, BOOLCONST, yytext); }
"return"       { return setValue(line, RETURN, yytext); }
"static"       { return setValue(line, STATIC, yytext); }
"to"	       { return setValue(line, TO, yytext); }
"while"	       { return setValue(line, WHILE, yytext); }
"if"           { return setValue(line, IF, yytext); }
"then"         { return setValue(line, THEN, yytext); }
"for"          { return setValue(line, FOR, yytext); }
"false"	       { return setValue(line, BOOLCONST, yytext); }
"=="           { return setValue(line, EQ, yytext); }
">="           { return setValue(line, GEQ, yytext); }
"<="           { return setValue(line, LEQ, yytext); }
"!="           { return setValue(line, NEQ, yytext); }
"+="           { return setValue(line, ADDASS, yytext); }
"-="           { return setValue(line, SUBASS, yytext); }
"*="           { return setValue(line, MULASS, yytext); }
"/="           { return setValue(line, DIVASS, yytext); }
"--"           { return setValue(line, DEC, yytext); }
"++"           { return setValue(line, INC, yytext); }
"not"          { return setValue(line, NOT, yytext); }
"and"          { return setValue(line, AND, yytext); }
"or"           { return setValue(line, OR, yytext); }
":<:"          { return setValue(line, MIN, yytext); }
":>:"          { return setValue(line, MAX, yytext); }
^"#DRBC ".*    { return setValue(line, PRECOMPILER, yytext); }
^"#DRBCRUN ".*    { return setValue(line, PRECOMPILER, yytext); }
{letter}{letdig}*  { return setValue(line, ID, yytext); }
[0-9]+         { return setValue(line, NUMCONST, yytext); }
\'{letdig}\'       { return setValue(line, CHARCONST, yytext); }
"' '"       	  { return setValue(line, CHARCONST, yytext); }
\'\\{letter}\'       { return setValue(line, CHARCONST, yytext);/*Error condition later on for '\\0' possibly*/}
\"[^"\n]*\"       { return setValue(line, STRINGCONST, yytext);}
\n             {  line++; }

"//".*	;
{whitespace}+  ;

.              { printf("ERROR(%d): Token error, invalid or misplaced input character: \'%c\'. Character Ignored.\n", line, yytext[0]);}




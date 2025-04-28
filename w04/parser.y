%{
#include <cstdio>
#include <iostream>
#include <unistd.h>
#include "scanType.h"
#include "treeUtils.h"
#include "treeNodes.h"
#include "semantics.h"
#include "symbolTable.h"
using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *msg);

void printToken(TokenData myData, string tokenName, int type = 0) {
   cout << "Line: " << myData.linenum << " Type: " << tokenName;
   if(type==0)
     cout << " Token: " << myData.tokenstr;
   if(type==1)
     cout << " Token: " << myData.nvalue;
   if(type==2)
     cout << " Token: " << myData.cvalue;
   cout << endl;
}
int numErrors;
int numWarnings;
extern int line;
extern int yylex();
TreeNode *syntaxTree;
TreeNode *addSibling(TreeNode *t, TreeNode *s)
{
// make sure s is not null. If it is this s a major error. Exit the program!
if (s == NULL){printf("Error "); exit(1);}
// Make sure t is not null. If it is, just return s
if (t == NULL){return s;}
// look down t’s sibling list until you fin with with sibblin = null (the end o f the lsit) and add s there.
TreeNode *temp = t;
while (temp->sibling != NULL)
{
	temp = temp->sibling;
}
temp->sibling = s;
return t;
}
// pass the static and type attribute down the sibling list
void setType(TreeNode *t, ExpType type, bool isStatic)
{
	while (t) {
 		t->type = type;
		t->isStatic = isStatic;
 		t = t->sibling;
	}
}
// the syntax tree goes here

%}
%union
{
   TokenData *tokenData;
   TreeNode  *tree;
   ExpType   type;
}
%type <tokenData> assignop minmaxop mulop relop sumop unaryop
%type    <tree> program
%type    <tree> precomList declList decl varDecl scopedVarDecl varDeclList varDeclInit varDeclId
%type    <tree> funDecl parms parmList parmTypeList parmIdList parmId stmt
%type    <tree> matched iterRange unmatched expStmt compoundStmt localDecls stmtList returnStmt breakStmt
%type    <tree> simpleExp andExp unaryRelExp relExp minmaxExp sumExp mulExp unaryExp
%type    <tree> factor mutable immutable call args argList constant exp
%type    <type> typeSpec
%token   <tokenData>  '*' '-' '+' '/' '>' '<' '=' '?' '%'
%token   <tokenData>  ';' ':'  ')' '(' ',' '[' '{' '}' ']'
%token   <tokenData>  NOT
%token   <tokenData>  AND
%token   <tokenData>  OR
%token   <tokenData>  GEQ
%token   <tokenData>  ADDASS
%token   <tokenData>  SUBASS
%token   <tokenData>  MULASS
%token   <tokenData>  DIVASS
%token   <tokenData>  DEC
%token   <tokenData>  INC
%token   <tokenData>  NEQ
%token   <tokenData>  EQ
%token   <tokenData>  LEQ
%token   <tokenData>  PRECOMPILER
%token   <tokenData>  NUMCONST
%token   <tokenData>  ERROR
%token   <tokenData>  MIN
%token   <tokenData>  MAX
%token   <tokenData>  ID
%token   <tokenData>  CHARCONST
%token   <tokenData>  QUOTE
%token   <tokenData>  UNDERBAR
%token   <tokenData>  LETDIG
%token   <tokenData>  INT
%token   <tokenData>  CHAR
%token   <tokenData>  BOOL
%token   <tokenData>  STRINGCONST
%token   <tokenData>  BREAK
%token   <tokenData>  DO
%token   <tokenData>  ELSE
%token   <tokenData>  BY
%token   <tokenData>  BOOLCONST
%token   <tokenData>  RETURN
%token   <tokenData>  STATIC
%token   <tokenData>  TO
%token   <tokenData>  WHILE
%token   <tokenData>  IF
%token   <tokenData>  THEN
%token   <tokenData>  FOR
%token   <tokenData>  CHSIGN
%token   <tokenData>  SIZEOF
%token   <tokenData>  LASTTERM
%%
program    : precomList declList                    { syntaxTree = $2;}
           ;

precomList : precomList PRECOMPILER                   {$$=NULL; printf("%s\n", yylval.tokenData->tokenstr );}
             | PRECOMPILER                                 {$$ = NULL; printf("%s\n", yylval.tokenData->tokenstr );}
             | /* empty */                                 {$$ = NULL;}
           ;

declList   : declList decl                          {$$ = addSibling($1,$2);}
             | decl				    {$$=$1;}
           ;

decl       : varDecl				{$$ = $1;}
             | funDecl				{$$ = $1;}
           ;

varDecl    : typeSpec varDeclList ';'               {$$=$2;setType($2,$1,false);}
           ;


scopedVarDecl : STATIC typeSpec varDeclList ';'     {$$=$3;setType($3,$2,true);}
                | typeSpec varDeclList ';'             {$$=$2;setType($2,$1,false);}
              ;

varDeclList  : varDeclList ',' varDeclInit          {$$ = addSibling($1,$3);}
               | varDeclInit	{$$=$1;}
             ;

varDeclInit  : varDeclId
               | varDeclId ':' simpleExp               {$$ = $1; if ($$ != NULL) $$->child[0] = $3;}
             ;

varDeclId   : ID                                         {$$=newDeclNode(VarK,UndefinedType,$1);}
             | ID '[' NUMCONST ']'                         {$$=newDeclNode(VarK,UndefinedType,$1);$$->isArray=true;$$->size=$3->nvalue+1;}
             ;

typeSpec   : INT                                        {$$=Integer;}
             | BOOL                                        {$$=Boolean;}
             | CHAR                                        {$$=Char;}
           ;

funDecl    : typeSpec ID '(' parms ')' stmt       {$$ =newDeclNode(FuncK,$1,$2,$4,$6);}
             | ID '(' parms ')' stmt              {$$ =newDeclNode(FuncK,Void,$1,$3,$5);}
           ;

parms      : parmList
             | /* empty */                                { $$ =NULL;}
           ;

parmList   : parmList ';' parmTypeList              {$$=addSibling($1,$3);}
             | parmTypeList	{$$=$1;}
           ;

parmTypeList : typeSpec parmIdList                  {$$=$2;setType($2,$1,false);}
             ;

parmIdList   : parmIdList ',' parmId                 {$$=addSibling($1,$3);}
             | parmId				     {$$=$1;}
             ;

parmId     : ID                                          {$$=newDeclNode(ParamK,UndefinedType,$1);}
             | ID '[' ']'                                   {$$=newDeclNode(ParamK,UndefinedType,$1);$$->isArray=true;}
           ;

stmt       : matched				{$$=$1;}
             | unmatched			{$$=$1;}
           ;


matched    : IF simpleExp THEN matched ELSE matched   {$$=newStmtNode(IfK,$1,$2,$4,$6);}
             | WHILE simpleExp DO matched                  {$$=newStmtNode(WhileK,$1,$2,$4);}
             | FOR ID '=' iterRange DO matched             {$$=newStmtNode(ForK,$1,newDeclNode(VarK,Integer,$2),$4,$6);} /*May Need Change Later*/
             | expStmt		{$$=$1;}
             | compoundStmt	{$$=$1;}
             | returnStmt	{$$=$1;}
             | breakStmt	{$$=$1;}
           ;

iterRange  : simpleExp TO simpleExp                  {$$=newStmtNode(RangeK,$2,$1,$3);}/*May Need Changed Later*/
             | simpleExp TO simpleExp BY simpleExp    {$$=newStmtNode(RangeK,$2,$1,$3,$5);}
           ;

unmatched  : IF simpleExp THEN stmt                     {$$=newStmtNode(IfK,$1,$2,$4);}
             | IF simpleExp THEN matched ELSE unmatched  {$$=newStmtNode(IfK,$1,$2,$4,$6);}
             | WHILE simpleExp DO unmatched                {$$=newStmtNode(WhileK,$1,$2,$4);}
             | FOR ID '=' iterRange DO unmatched           {$$=newStmtNode(ForK,$1,newDeclNode(VarK,Integer,$2),$4,$6);}
           ;

expStmt    : exp ';'	{$$=$1;}
             | ';'                                        {$$ =NULL;}
           ;

compoundStmt : '{' localDecls stmtList '}'         {$$=newStmtNode(CompoundK,$1,$2,$3);}
             ;

localDecls : localDecls scopedVarDecl              {$$=addSibling($1,$2);}
             | /* empty */                               { $$ =NULL;}
             ;

stmtList   : stmtList stmt                         {$2 == NULL ? $$ = $1 : $$=addSibling($1,$2);}
             | /* empty */                               { $$ =NULL;}
           ;

returnStmt : RETURN ';'                                {$$=newStmtNode(ReturnK,$1);}
             | RETURN exp ';'                           {$$=newStmtNode(ReturnK,$1,$2);}
           ;

breakStmt  : BREAK ';'                                 {$$=newStmtNode(BreakK,$1);}
           ;

exp        : mutable assignop exp                {$$=newExpNode(AssignK,$2,$1,$3);}
             | mutable INC                              {$$=newExpNode(AssignK,$2,$1);}
             | mutable DEC                              {$$=newExpNode(AssignK,$2,$1);}/*May need to change*/
             | simpleExp	{$$=$1;}
           ;

assignop  : '='		{$$=$1;}
            | ADDASS	{$$=$1;}
            | SUBASS	{$$=$1;}
            | MULASS	{$$=$1;}
            | DIVASS	{$$=$1;}
          ;

simpleExp  : simpleExp OR andExp                 {$$=newExpNode(OpK,$2,$1,$3);}/*May need to change*/
             | andExp	{$$=$1;}
           ;

andExp     : andExp AND unaryRelExp              {$$=newExpNode(OpK,$2,$1,$3);}/*May need to change*/
             | unaryRelExp	{$$=$1;}
           ;

unaryRelExp : NOT unaryRelExp                      {$$=newExpNode(OpK,$1,$2);}/*May need to change*/
              | relExp	{$$=$1;}
            ;

relExp     : minmaxExp relop minmaxExp          {$$ = newExpNode(OpK,$2,$1,$3);}
             | minmaxExp	{$$=$1;}
           ;

relop      : LEQ	{$$=$1;}
             | '<'	{$$=$1;}
             | '>'	{$$=$1;}
             | GEQ	{$$=$1;}
             | EQ	{$$=$1;}
             | NEQ	{$$=$1;}
           ;

minmaxExp  : minmaxExp minmaxop sumExp              {$$=newExpNode(OpK,$2,$1,$3);}
             | sumExp	{$$=$1;}
           ;

minmaxop   : MAX	{$$=$1;}
             | MIN	{$$=$1;}
           ;

sumExp     : sumExp sumop mulExp              {$$=newExpNode(OpK,$2,$1,$3);}
             | mulExp	{$$=$1;}
           ;

sumop      : '+'	{$$=$1;}
             | '-'	{$$=$1;}
           ;

mulExp     : mulExp mulop unaryExp           {$$=newExpNode(OpK,$2,$1,$3);}
             | unaryExp	{$$=$1;}
           ;

mulop      : '*'	{$$=$1;}
             | '/'	{$$=$1;}
             | '%'	{$$=$1;}
           ;

unaryExp   : unaryop unaryExp                   {$$=newExpNode(OpK,$1,$2);}
             | factor	{$$=$1;}
           ;

unaryop    : '-'                                     {$1->tokenclass=CHSIGN;$$=$1;}/*add more functionality*/
             | '*'                                      {$1->tokenclass=SIZEOF;$$=$1;}/*add more functionality*/
             | '?'	{$$=$1;}/*May need to change*/
           ;
	   ;
factor     : immutable	{$$=$1;}
             | mutable	{$$=$1;}
           ;

mutable    : ID                                       {$$=newExpNode(IdK,$1);$$->attr.name = $1->svalue;}
             | ID '[' exp ']'                          {$$=newExpNode(OpK,$2,NULL,$3);$$->child[0]=newExpNode(IdK,$1);$$->child[0]->attr.name = $1->svalue;}
           ;

immutable  : '(' exp ')'                            {$$=$2;}
             | call	{$$=$1;}
             | constant	{$$=$1;}
           ;

call       : ID '(' args ')'                        {$$=newExpNode(CallK,$1,$3);}
           ;

args       : argList	{$$=$1;}
             | /* empty */                                {$$ = NULL;}
           ;

argList    : argList ',' exp                       {addSibling($1,$3);}
             | exp	{$$=$1;}
           ;

constant   : NUMCONST                                      {$$=newExpNode(ConstantK,$1);$$->type=Integer;$$->attr.value=$1->nvalue;}
             | CHARCONST                                   {$$=newExpNode(ConstantK,$1);$$->type=Char;$$->attr.cvalue=$1->cvalue;}
             | STRINGCONST                                 {$$=newExpNode(ConstantK,$1); $$->size = $1->nvalue + 1; $$->isArray = true; $$->attr.name = $1->svalue ; setType($$,Char,false);}
             | BOOLCONST                                   {$$=newExpNode(ConstantK,$1);setType($$,Boolean,false);}
           ;


%%
char *largerTokens[LASTTERM+1]; // used in the utils.cpp file printing routines
// create a mapping from token class enum to a printable name in a
// way that makes it easy to keep the mapping straight.
void initTokenStrings()
{ largerTokens[ADDASS] = (char *)"+=";
largerTokens[AND] = (char *)"and";
largerTokens[BOOL] = (char *)"bool";
largerTokens[BOOLCONST] = (char *)"boolconst";
largerTokens[BREAK] = (char *)"break";
largerTokens[BY] = (char *)"by";
largerTokens[CHAR] = (char *)"char";
largerTokens[CHARCONST] = (char *)"charconst";
largerTokens[CHSIGN] = (char *)"chsign";
largerTokens[DEC] = (char *)"--";
largerTokens[DIVASS] = (char *)"/=";
largerTokens[DO] = (char *)"do";
largerTokens[ELSE] = (char *)"else";
largerTokens[EQ] = (char *)"==";
largerTokens[FOR] = (char *)"for";
largerTokens[GEQ] = (char *)">=";
largerTokens[ID] = (char *)"id";
largerTokens[IF] = (char *)"if";
largerTokens[INC] = (char *)"++";
largerTokens[INT] = (char *)"int";
largerTokens[LEQ] = (char *)"<=";
largerTokens[MAX] = (char *)":>:";
largerTokens[MIN] = (char *)":<:";
largerTokens[MULASS] = (char *)"*=";
largerTokens[NEQ] = (char *)"!=";
largerTokens[NOT] = (char *)"not";
largerTokens[NUMCONST] = (char *)"numconst";
largerTokens[OR] = (char *)"or";
largerTokens[RETURN] = (char *)"return";
largerTokens[SIZEOF] = (char *)"sizeof";
largerTokens[STATIC] = (char *)"static";
largerTokens[STRINGCONST] = (char *)"stringconst";
largerTokens[SUBASS] = (char *)"-=";
largerTokens[THEN] = (char *)"then";
largerTokens[TO] = (char *)"to";
largerTokens[WHILE] = (char *)"while";
largerTokens[LASTTERM] = (char *)"lastterm";
}
static char tokenBuffer[16];
char *tokenToStr(int type)
{
    if (type>LASTTERM) {
   return (char *)"UNKNOWN";
    }
    else if (type>256) {
   return largerTokens[type];
    }
    else if ((type<32) || (type>127)) {
   sprintf(tokenBuffer, "Token#%d", type);
    } else {
   tokenBuffer[0] = type;
   tokenBuffer[1] = '\0';
    }
    return tokenBuffer;
}
void yyerror (const char *msg)
{
   cout << "Error: " <<  msg << endl;
}

int main(int argc, char **argv) {
   // declare some vars:
   initTokenStrings();
   int option, index;
   char *file = NULL;
   extern FILE *yyin;
   // new stuff for w04:
   SymbolTable *symtab;
   symtab = new SymbolTable();
   symtab->debug(false);
   int globalOffset;
   //other junk:
   while ((option = getopt (argc, argv, "")) != -1)
      switch (option)
      {
      default:
         ;
      }
   if ( optind == argc ) yyparse();
   for (index = optind; index < argc; index++)
   {
      yyin = fopen (argv[index], "r");
      yyparse();
      fclose (yyin);
   }
   // int numErrors = 0;
   
   syntaxTree = semanticAnalysis( syntaxTree, symtab, globalOffset ); //construct syntax Tree! :)
   
   if(numErrors == 0){
      printTree(stdout, syntaxTree); // set to true, true for assignment 4
	}
   printf("Number of warnings: 0\n");
   printf("Number of errors: 0\n");
   return 0;
}



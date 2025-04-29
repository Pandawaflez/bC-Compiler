//codegen.cpp carsonG
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "treeNodes.h"
#include "treeUtils.h"
#include "symbolTable.h"
#include "emitcode.h"
#include "codegen.h"
#include "scanType.h"
#include "parser.tab.h"

extern int numErrors;
extern int numWarnings;
extern int yydebug;
extern TreeNode *syntaxTree;
extern char **largerTokens;
extern void initTokenStrings();

//globals:
FILE *code; // shared code file
static SymbolTable *globals;
static bool linenumFlag;
static int breakloc;
static int toffset;
#define OFPOFF 0
#define RETURNOFFSET -1

void codegenStatement(TreeNode *currnode);
void codegenDecl(TreeNode *currnode);
void codegenExpression(TreeNode *currnode);
void codegenHeader(char *srcFile);
void commentLineNum(TreeNode *currnode);
void codegenLibraryFun(TreeNode *currnode);
void codegenFun(TreeNode *currnode);
int offsetRegister(VarKind v);
void codegenInit(int initJump, int globalOffset);
void initGlobalArraySizes();
void initAGlobalSymbol(std::string sym, void *ptr);
void codegenGeneral(TreeNode *currnode);
void emitParams(TreeNode *currnode);

/*void codegen(FILE *codeIn,          // where the code should be written
             char *srcFile,         // name of file compiled
             TreeNode *syntaxTree,  // tree to process
	     SymbolTable *globalsIn,     // globals so function info can be found
	     int globalOffset,      // size of the global frame
             bool linenumFlagIn);   // comment with line numbers*/
void codegen(FILE *codeIn, char *srcFile, TreeNode *syntaxTree, SymbolTable *globalsIn, int globalOffset, bool linenumFlagIn){
   
   int initJump;
   code = codeIn;
   globals = globalsIn;
   linenumFlag = linenumFlagIn;
   breakloc = 0;
   
   initJump = emitSkip(1); // save a place for the jump to init
   codegenHeader(srcFile); // nice comments describing what is compiled
   codegenGeneral(syntaxTree); // general code generation including I/O library
   codegenInit(initJump, globalOffset); // generation of initialization for run
   
   return;
}

void codegenStatement(TreeNode *currnode){
   int currloc;
   int skiploc;
   int skiploc2;
   int savedToffset;
   switch (currnode->kind.stmt){
      case IfK:
         emitComment((char *)"IF");
         codegenExpression(currnode->child[0]);
         skiploc = emitSkip(1);
         emitComment((char *)"THEN");
         codegenGeneral(currnode->child[1]);
         if (currnode->child[2] != NULL) {
            skiploc2 = emitSkip(1);
         }
         backPatchAJumpToHere((char *)"JZR", AC, skiploc, (char *)"Jump around the THEN if false [backpatch]");
         if (currnode->child[2] != NULL) {
            emitComment((char *)"ELSE");
            codegenGeneral(currnode->child[2]);
            backPatchAJumpToHere(skiploc2, (char *)"Jump around the ELSE [backpatch]");
         }
         
         emitComment((char *)"END IF");
         break;
      case WhileK:
         // from slides:
         emitComment((char *)"WHILE");
         currloc = emitSkip(0); // return to here to do the test
         codegenExpression(currnode->child[0]); // test expression
         emitRM((char *)"JNZ", AC, 1, PC, (char *)"Jump to while part");
         emitComment((char *)"DO");
         skiploc = breakloc; // save the old break statement return point
         breakloc = emitSkip(1); // addr of instr that jumps to end of loop
         // this is also the backpatch point
         codegenGeneral(currnode->child[1]); // do body of loop
         emitGotoAbs(currloc, (char *)"go to beginning of loop");
         backPatchAJumpToHere(breakloc, (char *)"Jump past loop [backpatch]");
         // backpatch jump to end of loop
         breakloc = skiploc; // restore for break statement
         emitComment((char *)"END WHILE");
         break;
      case ForK: {
         int startoff;
         int stopoff;
         int stepoff;
         TreeNode *loopindex;
         savedToffset = toffset;
         toffset = currnode->size;
         emitComment((char *)"TOFF set:", toffset);
         emitComment((char *)"FOR");
         loopindex = currnode->child[0];
         if (loopindex == NULL) {
            printf("ERROR(codegen) loop index is null");
            break;
         }
         startoff = loopindex->offset;
         stopoff = startoff-1;
         stepoff = startoff-2;
         // ranges:
         if (currnode->child[1] == NULL) {
            printf("ERROR(codegen) no range in loop");
            break;
         } else {
            TreeNode *rangeNode = currnode->child[1];
            codegenExpression(rangeNode->child[0]);
            emitRM((char *)"ST", AC, startoff, FP, (char *)"save starting value in index variable");
            codegenExpression(rangeNode->child[1]);
            emitRM((char *)"ST", AC, stopoff, FP, (char *)"save stop value");
            if (rangeNode->child[2] != NULL) {
               codegenExpression(rangeNode->child[2]);
            } else {
               emitRM((char *)"LDC", AC, 1, 6, (char *)"default increment by 1");
            }
            emitRM((char *)"ST", AC, stepoff, FP, (char *)"save step value");
         }
         currloc = emitSkip(0); // return here to do the test
         emitRM((char *)"LD", AC1, startoff, FP, (char *)"loop index");
         emitRM((char *)"LD", AC2, stopoff, FP, (char *)"stop value");
         emitRM((char *)"LD", AC, stepoff, FP, (char *)"step value");
         emitRO((char *)"SLT", 3, 4, 5, (char *)"Op <");
         emitRM((char *)"JNZ", 3, 1, 7, (char *)"Jump to loop body");
         skiploc = breakloc;
         breakloc = emitSkip(1);
         if (currnode->child[2] == NULL) {
            printf("ERROR(codegen) compound for statement empty\n");
            break;
         }
         codegenGeneral(currnode->child[2]);
         emitComment((char *)"Bottom of loop increment and jump");
         emitRM((char *)"LD", AC, startoff, FP, (char *)"Load index");
         emitRM((char *)"LD", AC2, stepoff, FP, (char *)"Load step");
         emitRO((char *)"ADD", AC, AC, AC2, (char *)"increment");
         emitRM((char *)"ST", AC, startoff, FP, (char *)"store back to index");
         emitGotoAbs(currloc, (char *)"go to beginning of loop");
         backPatchAJumpToHere(breakloc, (char *)"Jump past loop [backpatch]");
         breakloc = skiploc;
         emitComment((char *)"END LOOP");
         break;
      }
      case CompoundK:
         // Copied from slides:
         savedToffset = toffset;
         toffset = currnode->size; // recover the end of activation record
         emitComment((char *)"COMPOUND");
         emitComment((char *)"TOFF set:", toffset);
         codegenGeneral(currnode->child[0]); // process inits
         emitComment((char *)"Compound Body");
         codegenGeneral(currnode->child[1]); // process body
         toffset = savedToffset;
         emitComment((char *)"TOFF set:", toffset);
         emitComment((char *)"END COMPOUND");
         break;
      case ReturnK:
         emitComment((char *)"RETURN");
         if (currnode->child[0] != NULL) {
            codegenExpression(currnode->child[0]);
            emitRM((char *)"LDA", 2, 0, AC, (char *)"Copy result to return register");
         }
         emitRM((char *)"LD", AC, -1, FP, (char *)"Load return address");
         emitRM((char *)"LD", FP, GP, FP, (char *)"Adjust fp");
         emitGoto(GP, AC, (char *)"Return");
         break;
      case BreakK:
         emitComment((char *)"BREAK");
         emitGotoAbs(breakloc, (char *)"break");
         break;
      case RangeK:
         break;
      /*default:
         break;*/
   }
}

void codegenExpression(TreeNode *currnode){
   
   commentLineNum(currnode);
   int offReg;
   
   switch (currnode->kind.exp) {
      case AssignK:{
         TreeNode* lhs = currnode->child[0]; //left
         TreeNode* rhs = currnode->child[1]; //right
         if (lhs->attr.op == '[') { //if array
            lhs->isArray = true;
            TreeNode *var = lhs->child[0], *index = lhs->child[1];
            offReg = offsetRegister(var->varKind);

            if (var == NULL) {
               printf("ERROR(codegenExpression) var is NULL\n");
               break;
            }
            if (index == NULL) {
               printf("ERROR(codegenExpression) var is NULL\n");
               break;
            }

            codegenExpression(index);

            if (rhs != NULL) {
               emitRM((char *)"ST", AC, toffset, FP, (char *)"Push index");
               toffset--;
               emitComment((char *)"TOFF dec:", toffset);
               codegenExpression(rhs);
               toffset++;
               emitComment((char *)"TOFF inc:", toffset);
               emitRM((char *)"LD", AC1, toffset, FP, (char *)"Pop index");
            }
            
            if (var->varKind == Parameter) {
               emitRM((char *)"LD", AC2, var->offset, FP, (char *)"Load address of base of array", var->attr.name);
            } else if (var->varKind == Local) {
               emitRM((char *)"LDA", AC2, var->offset, FP, (char *)"Load address of base of array", var->attr.name);
            } else if (var->varKind == LocalStatic || var->varKind == Global) {
               emitRM((char *)"LDA", AC2, var->offset, GP, (char *)"Load address of base of array", var->attr.name);
            }
            
            int op = currnode->attr.op;

            if (op == INC || op == DEC) {
               emitRO((char *)"SUB", AC2, AC2, AC, (char *)"Compute offset of value");
            } else {
               emitRO((char *)"SUB", AC2, AC2, AC1, (char *)"Compute offset of value");
            }
            
            switch(op) {
               case INC:
                  emitRM((char *)"LD", AC, 0, 5, (char *)"load lhs variable", var->attr.name);
                  emitRM((char *)"LDA", AC, 1, AC, (char *)"increment value of", var->attr.name);
                  emitRM((char *)"ST", AC, 0, AC2, (char *)"Store variable", var->attr.name);
                  break;

               case DEC:
                  emitRM((char *)"LD", AC, 0, 5, (char *)"load lhs variable", var->attr.name);
                  emitRM((char *)"LDA", AC, -1, AC, (char *)"decrement value of", var->attr.name);
                  emitRM((char *)"ST", AC, 0, AC2, (char *)"Store variable", var->attr.name);
                  break;

               case ADDASS:
                  emitRM((char *)"LD", AC1, 0, 5, (char *)"load lhs variable", var->attr.name);
                  emitRO((char *)"ADD", AC, AC1, AC, (char *)"op +=");
                  emitRM((char *)"ST", AC, 0, 5, (char *)"Store variable", var->attr.name);
                  break;

               case SUBASS:
                  emitRM((char *)"LD", AC1, 0, 5, (char *)"load lhs variable", var->attr.name);
                  emitRO((char *)"SUB", AC, AC1, AC, (char *)"op -=");
                  emitRM((char *)"ST", AC, 0, 5, (char *)"Store variable", var->attr.name);
                  break;

               case DIVASS:
                  emitRM((char *)"LD", AC1, 0, 5, (char *)"load lhs variable", var->attr.name);
                  emitRO((char *)"DIV", AC, AC1, AC, (char *)"op /=");
                  emitRM((char *)"ST", AC, 0, 5, (char *)"Store variable", var->attr.name);
                  break;

               case MULASS:
                  emitRM((char *)"LD", AC1, 0, 5, (char *)"load lhs variable", var->attr.name);
                  emitRO((char *)"MUL", AC, AC1, AC, (char *)"op *=");
                  emitRM((char *)"ST", AC, 0, 5, (char *)"Store variable", var->attr.name);
                  break;

               default:
                  emitRM((char *)"ST", AC, 0, 5, (char *)"Store variable", var->attr.name);
                  break;
               }
            } else {
               offReg = offsetRegister(lhs->varKind);
               if (rhs) {
                  codegenExpression(rhs);
               }
               switch (currnode->attr.op) {
                  case ADDASS:
                     emitRM((char *)"LD", AC1, lhs->offset, offReg, (char *)"load lhs variable", lhs->attr.name);
                     emitRO((char *)"ADD", AC, AC1, AC, (char *)"op +=");
                     emitRM((char *)"ST", AC, lhs->offset, offReg, (char *)"Store variable", lhs->attr.name);
                     break;
                  case SUBASS:
                     emitRM((char *)"LD", AC1, lhs->offset, offReg, (char *)"load lhs variable", lhs->attr.name);
                     emitRO((char *)"SUB", AC, AC1, AC, (char *)"op -=");
                     emitRM((char *)"ST", AC, lhs->offset, offReg, (char *)"Store variable", lhs->attr.name);
                     break;
                  
                  case DIVASS:
                     emitRM((char *)"LD", AC1, lhs->offset, offReg, (char *)"load lhs variable", lhs->attr.name);
                     emitRO((char *)"DIV", AC, AC1, AC, (char *)"op /=");
                     emitRM((char *)"ST", AC, lhs->offset, offReg, (char *)"Store variable", lhs->attr.name);
                     break;

                  case MULASS:
                     emitRM((char *)"LD", AC1, lhs->offset, offReg, (char *)"load lhs variable", lhs->attr.name);
                     emitRO((char *)"MUL", AC, AC1, AC, (char *)"op *=");
                     emitRM((char *)"ST", AC, lhs->offset, offReg, (char *)"Store variable", lhs->attr.name);
                     break;

                  case '=':
                     emitRM((char *)"ST", AC, lhs->offset, offReg, (char *)"Store variable", lhs->attr.name);
                     break;

                  case DEC:
                     emitRM((char *)"LD", AC, lhs->offset, offReg, (char *)"load lhs variable", lhs->attr.name);
                     emitRM((char *)"LDA", AC, -1, AC, (char *)"decrement value of", lhs->attr.name);
                     emitRM((char *)"ST", AC, lhs->offset, offReg, (char *)"Store variable", lhs->attr.name);
                     break;

                  case INC:
                     emitRM((char *)"LD", AC, lhs->offset, offReg, (char *)"load lhs variable", lhs->attr.name);
                     emitRM((char *)"LDA", AC, 1, AC, (char *)"increment value of", lhs->attr.name);
                     emitRM((char *)"ST", AC, lhs->offset, offReg, (char *)"Store variable", lhs->attr.name);
                     break;
                  default: // error?
                     break; 
               }
            }
            break;
         }
      case CallK: {
         emitComment((char *)"CALL", currnode->attr.name);
         
         TreeNode *funcNode = (TreeNode *)globals->lookup(currnode->attr.name);
         int savedToffset = toffset;
         int callLoc = funcNode->offset;

         emitRM((char *)"ST", FP, toffset, FP, (char *)"Store fp in ghost frame for", currnode->attr.name);
         toffset--;
         emitComment((char *)"TOFF dec:", toffset);
         toffset--;
         emitComment((char *)"TOFF dec:", toffset);

         emitParams(currnode->child[0]);

         emitComment((char *)"Param end", currnode->attr.name);

         emitRM((char *)"LDA", FP, savedToffset, FP, (char *)"Ghost frame becomes new active frame");
         emitRM((char *)"LDA", AC, FP, 7, (char *)"Return address in ac");
         emitRMAbs((char *)"JMP", PC, callLoc, (char *)"CALL", currnode->attr.name);
         emitRM((char *)"LDA", AC, 0, 2, (char *)"Save the result in ac");

         emitComment((char *)"Call end", currnode->attr.name);
         toffset = savedToffset;

         emitComment((char *)"TOFF set:", toffset);

         break;
      }
      case ConstantK:
         if ( currnode->type == Char ){
            if (currnode->isArray) {
               emitStrLit(currnode->offset, currnode->attr.name);
               emitRM((char *)"LDA", AC, currnode->offset, 0, (char *)"Load address of char array");
            } else {
               emitRM((char *)"LDC", AC, int(currnode->attr.cvalue), AC3, (char *)"Load char constant");
            }
         } else if ( currnode->type == Boolean ) {
            emitRM((char *)"LDC", AC, currnode->attr.value, AC3, (char *)"Load Boolean constant");
         } else if ( currnode->type == Integer ) {
            emitRM((char *)"LDC", AC, int(currnode->attr.value), AC3, (char *)"Load integer constant");
         }
         break;
      case IdK: //id's:
         if (currnode->isArray) { //handle arrays
            offReg = offsetRegister(currnode->varKind);
            if (currnode->varKind == Parameter) { // handle params
               emitRM((char *)"LD", AC, currnode->offset, offReg, (char *)"Load address of base of array", currnode->attr.name);
            } else { //otherwise:
               emitRM((char *)"LDA", AC, currnode->offset, offReg, (char *)"Load address of base of array", currnode->attr.name);
            }
         } else { // variable:
            offReg = offsetRegister(currnode->varKind);
            emitRM((char *)"LD", AC, currnode->offset, offReg, (char *)"Load variable", currnode->attr.name);
         }
         break;
      case OpK:
         if (currnode->child[0]) {
            codegenExpression(currnode->child[0]);
         }
         // slides:
         if (currnode->child[1]) {
            emitRM((char *)"ST", AC, toffset, FP, (char *)"Push left side");
            toffset--; emitComment((char *)"TOFF dec:", toffset);
            codegenExpression(currnode->child[1]);
            toffset++; emitComment((char *)"TOFF inc:", toffset);
            emitRM((char *)"LD", AC1, toffset, FP, (char *)"Pop left into ac1");
            if (currnode->isArray) {
               emitRO((char *)"SUB", AC, AC1, AC, (char *)"compute location from index");
               emitRM((char *)"LD", AC, GP, AC, (char *)"Load array element");
            }
         }
         /*if (currnode->child[1]) {
            emitRM((char *)"ST", AC, toffset, FP, (char *)"Push left side");
            toffset--; emitComment((char *)"TOFF dec:", toffset);
            codegenExpression(currnode->child[1]);
            toffset++; emitComment((char *)"TOFF inc:", toffset);
            emitRM((char *)"LD", AC1, toffset, FP, (char *)"Pop left into ac1");
            // for arrays:
            if (currnode->isArray) {
               emitRO((char *)"SUB", AC, AC1, AC, (char *)"compute location from index");
               emitRM((char *)"LD", AC, GP, AC, (char *)"Load array element");
            }
         }*/
         switch(currnode->attr.op) {
            case '[':
               emitRO((char *)"SUB", AC, AC1, AC, (char *)"compute location from index");
               emitRM((char *)"LD", AC, GP, AC, (char *)"Load array element");
               break;
            case '+':
               emitRO((char *)"ADD", AC, AC1, AC, (char*)"Op +");
               break;
            case AND:
               emitRO((char *)"AND", AC, AC1, AC, (char*)"Op AND");
               break;
            case OR:
               emitRO((char *)"OR", AC, AC1, AC, (char*)"Op OR");
               break;
            case '-':
               emitRO((char *)"SUB", AC, AC1, AC, (char*)"Op -");
               break;
            case '*':
               emitRO((char *)"MUL", AC, AC1, AC, (char*)"Op *");
               break;
            case '/':
               emitRO((char *)"DIV", AC, AC1, AC, (char*)"Op /");
               break;
            case '%':
               emitRO((char *)"MOD", AC, AC1, AC, (char*)"Op %");
               break;
            case NEQ:
               emitRO((char *)"TNE", AC, AC1, AC, (char*)"Op !=");
               break;
            case EQ:
               emitRO((char *)"TEQ", AC, AC1, AC, (char*)"Op ==");
               break;
            case GEQ:
               emitRO((char *)"TGE", AC, AC1, AC, (char*)"Op >=");
               break;
            case LEQ:
               emitRO((char *)"TLE", AC, AC1, AC, (char*)"Op <=");
               break;
            case '<':
               emitRO((char *)"TLT", AC, AC1, AC, (char*)"Op <");
               break;
            case '>':
               emitRO((char *)"TGT", AC, AC1, AC, (char*)"Op >");
               break;
            case MIN:
               emitRO((char *)"SWP", AC, AC1, AC, (char*)"Op :<:");
               break;
            case MAX:
               emitRO((char *)"SWP", AC1, AC, AC, (char*)"Op :>:");
               break;
            case NOT:
               emitRM((char *)"LDC", AC1, 1, 6, (char *)"Load 1");
               emitRO((char *)"XOR", AC, AC, AC1, (char *)"Op XOR to get logical not");
               break;
            case '?':
               emitRO((char *)"RND", AC, AC, 6, (char *)"Op ?");
               break;
            case SIZEOF:
               emitRM((char *)"LD", AC, 1, AC, (char *)"Load array size");
               break;
            case CHSIGN:
               emitRO((char *)"NEG", AC, AC, AC, (char *)"Op unary -");
               break;
         }
         break;
   }
}

void codegenDecl(TreeNode *currnode) {
   switch(currnode->kind.decl) {
      case VarK:
         // You have a LOT to do here!!!!!
         if (currnode->isArray) {
         switch (currnode->varKind) {
            case Local:
               emitRM((char *)"LDC", AC, currnode->size-1, 6, (char *)"load size of array", currnode->attr.name);
               emitRM((char *)"ST", AC, currnode->offset+1, offsetRegister(currnode->varKind), (char *)"save size of array", currnode->attr.name);
               break;
            case LocalStatic: 
               //something
               break;
            case Parameter:
               //something
               break;
            case Global:
               // do nothing here
               break;
            case None:
               // Error Condition
               break;
            }
            // ARRAY VALUE initialization
            if (currnode->child[0]) {
               codegenExpression(currnode->child[0]);
               emitRM((char *)"LDA", AC1, currnode->offset, offsetRegister(currnode->varKind), (char *)"address of lhs");
               emitRM((char *)"LD", AC2, 1, AC, (char *)"size of rhs");
               emitRM((char *)"LD", AC3, 1, AC1, (char *)"size of lhs");
               emitRO((char *)"SWP", AC2, AC3, 6, (char *)"pick smallest size");
               emitRO((char *)"MOV", AC1, AC, AC2, (char *)"array op =");
            } else { // !currnode->isArray
            // SCALAR VALUE initialization
               if (currnode->child[0]) {
                  switch (currnode->varKind) {
                     case Local:
                     // compute rhs -> AC;
                     codegenExpression(currnode->child[0]);
                     // save it
                     emitRM((char *)"ST", AC, currnode->offset, FP, (char *)"Store variable", currnode->attr.name);
                     case LocalStatic: 
                        //break;
                        break;
                     case Parameter: 
                        break;
                     case Global:
                        // do nothing here
                        break;
                     case None:
                        ///Error condition!!!
                        break;
                  }
               }
            }
            break;
         } else {
            if ( currnode->child[0] ){
               switch( currnode->varKind ){
                  case Local:
                     codegenExpression(currnode->child[0]);
                     emitRM((char *)"ST", AC, currnode->offset, FP, (char *)"Store variable", currnode->attr.name);
                     break;
                  //make cases for local static
                  default:
                     break;
               }
            }
         }
         break;
      case FuncK:
         if (currnode->lineno == -1) { // These are the library functions we just added
            codegenLibraryFun(currnode);
         } else {
            codegenFun(currnode);
         }
         break;
      case ParamK:
         break;
   }
}

// Generate a header for our code
void codegenHeader(char *srcFile)
{
   emitComment((char *)"bC compiler version bC-2025");
   emitComment((char *)"File compiled: ", srcFile);
}

void codegenGeneral(TreeNode *currnode) { 
   while (currnode) {
      switch (currnode->nodekind) {
         case StmtK:
         codegenStatement(currnode);
         break;
      case ExpK:
         emitComment((char *)"EXPRESSION");
         codegenExpression(currnode);
         break;
      case DeclK:
         codegenDecl(currnode);
         break;
      }
      currnode = currnode->sibling;
   }
}

void codegenLibraryFun(TreeNode *currnode) { 
   emitComment((char *)"");
   emitComment((char *)"** ** ** ** ** ** ** ** ** ** ** **");
   emitComment((char *)"FUNCTION", currnode->attr.name);
   // remember where this function is
   currnode->offset = emitSkip(0);
   // Store return address
   emitRM((char *)"ST", AC, RETURNOFFSET, FP, (char *)"Store return address");
   
   // Next slides here
   if (strcmp(currnode->attr.name, (char *)"input")==0) {
      emitRO((char *)"IN", RT, RT, RT, (char *)"Grab int input");
   }
   else if (strcmp(currnode->attr.name, (char *)"inputb")==0) {
      emitRO((char *)"INB", RT, RT, RT, (char *)"Grab bool input");
   }
   else if (strcmp(currnode->attr.name, (char *)"inputc")==0) {
      emitRO((char *)"INC", RT, RT, RT, (char *)"Grab char input");
   }
   else if (strcmp(currnode->attr.name, (char *)"output")==0) {
      emitRM((char *)"LD", AC, -2, FP, (char *)"Load parameter");
      emitRO((char *)"OUT", AC, AC, AC, (char *)"Output integer");
   }
   else if (strcmp(currnode->attr.name, (char *)"outputb")==0) {
      emitRM((char *)"LD", AC, -2, FP, (char *)"Load parameter");
      emitRO((char *)"OUTB", AC, AC, AC, (char *)"Output bool");
   }else if (strcmp(currnode->attr.name, (char *)"outputc")==0) {
      emitRM((char *)"LD", AC, -2, FP, (char *)"Load parameter");
      emitRO((char *)"OUTC", AC, AC, AC, (char *)"Output char");
   }
   else if (strcmp(currnode->attr.name, (char *)"outnl")==0) {
      emitRO((char *)"OUTNL", AC, AC, AC, (char *)"Output a newline");
   }
   else {
      emitComment((char *)"ERROR(LINKER): No support for special function");
      emitComment(currnode->attr.name);
   }
   
   emitRM((char *)"LD", AC, RETURNOFFSET, FP, (char *)"Load return address");
   emitRM((char *)"LD", FP, OFPOFF, FP, (char *)"Adjust fp");
   emitGoto(0, AC, (char *)"Return");
   emitComment((char *)"END FUNCTION", currnode->attr.name);
}

void codegenFun(TreeNode *currnode){
   emitComment((char *)"");
   emitComment((char *)"** ** ** ** ** ** ** ** ** ** ** **");
   emitComment((char *)"FUNCTION", currnode->attr.name);
   toffset = currnode->size; // recover the end of activation record
   emitComment((char *)"TOFF set:", toffset);
   // IMPORTANT: For function nodes the offset is defined to be the position of the
   // function in the code space! This is accessible via the symbol table.
   // remember where this function is:
   currnode->offset = emitSkip(0); // offset holds the instruction address!!
   // Store return address
   emitRM((char *)"ST", AC, RETURNOFFSET, FP, (char *)"Store return address");
   // Generate code for the statements...
   codegenGeneral(currnode->child[1]);
   // In case there was no return statement
   // set return register to 0 and return
   emitComment((char *)"Add standard closing in case there is no return statement");
   emitRM((char *)"LDC", RT, 0, 6, (char *)"Set return value to 0");
   emitRM((char *)"LD", AC, RETURNOFFSET, FP, (char *)"Load return address");
   emitRM((char *)"LD", FP, OFPOFF, FP, (char *)"Adjust fp");
   emitGoto(0, AC, (char *)"Return");
   emitComment((char *)"END FUNCTION", currnode->attr.name);
}

int offsetRegister(VarKind v) {
   switch (v) {
      case Local: return FP;
      case Parameter: return FP;
      case Global: return GP;
      case LocalStatic: return GP;
      default:
         printf((char *)"ERROR(codegen): looking up offset register for a variable of type %d\n", v);
         return 666;
   }
}

void commentLineNum(TreeNode *currnode) {
   char buf[16];
   if (linenumFlag) {
      sprintf(buf, "%d", currnode->lineno);
      emitComment((char *)"Line: ", buf);
   }
}

void codegenInit(int initJump, int globalOffset)
{ 
   backPatchAJumpToHere(initJump, (char *)"Jump to init [backpatch]");
   emitComment((char *)"INIT");
   //OLD pre 4.6 TM emitRM((char *)"LD", GP, 0, 0, (char *)"Set the global pointer");
   emitRM((char *)"LDA", FP, globalOffset, GP, (char *)"set first frame at end of globals");
   emitRM((char *)"ST", FP, 0, FP, (char *)"store old fp (point to self)");
   initGlobalArraySizes();
   emitRM((char *)"LDA", AC, 1, PC, (char *)"Return address in ac");
   { // jump to main
      TreeNode *funcNode;
      funcNode = (TreeNode *)(globals->lookup((char *)"main"));
      if (funcNode) {
         emitGotoAbs(funcNode->offset, (char *)"Jump to main");
      } else {
         printf((char *)"ERROR(LINKER): Procedure main is not defined.\n");
         numErrors++;
      }
   }
   emitRO((char *)"HALT", 0, 0, 0, (char *)"DONE!");
   emitComment((char *)"END INIT");
}

void initGlobalArraySizes(){
   emitComment((char *)"INIT GLOBALS AND STATICS");
   globals->applyToAllGlobal(initAGlobalSymbol);
   emitComment((char *)"END INIT GLOBALS AND STATICS");
}

void initAGlobalSymbol(std::string sym, void *ptr)
{ // from slides:
   TreeNode *currnode;
   // printf("Symbol: %s\n", sym.c_str()); // dump the symbol table
   currnode = (TreeNode *)ptr;
   // printf("lineno: %d\n", currnode->lineno); // dump the symbol table
   if (currnode->lineno != -1) {
      if (currnode->isArray) {
         emitRM((char *)"LDC", AC, currnode->size-1, 6, (char *)"load size of array", currnode->attr.name);
         emitRM((char *)"ST", AC, currnode->offset+1, GP, (char *)"save size of array", currnode->attr.name);
      }
      if (currnode->kind.decl==VarK && (currnode->varKind == Global || currnode->varKind == LocalStatic)) {
         if (currnode->child[0]) {
            // compute rhs -> AC;
            codegenExpression(currnode->child[0]);
            // save it
            emitRM((char *)"ST", AC, currnode->offset, GP,
            (char *)"Store variable", currnode->attr.name);
         }
      }
   }
}

void emitParams(TreeNode *currnode) {
   int params = 1;
   char paramsStr[10];
   TreeNode *tmp = currnode;

   while (tmp != NULL) {
      snprintf(paramsStr, 10, "%d", params);
      emitComment((char *)"Param", paramsStr);
      codegenExpression(tmp);
      emitRM((char *)"ST", AC, toffset, FP, (char *)"Push parameter");
      toffset--;
      emitComment((char *)"TOFF dec:", toffset);
      params++;
      
      tmp = tmp->sibling;
   }

   return;
}

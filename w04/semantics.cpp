// Semantics.ccp by CG
#include "semantics.h"
#include "symbolTable.h"
#include "treeNodes.h"
#include "treeUtils.h"
#include "parser.tab.h"
//jgjlskdglksjs

// prototypes:
TreeNode* loadIOLib(TreeNode*);
void treeTraverse( TreeNode* , SymbolTable* );

// global variables:
static int goffset = 0;
static int foffset = 0;
static int newScope = 0;
static int varCounter = 0;

//functions:
TreeNode* loadIOLib(TreeNode *syntree){
   
   // declare a bunch of vars:
   TreeNode *input, *output, *param_output;
   TreeNode *inputb, *outputb, *param_outputb;
   TreeNode *inputc, *outputc, *param_outputc;
   TreeNode *outnl;
   
   ///////// Stuff from next slides:
   // slide 1:
   // 1:
   input = newDeclNode(FuncK, Integer); //1
   input->lineno = -1; // all are -1
   input->attr.name = strdup("input"); //We named the variables well
   input->type = Integer;
   // 2:
   inputb = newDeclNode(FuncK, Boolean); //2
   inputb->lineno = -1;
   inputb->attr.name = strdup("inputb");
   inputb->type = Boolean;
   // 3:
   inputc = newDeclNode(FuncK, Char); //3
   inputc->lineno = -1;
   inputc->attr.name = strdup("inputc");
   inputc->type = Char;
   // 4:
   param_output = newDeclNode(ParamK, Void); //4
   param_output->lineno = -1;
   param_output->attr.name = strdup("*dummy*");
   param_output->type = Integer;
   // 5:
   output = newDeclNode(FuncK, Void); //5
   output->lineno = -1; // all are -1
   output->attr.name = strdup("output"); //We named the variables well
   output->type = Void;
   output->child[0] = param_output;
   // 6:
   param_outputb = newDeclNode(ParamK, Void); //6
   param_outputb->lineno = -1;
   param_outputb->attr.name = strdup("*dummy*");
   param_outputb->type = Boolean;
   // 7:
   outputb = newDeclNode(FuncK, Void); //7
   outputb->lineno = -1; // all are -1
   outputb->attr.name = strdup("outputb");
   outputb->type = Void;
   outputb->child[0] = param_outputb;
   // 8:
   param_outputc = newDeclNode(ParamK, Void); //8
   param_outputc->lineno = -1;
   param_outputc->attr.name = strdup("*dummy*");
   param_outputc->type = Char;
   // 9:
   outputc = newDeclNode(FuncK, Void); //9
   outputc->lineno = -1; // all are -1
   outputc->attr.name = strdup("outputc");
   outputc->type = Void;
   outputc->child[0] = param_outputc;
   
   outnl = newDeclNode(FuncK, Void); //10
   outnl->lineno = -1;
   outnl->attr.name = strdup("outnl");
   outnl->type = Void;
   //outnl->child[0] = NULL;
   
   // link them and prefix the tree we are interested in traversing.
   // This will put the symbols in the symbol table.
   input->sibling = output;
   output->sibling = inputb;
   inputb->sibling = outputb;
   outputb->sibling = inputc;
   inputc->sibling = outputc;
   outputc->sibling = outnl;
   outnl->sibling = syntree; // add in the tree we are given
   
   return input;
   
}

TreeNode* semanticAnalysis(TreeNode *syntree, SymbolTable *symtabX, int &globalOffset ){
   //copied from slides:
   syntree = loadIOLib(syntree);
   treeTraverse(syntree, symtabX);
   //what do do now?
   // ...
   // set global offset:
   globalOffset = goffset;
   
   //return:
   return syntree;
}

void treeTraverse( TreeNode* current , SymbolTable* symtab ){
   //make sure there is a node:
   if (current == NULL) {
      return;
   }
   
   if ( current->nodekind != StmtK || current->kind.stmt != CompoundK ){
      newScope = 1;
   }
   
   // what type of node?
   if ( current->nodekind == DeclK ){ //Declarations:
      if ( current->kind.decl == FuncK ){ //FuncK
         newScope = 0;
         foffset = -2;
         symtab->insert( current->attr.name , current );
         symtab->enter(current->attr.name);
         treeTraverse(current->child[0], symtab);
         current->size = foffset;
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         current->varKind = Global;
         symtab->leave();
      } else if ( current->kind.decl == VarK ) {
         /*
         if (symtab->depth()==1) // This is a global variable since it is not in a function
         // Set the varKind to Global for VarK (Parameter for ParamK)
         current->offset = goffset;
         goffset -= current->size;
         Otherwise, if current->isStatic // This is a static variable
         // Set varKind to LocalStatic for VarK (Parameter for ParamK)
         current->offset = goffset;
         goffset -= current->size;
         //symtab->insertGlobal with a unique name. (Keep a static int variable and append it to the end of the
         name)
         Otherwise, treat it as normal
         // Set varKind to Local for VarK (Parameter for ParamK)
         current->offset = foffset;
         foffset -= current->size; 
         */
         // VarK:
         treeTraverse(current->child[0], symtab);
         symtab->insert( current->attr.name , current );
         if (symtab->depth()==1) {
            current->varKind = Global;
            current->offset = goffset;
            goffset -= current->size;
         } else if ( current->isStatic ) {
            current->varKind = LocalStatic;
            current->offset = goffset;
            goffset -= current->size;
            char *newName;
            newName = new char[strlen(current->attr.name)+10];
            snprintf(newName, strlen(current->attr.name)+10, "%s-%d", current->attr.name, ++varCounter);
            symtab->insertGlobal(newName, current);
            delete [] newName;
         } else {
            current->offset = foffset;
            foffset -= current->size; 
            current->varKind = Local;
         }
         if (current->isArray) {
            current->offset--;
         }
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         
      } else if ( current->kind.decl == ParamK ) {
         treeTraverse(current->child[0], symtab);
         symtab->insert( current->attr.name , current );
         current->isAssigned = true;
         if (symtab->depth() == 1) {
            current->varKind = Global;
            current->offset = goffset;
            goffset -= current->size;
         } else if (current->isStatic) {
            current->varKind = LocalStatic;
            current->offset = goffset;
            goffset -= current->size;
            char *newName;
            newName = new char[strlen(current->attr.name)+10];
            snprintf(newName, strlen(current->attr.name)+10, "%s-%d", current->attr.name, ++varCounter);
            symtab->insertGlobal(newName, current);
            delete [] newName;
         } else {
            current->varKind = Local;
            current->offset = foffset;
            foffset -= current->size;
         }
         current->varKind = Parameter;
         /*if (current->isArray) {
            current->offset--;
         }*/
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         //treeTraverse(current->sibling, symtab);
      }
   } 
   else if ( current->nodekind == ExpK ){ //Expressions: AssignK, CallK, ConstantK, IdK, OpK
      if        ( current->kind.exp == AssignK ) {
         // AssignK:
         treeTraverse(current->child[0], symtab);
         TreeNode* lookupNode = (TreeNode *) symtab->lookup(current->child[0]->attr.name);
         if (lookupNode == NULL) {
            // child not in symbol table :(
            current->type = current->child[0]->type;
            current->child[0]->isAssigned = true;
         } else {
            lookupNode->isAssigned = true;
            current->type = lookupNode->type;
         }
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         
      } else if ( current->kind.exp == CallK ) {
         // CallK:
         // Look up like for IdK and set type and size
         treeTraverse(current->child[0], symtab);
         // says to do this in the slides:
         TreeNode* tmp;
         if ((tmp = (TreeNode *)(symtab->lookup(current->attr.name)))) {
            current->type = tmp->type;
            //current->isStatic = tmp->isStatic;
            //current->isArray = tmp->isArray;
            current->size = tmp->size;
            current->varKind = tmp->varKind;
            current->offset = tmp->offset;
         }
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
      } else if ( current->kind.exp == ConstantK ) {
         // copied from slides:
         treeTraverse(current->child[0], symtab);
         if (current->type == Char && current->isArray) { // Deal with strings
            current->varKind = Global;
            current->offset = goffset - 1;
            //current->size = strlen(current->attr.name-2);
            goffset -= current->size;
         }
         //current->isStatic = false;
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
      } else if ( current->kind.exp == IdK ) { //ID
         // IdK:
         treeTraverse(current->child[0], symtab);
         TreeNode* tmp;
         // says to do this in the slides:
         if ((tmp = (TreeNode *)(symtab->lookup(current->attr.name)))) {
            current->type = tmp->type;
            current->isStatic = tmp->isStatic;
            current->isArray = tmp->isArray;
            current->size = tmp->size;
            current->varKind = tmp->varKind;
            current->offset = tmp->offset;
            current->isUsed = true;
            tmp->isUsed = true;
         } /*else {
            printf("No Node found by IdK\n");
         }*/
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
      } else if ( current->kind.exp == OpK ) {
         int op = current->attr.op;

         treeTraverse(current->child[0], symtab);
         if (op == EQ || op == NEQ || op == LEQ || op == GEQ || op == '<' || op == '>') {
            current->type = Boolean;
         } else if (op == SIZEOF) {
            current->type = Integer;
         } else if ( op == '+' || op == '-' || op == '?' || op == ADDASS || op == SUBASS || op == MULASS || op == DIVASS || op == DEC || op == INC ) {
            current->type = Integer;
         } else {
            TreeNode* lookupNode = (TreeNode*)symtab->lookup(current->child[0]->attr.name);
            if (lookupNode == NULL) {
               current->type = current->child[0]->type;
            } else {
               current->type = lookupNode->type;
            }
         }
         if (op == '[') {
            //current->isArray = true;
            current->type = current->child[0]->type;
         }
         
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         
      } else {
         //printf ("expression nodekind invalid \n");
      }
   }
   else if ( current->nodekind == StmtK ){ //Statements:
      /*
      symtab->enter((char *)"compoundStmt");
      treeTraverse(current->child[0], symtab); // process declarations
      // More stuff
      current->size = foffset;
      treeTraverse(current->child[1], symtab);
      // More stuff
      symtab->leave(); //end of processing of the compound statement
      //because you can throw away the scope.
      
      if(isCompound) {
         char *id = strdup("{");
         symtab->enter("NewScope from " + (std::string)id);
      }
      
      if(isCompound) {
         symtab->leave();
      }
      
      If newScope
      • Remember the current Offset
      • Traverse child[0]’s tree
      • current->size = foffset;
      • Traverse child[1]’s tree
      • Restore the current Offset
      • Otherwise
      • Traverse child[0]’s tree
      • current->size = foffset;
      • Traverse child[1]’s tree
      
      */
      if ( current->kind.stmt == CompoundK ){
         
         if (newScope) {
            symtab->enter((char*)"CompoundStatement");
            int tmp = foffset;
            treeTraverse(current->child[0], symtab);
            current->size = foffset;
            treeTraverse(current->child[1], symtab);
            treeTraverse(current->child[2], symtab);
            foffset = tmp;
            symtab->leave();
         } else {
            newScope = 1;
            treeTraverse(current->child[0], symtab);
            current->size = foffset;
            treeTraverse(current->child[1], symtab);
            treeTraverse(current->child[2], symtab);
         }
      } 
      else if ( current->kind.stmt == IfK ){
          if (newScope) {   
            symtab->enter((char *)"IfStmt");
            int offsetTemp = foffset;
            TreeNode* tempNode;
            treeTraverse(current->child[0], symtab);
            if (current->child[0]) {
               tempNode = (TreeNode *)symtab->lookup(current->child[0]->attr.name);
            }
            if (tempNode == NULL) {
               tempNode = current->child[0];
            }
            current->size = foffset;
            treeTraverse(current->child[1], symtab);
            treeTraverse(current->child[2], symtab);
            foffset = offsetTemp;
            symtab->leave();
         } else {
            newScope = 1;
            treeTraverse(current->child[0], symtab);
            current->size = foffset;
            treeTraverse(current->child[1], symtab);
            treeTraverse(current->child[2], symtab);
         }
         
         /*newScope = 1;
         treeTraverse(current->child[0], symtab);
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         //treeTraverse(current->sibling, symtab);*/
      }
      else if ( current->kind.stmt == ForK ){
         if (newScope) {   
            symtab->enter((char *)"ForStmt");
            int offsetTemp = foffset;
            treeTraverse(current->child[0], symtab);
            foffset -= 2;
            current->size = foffset;
            treeTraverse(current->child[1], symtab);
            treeTraverse(current->child[2], symtab);
            foffset = offsetTemp;
            symtab->leave();
         } else {
            newScope = 1;
            treeTraverse(current->child[0], symtab);
            current->size = foffset;
            treeTraverse(current->child[1], symtab);
            treeTraverse(current->child[2], symtab);
         }
      }
      else if ( current->kind.stmt == WhileK ){
         if (newScope) {   
            symtab->enter((char *)"WhileStmt");
            int offsetTemp = foffset;
            treeTraverse(current->child[0], symtab);
            //foffset -= 2;
            current->size = foffset;
            treeTraverse(current->child[1], symtab);
            treeTraverse(current->child[2], symtab);
            foffset = offsetTemp;
            symtab->leave();
         } else {
            newScope = 1;
            treeTraverse(current->child[0], symtab);
            current->size = foffset;
            treeTraverse(current->child[1], symtab);
            treeTraverse(current->child[2], symtab);
         }
         /*newScope = 1;
         symtab->enter((char *)"WhileStmt");
         int offsetTemp = foffset; // Remember the current Offset
         treeTraverse(current->child[0], symtab); // Traverse child[0]’s tree
         foffset-=2; // Make space for the for loop var
         current->size = foffset;
         treeTraverse(current->child[1], symtab); // Traverse child[1]’s tree
         treeTraverse(current->child[2], symtab); // Traverse child[2]’s tree
         foffset = offsetTemp; // Restore the current Offset
         symtab->leave(); //leave table
         //treeTraverse(current->sibling, symtab); //do siblings*/
      } 
      else if ( current->kind.stmt == ReturnK ){
         treeTraverse(current->child[0], symtab);
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         //treeTraverse(current->sibling, symtab);
      } 
      else if ( current->kind.stmt == BreakK ){
         treeTraverse(current->child[0], symtab);
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         //treeTraverse(current->sibling, symtab);
      } 
      else if ( current->kind.stmt == RangeK ){
         treeTraverse(current->child[0], symtab);
         treeTraverse(current->child[1], symtab);
         treeTraverse(current->child[2], symtab);
         //treeTraverse(current->sibling, symtab);
      } else {
         printf("Statement Kind not found\n");
      }
   } /*else {
      printf("Node type not known\n");
   }*/
   // check sibling:
   if (current->sibling) {
      treeTraverse(current->sibling, symtab);
   }
   
}

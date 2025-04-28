#include "treeUtils.h"
#include <string.h>

extern char *largerTokens[];

void showAllocation(FILE*, TreeNode*);
char* varKindToStr(int);

TreeNode *newTreeNode(TokenData *token, TreeNode *c0, TreeNode *c1, TreeNode *c2)
{
    TreeNode *newNode;
    newNode = new TreeNode;
    newNode->nodeNum += 1;
    newNode->child[0] = c0;
    newNode->child[1] = c1;
    newNode->child[2] = c2;
    newNode->sibling = NULL;
    newNode->lineno = (token ? token->linenum : -1);
    newNode->size = 1;
    newNode->varKind = Local;
    newNode->offset = 0;
    newNode->isArray = false;
    newNode->isStatic = false;
    newNode->isConst = false;
    // possibly add used and assigned
    //printf("Constructing Node");
    return newNode;
}

TreeNode *newDeclNode(DeclKind kind, ExpType type, TokenData *token, TreeNode *c0, TreeNode *c1, TreeNode *c2)
{
    TreeNode *newNode = newTreeNode(token, c0, c1, c2);
    newNode->attr.name = (token ? token->svalue : strdup("DUMMY"));
    newNode->type = type;
    newNode->nodekind = DeclK;
    newNode->kind.decl = kind;
    return newNode;
}

TreeNode *newStmtNode(StmtKind kind, TokenData *token, TreeNode *c0, TreeNode *c1, TreeNode *c2)
{
    TreeNode *newNode = newTreeNode(token, c0, c1, c2);
    newNode->varKind = None;
    newNode->nodekind = StmtK;
    newNode->kind.stmt = kind;
    return newNode;
}

TreeNode *newExpNode(ExpKind kind, TokenData *token, TreeNode *c0, TreeNode *c1, TreeNode *c2)
{
    TreeNode *newNode = newTreeNode(token, c0, c1, c2);
    newNode->attr.op = OpKind(token->tokenclass);
    newNode->type = UndefinedType;
    newNode->attr.name = (token ? token->svalue : strdup("DUMMY"));
    // newNode->ExpType = token->ExpType;
    newNode->nodekind = ExpK;
    newNode->kind.exp = kind;
    return newNode;
}

static void printSpaces(FILE *listing, int depth)
{
    for (int i = 0; i < depth; i++)
        fprintf(listing, ".   ");
}

char expressionTypeToStrBuffer[80];

char *expTypeStr(ExpType type, bool isarray, bool isstatic)
{
    char *typeName;
    switch (type)
    {
        case Void:
            typeName = (char *)"type void";
            break;
        case Integer:
            typeName = (char *)"type int";
            break;
        case Boolean:
            typeName = (char *)"type bool";
            break;
        case Char:
            typeName = (char *)"type char";
            break;
        case UndefinedType:
            typeName = (char *)"undefined type";
            break;
        default:
            typeName = (char *)"Do something here later";
            break;
    }

    sprintf(expressionTypeToStrBuffer, "%s%s%s",
            (isstatic ? "static " : ""),
            (isarray ? "array of " : ""),
            typeName);

    return strdup(expressionTypeToStrBuffer);
}

void printTreeNode(FILE *listing, TreeNode *tree)
{
    //printf("Printing A Tree Node\n");
    if (tree->nodekind == DeclK)
    {
        switch (tree->kind.decl)
        {
            case FuncK:
                fprintf(listing, "Func: %s", tree->attr.name);
                fprintf(listing, " returns %s", expTypeStr(tree->type, tree->isArray, tree->isStatic));
                showAllocation(listing, tree);
                break;

            case VarK:
                fprintf(listing, "Var: %s", tree->attr.name);
                fprintf(listing, " of %s", expTypeStr(tree->type, tree->isArray, tree->isStatic));
                showAllocation(listing, tree);
                break;

            case ParamK:
                fprintf(listing, "Parm: %s", tree->attr.name);
                fprintf(listing, " of %s", expTypeStr(tree->type, tree->isArray, tree->isStatic));
                showAllocation(listing, tree);
                break;

            default:
                fprintf(listing, "decl not found");
                break;
        }
    }
    else if (tree->nodekind == StmtK)
    {
        switch (tree->kind.stmt)
        {
            case CompoundK:
                fprintf(listing, "Compound");
                showAllocation(listing, tree);
                break;

            case IfK:
                fprintf(listing, "If");
                break;

            case WhileK:
                fprintf(listing, "While");
                break;

            case ForK:
                fprintf(listing, "For");
                showAllocation(listing, tree);
                break;

            case ReturnK:
                fprintf(listing, "Return");
                break;

            case BreakK:
                fprintf(listing, "Break");
                break;

            case RangeK:
                fprintf(listing, "Range");
                break;

            default:
                fprintf(listing, "statement not found");
                break;
        }
    }
    else if (tree->nodekind == ExpK)
    {
        switch (tree->kind.exp)
        {
            case AssignK:
                fprintf(listing, "Assign: %s", tokenToStr(tree->attr.op));
                fprintf(listing, " of %s", expTypeStr(tree->type, tree->isArray, tree->isStatic));
                break;

            case CallK:
                fprintf(listing, "Call: %s", tree->attr.name);
                fprintf(listing, " of %s", expTypeStr(tree->type, tree->isArray, tree->isStatic));
                // showAllocation(listing, tree);
                break;

            case ConstantK:
                switch (tree->type)
                {
                    case Char:
                        // Check for array
                        if (tree->isArray) {
                            fprintf(listing, "Const %s", tree->attr.name);
                            break;
                        } else {
                            fprintf(listing, "Const '%c'", tree->attr.cvalue);
                        }
                        break;

                    case Integer:
                        fprintf(listing, "Const %d", tree->attr.value);
                        break;

                    case Void:
                        fprintf(listing, "Const %s", tree->attr.name);
                        break;

                    case Boolean:
                        fprintf(listing, "Const %s", tree->attr.name);
                        break;

                    case UndefinedType:
                        fprintf(listing, "Const %s", tree->attr.name);
                        break;

                    default:
                        fprintf(listing, "Const %s", tree->attr.name);
                        break;
                }
                fprintf(listing, " of %s", expTypeStr(tree->type, tree->isArray , tree->isStatic));
                if ( tree->isArray ) showAllocation(listing, tree);
                break;

            case IdK:
                fprintf(listing, "Id: %s", tree->attr.name);
                fprintf(listing, " of %s", expTypeStr(tree->type, tree->isArray, tree->isStatic));
                showAllocation(listing, tree);
                break;

            case OpK:
                fprintf(listing, "Op: %s", tokenToStr(tree->attr.op));
                fprintf(listing, " of %s", expTypeStr(tree->type, tree->isArray, tree->isStatic));
                break;

            default:
                fprintf(listing, "exp not found");
                break;
        }
    }

    fprintf(listing, " [line: %d]", tree->lineno);
}

void printTreeRec(FILE *listing, int depth, int siblingCnt, TreeNode *tree)
{
    int childCnt;
    if (tree == NULL) return;
    if (tree != NULL)
    {
        // print self
        printTreeNode(listing, tree);
        fprintf(listing, "\n");

        // print children
        for (childCnt = 0; childCnt < MAXCHILDREN; childCnt++)
        {
            if (tree->child[childCnt])
            {
                printSpaces(listing, depth);
                fprintf(listing, "Child: %d  ", childCnt);
                printTreeRec(listing, depth + 1, 1, tree->child[childCnt]);
            }
        }
    }

    // print sibling
    tree = tree->sibling;
    if (tree != NULL)
    {
        if (depth)
        {
            printSpaces(listing, depth - 1);
            fprintf(listing, "Sibling: %d  ", siblingCnt);
        }
        printTreeRec(listing, depth, siblingCnt + 1, tree);
    }

    fflush(listing);
}

void printTree(FILE *listing, TreeNode *tree)
{
    if (tree == NULL)
    {
        printf("NULL tree\n");
        return;
    }
    printTreeRec(listing, 1, 1, tree);
}

char *varKindToStr(int kind)
{
    switch (kind)
    {
        case None:
            return (char *)"None";
        case Local:
            return (char *)"Local";
        case Global:
            return (char *)"Global";
        case Parameter:
            return (char *)"Parameter";
        case LocalStatic:
            return (char *)"LocalStatic";
        default:
            return (char *)"unknownVarKind";
    }
}

void showAllocation(FILE *out, TreeNode *theNode)
{
    fprintf(out, " [mem: %s loc: %d size: %d]", varKindToStr(theNode->varKind), theNode->offset, theNode->size);
}


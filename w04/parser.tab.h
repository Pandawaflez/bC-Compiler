/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    NOT = 258,
    AND = 259,
    OR = 260,
    GEQ = 261,
    ADDASS = 262,
    SUBASS = 263,
    MULASS = 264,
    DIVASS = 265,
    DEC = 266,
    INC = 267,
    NEQ = 268,
    EQ = 269,
    LEQ = 270,
    PRECOMPILER = 271,
    NUMCONST = 272,
    ERROR = 273,
    MIN = 274,
    MAX = 275,
    ID = 276,
    CHARCONST = 277,
    QUOTE = 278,
    UNDERBAR = 279,
    LETDIG = 280,
    INT = 281,
    CHAR = 282,
    BOOL = 283,
    STRINGCONST = 284,
    BREAK = 285,
    DO = 286,
    ELSE = 287,
    BY = 288,
    BOOLCONST = 289,
    RETURN = 290,
    STATIC = 291,
    TO = 292,
    WHILE = 293,
    IF = 294,
    THEN = 295,
    FOR = 296,
    CHSIGN = 297,
    SIZEOF = 298,
    LASTTERM = 299
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 61 "parser.y" /* yacc.c:1909  */

   TokenData *tokenData;
   TreeNode  *tree;
   ExpType   type;

#line 105 "parser.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */

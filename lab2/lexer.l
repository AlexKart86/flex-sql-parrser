%option yylineno caseless
%start QUOTE_STATE
RESERVED_WORD (UPDATE|SET|WHERE|DEFAULT|NOT|AND|OR)
QUOTE \"[^"]+\"
NEW_LINE [\n\r]*
SEPARATOR [ \t]*
ID [a-z_][a-z_0-9]*
PUNCT [\.\?!;:]
NUMBER [-]*[0-9]+
OPERATOR [+\-*/]
REL_OPERATOR (<>|<|>|<=|>=)
%{
  #include <stdarg.h>
  #include "parser.tab.h"
  #define KRED  "\x1B[31m"	
  #define KNRM  "\x1B[0m"  
  #define KGRN  "\x1B[32m" 
  int brackets_count = 0; 
  
  void show_error(char *msg, ...){
	va_list arg;
	va_start(arg, msg);
	fprintf(stderr, "%sError in line %d. %s", KRED, yylineno, KNRM);
	vfprintf(stderr, msg, arg);  
	fprintf(stderr, "\n");	
} 
  
%}
%%
{NEW_LINE}      ;
{QUOTE}			return STRING;
"UPDATE"		return UPDATE;
"SET"		    return SET;
"WHERE"			return WHERE;
"DEFAULT"		return DEFAULT;
"NOT"			return NOT;
"NULL"			return N_ULL;
"AND"			return AND;
"OR"		    return OR;
{NUMBER}		return NUMBER;
{ID} 			return ID;
{OPERATOR}		return OPERATOR;
{REL_OPERATOR}	return REL;
{SEPARATOR}		;
{PUNCT}			;
,				return ',';
=				return '=';
\)				{
	              --brackets_count;
				  if (brackets_count < 0)
				  {					  
					  show_error("Unclosed bracket");			  
					  return LEX_ERROR;
				  }
				  return ')';
				 
				}
\(				{
					return '(';
					++brackets_count;
				}
\"[^\"]*		{
					show_error("Unterminated string constant %s", yytext);
					return LEX_ERROR;
				}
. 				{ 
                   show_error("Unrecognized token %s", yytext);
				   return LEX_ERROR;
				}				   
				
%%

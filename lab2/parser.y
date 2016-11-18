%token UPDATE SET WHERE N_ULL DEFAULT NOT STRING NUMBER ID OPERATOR REL LEX_ERROR AND OR '=' '(' ')' 
%define parse.error verbose
%{
#define KRED  "\x1B[31m"	
#define KNRM  "\x1B[0m"  
#define KGRN  "\x1B[32m"	
%}

%%
root: UPDATE table SET assigment_list|
	  UPDATE table SET assigment_list WHERE condition|
	  UPDATE table SET assigment_list WHERE condition LEX_ERROR {yyerror("Analyze interrupted because of lex parser error");
	             YYERROR; }|
	  UPDATE table SET assigment_list LEX_ERROR {yyerror("Analyze interrupted because of lex parser error");
	             YYERROR; }|
	  LEX_ERROR {yyerror("Analyze interrupted because of lex parser error");
	             YYERROR;
				  };
assigment: field_name '=' value;
assigment_list: assigment|
				assigment_list ',' assigment;  
value: STRING|
	   number_expression|
	   N_ULL|
	   DEFAULT;
field_value: value | field_name; 	   
number_expression: number_factor|
				   '(' number_factor ')';
number_factor: 	NUMBER|
			   	NUMBER OPERATOR number_expression;
condition: 	condition_factor|
			'(' condition_factor ')';
rel_set: REL|
		 '=';	
//8. <фактор условия> ::= [NOT] <предикат> | [NOT] <предикат> <условный оператор> <условие>		 
condition_factor: 	predicate|
					NOT predicate|
					predicate rel_operator condition|									
					NOT predicate rel_operator condition;					
predicate: field_value rel_set field_value;
field_name: ID;
table: ID;
//Отстутствующее правило: в задании не был определен условный оператор.
//Определили его так:
//<условный оператор> ::= AND|OR
rel_operator: AND|
		      OR;
%%
#include <stdio.h>
#include <stdarg.h>
extern int yylineno;
extern char *yytext;
extern FILE *yyin;

#define YYPRINT(file, type, value) fprintf(file, "%d", value);

void yyerror(char* msg){
 printf("%sSyntax error line %d: %s %s. Token: '%s'\n", KRED, yylineno, KNRM, msg, yytext);
}




int main(int argc, char* argv[]) {
  //yydebug=1; 	// Включить для дебага
  ++argv, --argc;  /* skip over program name */
  if ( argc > 0 )
    yyin = fopen( argv[0], "r" );
  else
    yyin = stdin;
  // parse through the input until there is no more:
  int res = yyparse();
  if (!res){
	  printf("Analyze successfull\n");
  }
  return res;
}
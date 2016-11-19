/*Список терминальных символов
  вместо NULL использован символ N_ULL, поскольку NULL зарезервированное слово, и
  с лексемой NULL bison не компилировался
  Лексема LEX_ERROR - признак ошибки лексического анализатора
*/
%token UPDATE SET WHERE N_ULL DEFAULT NOT STRING NUMBER ID OPERATOR REL LEX_ERROR AND OR '=' '(' ')' 
/*Включаем расширенный вывод сообщений об ошибке*/
%define parse.error verbose
%{
/*Константы чтобы писать цветом в консоль*/	
#define KRED  "\x1B[31m"	
#define KNRM  "\x1B[0m"  
#define KGRN  "\x1B[32m"	
%}

%%
//Правило 1. UPDATE <название таблицы> SET <присваивание>[{,
//<присваивание>}...] [WHERE <условие>]
//учитываем здесь то, что может вернуться лексема LEX_ERROR
//сигнализирующая об ошибке лексического парсера 
root: UPDATE table SET assigment_list|
	  UPDATE table SET assigment_list WHERE condition|
	  UPDATE table SET assigment_list WHERE condition LEX_ERROR {yyerror("Analyze interrupted because of lex parser error");
	             YYERROR; }|
	  UPDATE table SET assigment_list LEX_ERROR {yyerror("Analyze interrupted because of lex parser error");
	             YYERROR; }|
	  LEX_ERROR {yyerror("Analyze interrupted because of lex parser error");
	             YYERROR;
				  };
//Правило 2	<присваивание> ::= <название поля>=<значение>			  
assigment: field_name '=' value;
//Часть правила 1, определяющее "список присваиваний": <присваивание>[{,<присваивание>}...]
assigment_list: assigment|
				assigment_list ',' assigment;  
//Правило 3. <значение> ::= <строка> | <числовое выражение> | NULL | DEFAULT				
value: STRING|
	   number_expression|
	   N_ULL|
	   DEFAULT;
//Правило 10. <значение поля> ::= <значение> | <название поля>	   
field_value: value | field_name; 	   
//Правило 4. <числовое выражение> ::= <числовой фактор> | (<числовой фактор>)
number_expression: number_factor|
				   '(' number_factor ')';
//Правило 5. <числовой фактор> ::= <число> | <число> <числовой оператор> <числовое выражение>				   
number_factor: 	NUMBER|
			   	NUMBER OPERATOR number_expression;
//Правило 7. <условие> ::= <фактор условия> | (<фактор условия>)			
condition: 	condition_factor|
			'(' condition_factor ')';
//Правило 11. <оператор сравнения> ::= =|<>|<|>|<=|>=			
//Учитываем тут опрератор = 
rel_set: REL|
		 '=';	
//8. <фактор условия> ::= [NOT] <предикат> | [NOT] <предикат> <условный оператор> <условие>		 
condition_factor: 	predicate|
					NOT predicate|
					predicate rel_operator condition|									
					NOT predicate rel_operator condition;					
//Правило 9. <предикат> ::= <значение поля> <оператор сравения> <значение поля>					
predicate: field_value rel_set field_value;
field_name: ID;
table: ID;
//Отстутствующее правило: в задании не было дано определение "условный оператор".
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
//Макрос, который печатает ход разбора в процессе отладки
#define YYPRINT(file, type, value) fprintf(file, "%d", value);

//Процедура вывода сообщения об ошибке
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
  //Вызываем основную процедуру разбора, она вернет 0 если разбор удачный 
  int res = yyparse();
  if (!res){
	  printf("%sAnalyze successfull%s\n", KGRN, KNRM);
  }
  return res;
}
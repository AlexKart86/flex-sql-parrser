/*
  Лексический анализатор отслеживает следующие типы ошибок:
    - Строковые константы с незакрытой кавычкой
    - Неизвестные токены
    - Незакрытые скобки	
*/
/*Дополнительные опции:
  yylineno - включает переменную yylineno в которую записывается текущая строчка
  caseless - парсинг без учета регистра */
%option yylineno caseless
/*Регулярное выражение для распознавания зарезервированных слов*/ 
RESERVED_WORD (UPDATE|SET|WHERE|NULL|DEFAULT|NOT|AND|OR)
/*Регулярное выражение для распознавания строковых констант*/
QUOTE \"[^"]+\"
/*Перевод на новую строку*/
NEW_LINE [\n\r]*
/*Разделители*/
SEPARATOR [ \t]*
/*Индентификаторы. правило 13 в задании */
ID [a-z_][a-z_0-9]*
/*Знаки препинания. Правило 19*/
PUNCT [\.\?!;:]
/*Число. Правило 16*/
NUMBER [-]*[0-9]+
/*Числовой оператор. Правило 6*/
OPERATOR [+\-*/]
/*Оператор сравнения. Правило 11. Тут исключен символ равенства, поскольку
  он используется в правиле №2 и может быть как оператором сравнения так и оператором присваивания
  поэтому равно отправляем как есть в выходной поток. Синтаксический анализатор будет разбираться   
*/
REL_OPERATOR (<>|<|>|<=|>=)
%{
  #include <stdarg.h>
  /*Константы для того, чтобы можно было писать красным цветом в консоле*/
  #define KRED  "\x1B[31m"	
  #define KNRM  "\x1B[0m"
  /*Переменная для подсчета количества открытых */
  int brackets_count = 0; 
  /*Функция для вывода сообщения об ошибке. Поддерживает форматированный ввод как printf*/
  void show_error(char *msg, ...){
	//Макросы для обработки переменного числа аргументов   
	va_list arg;
	va_start(arg, msg);
	//Выводим сообщение в stderr, с указанием номе
	fprintf(stderr, "%sLex Error in line %d. %s", KRED, yylineno, KNRM);
	vfprintf(stderr, msg, arg);  
	fprintf(stderr, "\n");
  }
%}
%%
{NEW_LINE}      printf("\n");
{QUOTE}			printf("STRING ");
{RESERVED_WORD}	printf("%s ", yytext);
{NUMBER}		printf("NUMBER ");
{ID} 			printf("ID ");
{OPERATOR}		printf("OPERATOR ");
{REL_OPERATOR}	printf("REL ");
{SEPARATOR}		;
{PUNCT}			;
,				printf(", ");
=				printf("= ");
\)				{
	              --brackets_count;
				  if (brackets_count < 0)				  
					  show_error("Unclosed bracket");			  
				  printf(") ");
				 
				}
\(				{
					printf("( ");
					++brackets_count;
				}
\"[^\"]*		show_error("Unterminated string constant %s", yytext);
. 				show_error("Unrecognized token %s", yytext);
				
%%
int main(int argc, char* argv[]) {
  ++argv, --argc;  /* skip over program name */
  if ( argc > 0 )
    yyin = fopen( argv[0], "r" );
  else
    yyin = stdin;

  yylex();
}
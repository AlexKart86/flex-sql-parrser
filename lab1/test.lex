%option yylineno caseless
%start QUOTE_STATE
RESERVED_WORD (UPDATE|SET|WHERE|NULL|DEFAULT|NOT)
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
  #define KRED  "\x1B[31m"	
  #define KNRM  "\x1B[0m"
  int brackets_count = 0; 
  void show_error(char *msg, ...){
	va_list arg;
	va_start(arg, msg);
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
\"[^\"\n]*$		show_error("Unterminated string constant %s", yytext);
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

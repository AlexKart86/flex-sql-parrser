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
. 				fprintf (stderr, "Error in line %d. Unrecognized token %s\n", yylineno, yytext);
%%
int main(int argc, char* argv[]) {
  ++argv, --argc;  /* skip over program name */
  if ( argc > 0 )
    yyin = fopen( argv[0], "r" );
  else
    yyin = stdin;

  yylex();
}

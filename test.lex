%start QUOTE_STATE
RESERVED_WORD (UPDATE|SET|WHERE|NULL|DEFAULT|NOT)
QUOTE \"[^"]+\"
NEW_LINE [\n\r]*
SEPARATOR [ \t]*
ID [a-z_][a-z_0-9]*
PUNCT [\.,\?!;:]
NUMBER [-]*[0-9]+
%{
   void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
   } 	
%}
%%
{NEW_LINE}      printf("\n");
{QUOTE}			printf("STRING ");
{RESERVED_WORD}	printf("%s ", yytext);
{NUMBER}		printf("NUMBER ");
{ID} 			printf("ID ");
{SEPARATOR}		;
=				printf("= ");
. 				{
					yyerror(yytext);
				}
%%
int main(int argc, char* argv[]) {
  ++argv, --argc;  /* skip over program name */
  if ( argc > 0 )
    yyin = fopen( argv[0], "r" );
  else
    yyin = stdin;

  yylex();
}
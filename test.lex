%start QUOTE_STATE
RESERVED_WORD (UPDATE|SET|WHERE|NULL|DEFAULT|NOT)
QUOTE \"
SEPARATOR (\t|\n|\s)*
ID [a-z_][a-z_0-9]*
PUNCT [\.,\?!;:]
%%
<QUOTE_STATE>.;
<QUOTE_STATE>{QUOTE} {
						printf("STRING\n");
						BEGIN 0;
					  }
{QUOTE}			BEGIN QUOTE_STATE;	
{RESERVED_WORD}	printf("%s\n", yytext);
{ID} 			printf("ID\n");
{SEPARATOR}		printf("SEPARATOR\n");
. 				;
\n 				;
%%
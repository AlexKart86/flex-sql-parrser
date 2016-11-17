%token UPDATE SET WHERE NULL DEFAULT NOT STRING NUMBER ID OPERATOR REL '=' '(' ')'


%%
root: UPDATE table SET assigment_list|
	  UPDATE table SET assigment_list WHERE condition;
assigment: field_name '=' value;
assigment_list: assigment|
				assigment_list ',' assigment;  
value: STRING|
	   number_expression|
	   NULL|
	   DEFAULT;
number_expression: number_factor|
				   '(' number_factor ')';
number_factor: 	NUMBER|
			   	NUMBER OPERATOR number_expression;
condition: 	condition_factor|
			'(' condition_factor ')';
condition_factor: 	predicate|
					NOT predicate|
					predicate REL condition|
					NOT predicate REL condition;					
predicate: value REL value;
field_name: ID;
table: ID;
		    	
%%
extern int yylineno;
extern char *yytext;
yyerror(char* msg){
 printf("%d: %s at '%s'\n", yylineno, msg, yytext);
}

int main(int argc, char* argv[]) {
  ++argv, --argc;  /* skip over program name */
  if ( argc > 0 )
    yyin = fopen( argv[0], "r" );
  else
    yyin = stdin;
  // parse through the input until there is no more:
  do {
		yyparse();
  } while (!feof(yyin));
  
}
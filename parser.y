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
				   '(' number ')';
				   
	   
%%
yyerror(char* msg){
 printf("%d: %s at '%s'\n", yylineno, msg, yytext);
}
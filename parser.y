%token UPDATE SET WHERE NULL DEFAULT NOT STRING NUMBER ID OPERATOR REL '='

%%
root: UPDATE table SET assigment_list|
	  UPDATE table WHERE condition;
assigment: field_name '=' value;
assigment_list: assigment|
				assigment_list ',' assigment;  
value: STRING|
	   number_expression|
	   NULL|
	   DEFAULT;
	   
%%

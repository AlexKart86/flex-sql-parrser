bison -vdt parser.y
flex lexer.l
gcc parser.tab.c lex.yy.c -lfl -o lab2.exe
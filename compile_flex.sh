flex -i test.lex
cc lex.yy.c -lfl
./a < test.txt > result.txt
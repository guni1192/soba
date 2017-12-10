CC = gcc


all: soba

soba.tab.c soba.tab.h:	soba.y
	bison -d soba.y

lex.yy.c: soba.l soba.tab.h
	flex soba.l

soba: lex.yy.c soba.tab.c soba.tab.h
	$(CC) -o ../bin/soba soba.tab.c lex.yy.c

clean:
	rm soba soba.tab.c lex.yy.c soba.tab.h

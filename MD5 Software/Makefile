CC = gcc -std=c99
CFLAGS = -Wall
LDFLAGS = -g

all: md5

md5: md5c.c md5_hash.c linkedList.c md5.h global.h linkedList.h
	$(CC) md5c.c md5_hash.c linkedList.c -o md5Test.exe $(CFLAGS) $(LDFLAGS)


clean: 
	rm -f *.o
	rm -f md5Test.exe

cleanw: 
	del  *.o
	del  md5Test.exe

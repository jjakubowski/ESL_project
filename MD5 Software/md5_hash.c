/* MDDRIVER.C - test driver for MD2, MD4 and MD5
*/
/* Copyright (C) 1990-2, RSA Data Security, Inc. Created 1990. All
rights reserved.
RSA Data Security, Inc. makes no representations concerning either
the merchantability of this software or the suitability of this
software for any particular purpose. It is provided "as is"
without express or implied warranty of any kind.
These notices must be retained in any copies of any part of this
documentation and/or software.
*/
/* The following makes MD default to MD5 if it has not already been
defined with C compiler flags.
*/
#ifndef MD5
#define MD5
#endif
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include "global.h"
#include "md5.h"
#include "linkedList.c"
/* Length of test block, number of test blocks.
*/
#define TEST_BLOCK_LEN 1000
#define TEST_BLOCK_COUNT 1000
static void MDString PROTO_LIST ((char *));
static void MDTimeTrial PROTO_LIST ((void));
static void MDTestSuite PROTO_LIST ((void));
static void MDFile PROTO_LIST ((char *));
static void MDFilter PROTO_LIST ((void));
static void MDPrint PROTO_LIST ((unsigned char [16]));
#define MD_CTX MD5_CTX
#define MDInit MD5Init
#define MDUpdate MD5Update
#define MDFinal MD5Final

/* Prints a message digest in hexadecimal.
*/
static void MDPrint (digest)
unsigned char digest[16];
{
	unsigned int i;
	for (i = 0; i < 16; i++)
	printf ("%02x", digest[i]);
}


linkedList* linkedList_generate(){
		linkedList* ptr;
		ptr = (linkedList*) malloc(sizeof(linkedList));
		ptr->head = NULL;
		ptr->tail = NULL;
		return ptr;
}

void linkedList_addToFront(linkedList* list,char data){
	node* ptr;
	ptr = (node*) malloc(sizeof(node));
	ptr->data = data;
	if(list->head == NULL) ptr->next = NULL;
	else ptr->next = list->head;
	list->head=ptr;
}


void linkedList_MD5(linkedList* list){
		node* curr;
		MD_CTX context;
		unsigned char digest[16];
		unsigned char buffer[1024];
		MDInit (&context);
		int len=0;
		if(list->head != NULL)
		{
			curr = list->head;
			while(curr != NULL)
			{
				buffer[len]=curr->data;
				if(len>1024){
					MDUpdate (&context, buffer, len); //update each time that we exceed the buffer
					len=0;
				}
				len++;
				curr = curr->next;
			}
		}
		MDUpdate (&context, buffer, len); //update the rest
		printf("Test trial \n");
		MDFinal (digest, &context);
		printf ("MD5 HASH KEY = ");
		MDPrint (digest);
		printf ("\n");
}


int main (argc, argv)
int argc;
char *argv[];
{
	clock_t start, end;
	double cpu_time_used;
	start = clock();
	linkedList* list = linkedList_generate();
	char *b=0x40000000;		// Load the programm into this address
	while(*b!=EOF){ 	//iterate until the end of the file
		linkedList_addToFront(list,*b); // Make a linked list with all the contents of the file
		b++;
	}
	linkedList_MD5(list);
	end = clock();
	cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
	printf("CPU time used (in secs.) :%.10f \n", cpu_time_used);fflush( stdout );
return (0);
}

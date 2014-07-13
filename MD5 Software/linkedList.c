#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct node{
	unsigned char data;
	struct node* next;
}node;

typedef struct{
	node* head;
	node* tail;
}linkedList;


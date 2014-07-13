#ifndef LINKEDLIST_H 
#define LINKEDLIST_H

#include <stdint.h> 

typedef struct node{
	intptr_t data; //signed integer type which is guaranteed to be able to hold an address
	struct node* next;
	//insert code here
}node;

typedef struct{
	//node* curr;
	node* head;
	//node* prev;
	node* tail;
	//insert code here
}linkedList;

//prototypes of the functions that have to be implemented
linkedList* linkedList_generate();
void linkedList_free(linkedList* list);
void linkedList_addToFront(linkedList* list,intptr_t data);
void linkedList_addToEnd(linkedList* list,intptr_t data);
void linkedList_RemoveFromFront(linkedList* list);
void linkedList_RemoveFromEnd(linkedList* list);
void linkedList_print(linkedList* list);//,PrintMode mode);
void linkedList_reverseList(linkedList* list);
void linkedList_deleteElement(linkedList* list,intptr_t number);

//--tests -- 
void testList();
#endif

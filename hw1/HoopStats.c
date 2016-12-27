#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// define struct of player
struct player{
	char* name;
	int jpg;
	struct player* next;
};



void sortList(struct player* head);
char* removeNL(char* myStr);



int main(int argc, char const *argv[])
{	

	// load and open file from command line
	FILE* myFilePtr;
	myFilePtr = fopen(argv[1], "r");

	// initialize char array to read file
	char buff[100];
	char done[] = "DONE\n";

	// make pointers to struct of player
	struct player* head;
	struct player* ptr = (struct player*) malloc(sizeof(struct player));

	// read in first line
	fgets(buff, 100, myFilePtr);

	// allocate space for 1st player's name
	ptr->name = (char*) malloc(sizeof(buff));

	// remove '\n' from end of string and assign string to name
	strcpy(ptr->name, removeNL(buff));

	// read in player number and score
	fgets(buff, 100, myFilePtr);
	int num = atoi(buff);
	fgets(buff, 100, myFilePtr);
	int score = atoi(buff);

	// store player JPG
	ptr->jpg = num - score;

	// point to next pointer
	ptr->next = NULL;

	// define head
	head = ptr;


	// loop through all remaining lines in txt file
	while(fgets(buff, 100, myFilePtr) != NULL){
		// check if DONE reached yet
		if(strcmp(buff, done) == 0) break;

		// allocate space for new player, his name, and store processed name
		struct player* curr = (struct player*) malloc(sizeof(struct player));
		curr->name = (char*) malloc(sizeof(buff));
		strcpy(curr->name, removeNL(buff));
		
		// read in player number and score
		fgets(buff, 100, myFilePtr);
		num = atoi(buff);
		fgets(buff, 100, myFilePtr);
		score = atoi(buff);

		// store player JPG
		curr->jpg = num - score;

		// point to next pointer
		curr->next = NULL;
		ptr->next = curr;

		// move 'ptr' to next pointer
		ptr = curr;
	}

	// sort linked list starting from head
	sortList(head);

	// loop through linked list to print out information and free memory
	ptr = head;
	while(ptr != NULL){
		printf("%s %d\n", ptr->name, ptr->jpg);
		struct player* temp = ptr;
		ptr = temp->next;
		free(temp->name);
		free(temp);
	}

	// close file
	fclose(myFilePtr);
	return(0);
}


// implementation of bubble sort for linked list
void sortList(struct player* head){
	struct player* countPtr;
	countPtr = head;
	int n = 0;

	// find total number of players in linked list
	while(countPtr != NULL){
		n++;
		countPtr = countPtr->next;
	}

	struct player* curr;
	
	// iterate for-loop for number of players
	for(int i = 0; i < n; i++){
		curr = head;
		
		// march through linked list and swap struct values
		// for adjacent players if jpg out of order
		while(curr->next != NULL){
			if(curr->jpg > curr->next->jpg){
				char* temp_name = curr->name;
				int temp_jpg = curr->jpg;

				curr->name = curr->next->name;
				curr->jpg = curr->next->jpg;

				curr->next->name = temp_name;
				curr->next->jpg = temp_jpg;
			}
			curr = curr->next;
		}
	}
}

// remove '\n' from end of string for name
char* removeNL(char* myStr){
	char* newStr = myStr;
	char* index = strchr(newStr, '\n');
	*index = '\0';

	return newStr;
}
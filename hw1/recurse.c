#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int f(int n);

int main(int argc, char *argv[]){
	int num = atoi(argv[1]);
	printf("%d\n", f(num));
}

int f(int n){
	if(n==0) return 1;
	return 3*(n+1) + f(n-1)-1;
}
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int palindromes(int n);

int main(int argc, char* argv[]){
	int myMax = atoi(argv[1]);
	int j = 10;

	while(myMax > 0){
		if(palindromes(j)==1){
			printf("%d ", j);
			myMax--;
		}
		j++;
	}
}

int palindromes(int n){
	if(n < 11) return 0;

	char myStr[256];
	sprintf(myStr, "%d", n);

	int dig = (int) ceil(log10((double) n));

	int i = 0; int j = dig-1;
	while(myStr[i]==myStr[j]){
		i++; j--;
		if(i>=j) return 1;
	}
	return 0;
}
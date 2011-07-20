#include <stdio.h>

main(){
	float x;
	int n=0;
	float sum = 0;
	while(!feof(stdin)) {
		scanf("%f", &x);
		if(feof(stdin)) break;
		fflush(stdin);
		n++;
		sum = sum + x;
	}
	printf("%.2f\n", sum/n);
}

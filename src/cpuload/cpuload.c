#include <stdio.h>
#include <time.h>
#define N 15000
main() {
	int i, j, result;
	clock_t t0 = clock();
	result = 0;
	for (i = 0; i < N; ++i)
		for (j = 0; j < i; ++j)
			result = (result % 456) + (i % (j + 1)) + (j % 567);
	clock_t t = clock() - t0;
	printf("result: %ld, clock: %ld\n", result, t);
}

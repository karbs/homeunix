#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void usage() { printf("Usage: pos [-p precision] [--pretty] {value | - } ...\n", stderr); exit(1); }

int compar(const void *x, const void *y) { return (*(float *)x - *(float *)y); }


main(int argc, char *argv[]) {
	float xx[100], yy[100], x, f = -1, b = -1;
	float prec = 10;
	int nx = 0, ny = 0;
	int i, j;
	int bSearch = 0, bDelta = 0, bPretty = 0;

	if (argc <= 1)
		usage();

	// Read values from arguments and (if arguments is "-") from stdin to yy.	
	char **last_argv = argv + argc - 1;
	for (; argv < last_argv; ++argv) {
		x = atof(argv[1]);
		if (x != 0) 
			yy[ny++] = floorf(x * 10) / 10;
		else if (strcmp(argv[1], "-") == 0)
			// read values from stdin
			while (scanf("%f", &x) == 1)
				yy[ny++] = floorf(x * 10) / 10;
		else if (strcmp(argv[1], "-d") == 0)
			bDelta = 1; // show search result as delta
		else if (strcmp(argv[1], "--pretty") == 0)
			bPretty = 1; // 
		else if (argv + 1 < last_argv) {
			if (strcmp(argv[1], "-p") == 0)
				prec = atof((++argv)[1]); // sets precision
			else if (strcmp(argv[1], "-f") == 0)
				f = floorf(atof((++argv)[1]) * 10) / 10, bSearch = 1; // sets forward
			else if (strcmp(argv[1], "-b") == 0)
				b = floorf(atof((++argv)[1]) * 10) / 10, bSearch = -1; // sets backward
		} else
			usage();
	}

	// Iterate given values from yy and accumulate result to xx.
	for (j = 0, nx = 0; j < ny; ++j) {
		x = yy[j];
		// delete nearest
		for (i = 0; i < nx; ++i)
			if ((xx[i] > 0) && (abs(xx[i] - abs(x)) < prec))
				xx[i] = -1;
		// add one
		if (x > 0)
			xx[nx++] = x;
	}

	// Filter only positive values to yy.
	for (i = 0, ny = 0; i < nx; ++i)
		if (xx[i] > 0)
			yy[ny++] = xx[i];

	// Sort the result.
	qsort(yy, ny, sizeof(float), compar);
	
	if (bSearch < 0) {
		for (i = ny - 1; i > 0; --i) if (yy[i] <= b - prec) break;
		if (!bPretty)
			printf("%g", bDelta ? yy[i] - b : yy[i]);
		else {
			if ((i + 1 >= ny) && (i - 2 >= 0)) printf(" %g ", yy[i - 2]);
			if (i - 1 >= 0) printf("%g ", yy[i - 1]);
			printf("<%g>", yy[i]);
			if (i + 1 < ny) printf(" %g ", yy[i + 1]);
			if ((i - 1 <= 0) && (i + 2 < ny)) printf(" %g ", yy[i + 2]);
		}
	} else if (bSearch > 0) {
		for (i = 0; i < ny - 1; ++i) if (yy[i] > f) break;
		if (!bPretty)
			printf("%g", bDelta ? yy[i] - f : yy[i]);
		else {
			if ((i + 1 >= ny) && (i - 2 >= 0)) printf(" %g ", yy[i - 2]);
			if (i - 1 >= 0) printf("%g ", yy[i - 1]);
			printf("<%g>", yy[i]);
			if (i + 1 < ny) printf(" %g ", yy[i + 1]);
			if ((i - 1 <= 0) && (i + 2 < ny)) printf(" %g ", yy[i + 2]);
		}
	} else {
		// Output the result.
		for (i = 0; i < ny; ++i) {
			if (i > 0)
				putchar(' ');
			printf("%g", yy[i]);
		}
	}

	putchar('\n');
}

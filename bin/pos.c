#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main(int argc, char *argv[]) {
	float xx[100], yy[100], x;
	float prec = 10;
	int nx = 0, ny = 0;
	int i, j;

	// Read values from arguments and (if arguments is "-") from stdin to yy.	
	char **last_argv = argv + argc - 1;
	for (; argv < last_argv; ++argv) {
		x = atof(argv[1]);
		if (x != 0) 
			yy[ny++] = x;
		else if (strcmp(argv[1], "-") == 0)
			while (scanf("%g", yy + ny++) == 1); // read values from stdin
		else if (argv + 1 < last_argv) {
			if (strcmp(argv[1], "-p") == 0)
				prec = atof((++argv)[1]); // sets precision
		} else {
			printf("Usage: pos [-p precision] {value | - } ...\n", stderr);
			return 1;
		}
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

	// Output the result.
	for (i = 0, j = 0; i < nx; ++i)
		if (xx[i] > 0)
			printf("%s%g", j++ > 0 ? " ": "", xx[i]);
	putchar('\n');
}

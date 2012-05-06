#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


// prints usage info
void usage() {
	fprintf(stderr, "Usage: pos [-p precision] [--pretty] {value | - } ...\n");
	exit(1);
}


// compatision function for using in qsort
int compar(const void *x, const void *y) { return (*(float *)x - *(float *)y); }

// returns minimum of two numbers
float _min(float a, float b) { return a < b ? a : b; }

// returns maximum of two numbers
float _max(float a, float b) { return a > b ? a : b; }

// returns absolute value of number, always not negative
float _abs(float x) {
	return x < 0 ? -x : x;
}


////////////////////////////////////////////////////////////////////////////////////////

main(int argc, char *argv[]) {
	float xx[1000], yy[1000], x, f = -1, b = -1, k, l, delta;
	float prec = 10;
	int nx = 0, ny = 0;
	int i, j, jmin, jmax;
	int bSearch = 0, bDelta = 0, bPretty = 0;
	float delta_range_width = 5;
	int pretty_count = 6;

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
		else if (strcmp(argv[1], "--pretty2") == 0)
			bPretty = 2; // 
		else if (argv + 1 < last_argv) {
			if (strcmp(argv[1], "-p") == 0)
				prec = atof((++argv)[1]); // sets precision
			if (strcmp(argv[1], "-w") == 0)
				delta_range_width = atof((++argv)[1]);
			if (strcmp(argv[1], "-n") == 0)
				pretty_count = atoi((++argv)[1]);
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
			if ((xx[i] > 0) && (_abs(xx[i] - _abs(x)) < prec))
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


	// If not searching then just output the result.
	if (!bSearch) {
		for (i = 0; i < ny; ++i) {
			if (i > 0)
				putchar(' ');
			printf("%g", yy[i]);
		}
		return 0;
	}


	/*
	printf("*** DUMP OF YY BEGIN ***\n");
	for (j = 0; j < ny - 1; ++j)
		printf("yy[%2d] = %g\n", j, yy[j]);
	printf("*** DUMP OF YY END ***\n");
	*/

	if (!ny)
		return 1;	


	if (bSearch < 0) {
		// search backward
		for (i = ny - 1; i > 0; --i)
			if (yy[i] < b)
				break;		
	} else {
		// search forward
		for (i = 0; i < ny - 1; ++i)
			if (yy[i] > f)
				break;
	}

	//printf("bSearch=%d, f=%g, b=%g, ny=%d, i=%d\n", bSearch, f, b, ny, i);


	float result = bDelta ? (bSearch < 0 ? yy[i] - b : yy[i] - f) : yy[i];
			
	
	// If not pretty output then just output found position.
	if (!bPretty) {
		printf("%g\n", result);
		return 0;
	}
	
	


	char out_left[100][10], out_right[100][10];
	int out_left_len = 0, out_right_len = 0;

	// place current value in right buffer
	sprintf(out_right[out_right_len++], "<%g>", yy[i]);
	

	// fill right buffer
	k = yy[i];
	jmin = i + 1;
	jmax = jmin + pretty_count;
	for (j = _max(0, jmin); (j >= 0) && (j < ny) && (j <= jmax); ++j) {
		l = yy[j];
		delta = _abs(k - l);
		//fprintf(stderr, "delta: %g\n", delta);
		//k = l;
		if (delta < delta_range_width)
			sprintf(out_right[out_right_len++], "+%g", delta);
		else
			sprintf(out_right[out_right_len++], " %g", l);
	}

	//if (j >= ny - 1)
	//	sprintf(out_right[out_right_len++], "END");
	

	// fill left buffer
	k = yy[i];
	jmax = i - 1;
	jmin = jmax - pretty_count;
	for (j = _min(ny - 1, jmax); (j >= 0) && (j < ny) && (j >= jmin); --j) {
		l = yy[j];
		delta = _abs(k - l);
		//k = l;
		if (delta < delta_range_width)
			sprintf(out_left[out_left_len++], "+%g", delta);
		else
			sprintf(out_left[out_left_len++], " %g", l);
	}

	//if (j <= 0)
	//	sprintf(out_left[out_left_len++], "BEG");


	// build main buffer
	char *out[200];
	int out_len = 0;

	// copy left buffer to main buffer (in reverse order)
	for (j = out_left_len - 1; j >= 0; --j)
		out[out_len++] = out_left[j];
	
	// store position of current value in main buffer
	i = out_len;
	
	// copy right buffer to main buffer
	for (j = 0; j < out_right_len; ++j)
		out[out_len++] = out_right[j];
	
	// calculate subset of main buffer to output	
	if (bSearch < 0) { 
		// if backward search then show "x[i-10] x[i-9] ... x[i-1]  <x[i]> x[i+1]"
		jmax = i + _min(pretty_count, 1);
		jmin = jmax - pretty_count;
		// if not enoth left elements then add more right elements
		if (jmin < 0)
			jmax += -jmin;
	} else {
		// if forward search then show "x[i-1] <x[i]> x[i+1] ... x[i+10]"
		jmin = i - _min(pretty_count, 1);
		jmax = jmin + pretty_count;
		// if not enoth right elements then add more left elements
		if (jmax > out_len - 1)
			jmin -= jmax - (out_len - 1);
	}
	
	jmin = _max(0, jmin);
	jmax = _min(out_len - 1, jmax);
	
	if (jmin > 0)
		printf("...  ");
	
	// output subset of main buffer separated by double space
	for (j = jmin; j <= jmax; ++j)
		printf("%s \xC2\xA0", out[j]);
		
	if (jmax < out_len - 1)
		printf("...  ");

	putchar('\n');
	

	if (bPretty == 2)
		printf("%g\n", result);
	
}

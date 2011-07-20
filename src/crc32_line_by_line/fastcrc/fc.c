/*
 * fc.c - A sample program for the use with fast CRC routines.
 * It calculates the traditional and POSIX CRC-32 of a file.
 *
 * Copyright 1999 G. Adam Stanislav.
 * All rights reserved.
 */
#include <stdio.h>
#include "fastcrc.h"

#define	BUFFERSIZE	(1024*8)

unsigned char buffer[BUFFERSIZE];

int main(int argc, char *argv[]) {
	FILE *file;
	unsigned int bytes, bytesinfile;
	crc_t ecrc = ecrcinit();
	crc_t pcrc = pcrcinit();

	if (argc > 2) {
		fprintf(stderr, "FC Usage: fc [file]\n");
		return 1;
	}

	if (argc == 2) {
		file = fopen(argv[1], "r");
		if (file == NULL) {
			fprintf(stderr, "FC: Can't open %s\n", argv[1]);
			return 2;
		}
	}
	else
		file = stdin;

	bytesinfile = 0;

	while (!feof(file)) {
		ecrc = ecrcpartial(ecrc,
			buffer,
			bytes = fread(buffer,
				sizeof(unsigned char),
				BUFFERSIZE,
				file));

		pcrc = pcrcpartial(pcrc,
			buffer,
			bytes);

		bytesinfile += bytes;
	}

	if (file != stdin)
		fclose(file);

	ecrc = ecrcfinish(ecrc);
	pcrc = pcrcfinish(pcrc, bytesinfile);

	printf("%s (%u):\n"
		"E-CRC-32 = 0x%08x (%u)\n"
		"P-CRC-32 = 0x%08x (%u)\n",
		file == stdin ? "<stdin>" : argv[1],
		bytesinfile,
		ecrc, ecrc,
		pcrc, pcrc);

	return 0;
}


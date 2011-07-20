#include <stdio.h>
#include <fastcrc.h>

crc_t sum(char *buf) {
	char c, *b = buf;
	crc_t crc = ecrcinit();
	while (c = *(b++))
		crc = ecrc(crc, c);	
	return ecrcfinish(crc);
}


#define MAXLEN 1000

main() {
	char buf[MAXLEN];
	buf[0] = 0;

	while (!feof(stdin)) {
		if (!fgets(buf, MAXLEN, stdin))
			break;
		crc_t s = sum(buf);
		printf("%10u\t%s", s, buf);
	}
	
	return 0;
}

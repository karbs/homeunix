#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>



int main(int argc, char **argv) {
	if (argc < 2) {
		fprintf(stderr, "Usage: fastsum file ...\n");
		return 1;
	}
	char **arg;
	char *filename;
	int fd;
	struct stat sb;
	int result;
	off_t size;
	unsigned char *buf = (char *)malloc(1000);
	off_t offset;
	//char *out = (char *)malloc(10000);
	//char *out_ptr;
	
	
	arg = argv;
	
	++arg;
	filename = *arg;
	//printf("Filename: %s\n", filename);
	fd = open(filename, O_RDONLY | O_NONBLOCK | O_DIRECT);
	if (fd == -1) {
		fprintf(stderr, "Error opening file %s\n", filename);
		fprintf(stderr, "   last errno=%i (%s)\n", errno, strerror(errno));
		return 1;
	}
	fstat(fd, &sb);
	size = sb.st_size;
	printf("%011u.", size);
	
	//buf[0] = buf[1] = buf[2] = buf[3] = 0;
	
	offset = 800;
	if (size < offset + 4)
		printf("00000000");
	else {
		lseek(fd, offset, SEEK_SET);
		if (4 != read(fd, buf, 4)) {
			fprintf(stderr, "Error reading 4 bytes from offset %d!\n", offset);
			return 1;
		}
		printf("%02X%02X%02X%02X", buf[0], buf[1], buf[2], buf[3]);
	}
	printf(".");
	offset = 10000;
	if (size < offset + 4)
		printf("00000000");
	else {
		lseek(fd, offset, SEEK_SET);
		if (4 != read(fd, buf, 4)) {
			fprintf(stderr, "Error reading 4 bytes from offset %d!\n", offset);
			return 1;
		}
		printf("%02X%02X%02X%02X", buf[0], buf[1], buf[2], buf[3]);
	}
	printf(".");
	offset = 50000;
	if (size < offset + 4)
		printf("00000000");
	else {
		lseek(fd, offset, SEEK_SET);
		if (4 != read(fd, buf, 4)) {
			fprintf(stderr, "Error reading 4 bytes from offset %d!\n", offset);
			return 1;
		}
		printf("%02X%02X%02X%02X", buf[0], buf[1], buf[2], buf[3]);
	}
	printf(".");
	offset = 1000000;
	if (size < offset + 4)
		printf("00000000");
	else {
		lseek(fd, offset, SEEK_SET);
		if (4 != read(fd, buf, 4)) {
			fprintf(stderr, "Error reading 4 bytes from offset %d!\n", offset);
			return 1;
		}
		printf("%02X%02X%02X%02X", buf[0], buf[1], buf[2], buf[3]);
	}


	
	printf(" %s\n", filename);
	
	close(fd);

	return 0;
}








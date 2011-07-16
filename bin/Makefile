programs = avg calc_mult calc_sum pos fastsum crc32_line_by_line

LDFLAGS = -lm 

all:
	gmake ${programs}

clean:
	rm -f ${programs} *.o

crc32_line_by_line: crc32_line_by_line.c
	gcc -o $@ ${CFLAGS} ${LDFLAGS} -L/usr/local/lib -lfcrc $<






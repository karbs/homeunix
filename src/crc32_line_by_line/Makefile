#CFLAGS = -L/usr/local/lib -lfcrc

CFLAGS += -Ifastcrc

crc32_line_by_line: crc32_line_by_line.c fastcrc/fastcrc.o
	${CC} -o $@ ${CFLAGS} ${LDFLAGS} $?

fastcrc/fastcrc.o:
	cd fastcrc && ${MAKE} fastcrc.o

pre-clean:
	rm -f fastcrc/*.o fastcrc/*.so fastcrc/fc


include ../src.mk






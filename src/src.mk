LDFLAGS = -lm 

CURDIR ?= ${.CURDIR}

.SHELL: path=/usr/local/bin/bash name=sh

all: ${programs}
	if [ -z "${programs}" ]; then ${MAKE} programs="`basename ${CURDIR}`"; fi

clean: pre-clean
	( \
		rm -f ${programs} *.o `basename ${CURDIR}`; \
		ls *.l 2>/dev/null && for i in *.l; do rm -f `basename $$i .l`.c; done || :\
	)

pre-clean:

install: ${programs} ${HOME}/bin
	if [ -z "${programs}" ]; then \
		${MAKE} install programs="`basename ${CURDIR}`"; \
	else \
		cp ${programs} ${HOME}/bin; \
	fi

uninstall deinstall:
	cd ${HOME}/bin && rm -f ${programs} `basename ${CURDIR}`

${HOME}/bin:
	mkdir ${HOME}/bin





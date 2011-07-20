dirs=xxx

all install uninstall deinstall clean:
	${MAKE} subdirs action="$@" dirs="`echo */Makefile | sed -r 's/\/Makefile//g'`"

subdirs: ${dirs}

${dirs}::
	cd $@ && ${MAKE} ${action}


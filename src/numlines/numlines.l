
%{
#include <stdio.h>
int n = 1;

char fmt[100];

void p() {
	printf(fmt, n++, yytext);
}

%}
%option 8bit noyywrap ecs meta-ecs align
%x text
%%

<INITIAL>\r?\n         p(); BEGIN(INITIAL);
<INITIAL>.             p(); BEGIN(text);


<text>\r?\n            ECHO; BEGIN(INITIAL);




%%


main(int argc, char **argv) {
	yyin = stdin;

	int size = 5;
	int p = 1, i;
	FILE *f;

	if ((argc > p) && (0 == strcmp("-h", argv[p]))) {
		fprintf(stderr, "Usage: numlines [size] [file]\n");
		return 1;
	}
	
	if ((argc > p) && (i = atoi(argv[p]))) {
		++p;
		size = i;
	}
	
	if (argc > p) {
		f = fopen(argv[p], "r");
		if (!f) {
			fprintf(stderr, "%s: Cannot open file\n", argv[p]);
			return 1;
		}
		yyin = f;
	}

	sprintf(fmt, "%%0%dd: %%s", size);
	
	yylex();
}

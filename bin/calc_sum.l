%{
#include <math.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <limits.h>

long sum = 0;
char buf[1000] = "";
char dirty = 0;

void out(char *delim) {
	if (!dirty)
		return;
	if (sum != 0){
		printf("%ld", sum);
		sum = 0;
	}
	printf("%s", delim);
	dirty = 0;
}

void value(char *x) {
	char *word;
	errno = 0;
	long n = strtol(x, &word, 10);
	if (errno) {
		out(" ");
		printf(" %s ", x);
	} else {
		sum += n;
		dirty = 1;
	}
}

void key(char *x) {
	if (!strcmp(buf, x))
		return;
	out("");
	printf("\n%s ", x);
	strcpy(buf, x);
}

%}

digit         [0-9]
letter        [a-zA-Z]
 
%%
^[^ \n]+		{ key(yytext); }
\n				{}
[ \t]+			{}
[^ \n\t]+		{ value(yytext); }
<<EOF>>			{ out("\n"); yyterminate(); }

%%
 
int yywrap(void){ return 1; }

int main(int argc, char **argv){
	++argv, --argc;
	if (argc > 0)
		yyin = fopen(argv[0], "r");
	else
		yyin = stdin;
	yylex();
}

%{
#include <math.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <limits.h>

long sum = 0;
char buf[1000] = "";
char buf2[1000] = "";
char dirty = 0;

#define value(x) printf("%s %s\n", x, buf)
#define key(x) strcpy(buf, x)

//void value(char *x){ printf("%s  %s\n", x, buf); }
//void key(char *x){ strcpy(buf,x); }

%}
digit         [0-9]
letter        [a-zA-Z]

%%

^[^ \n]+		{ key(yytext); }
\n				{}
[ \t]+			{}
[^ \n\t]+		{ value(yytext); }
<<EOF>>			{ printf("\n"); yyterminate(); }

%%

int yywrap(void){ return 1; }

int main(int argc, char **argv){
	++argv, --argc;
	if ( argc > 0 )
		yyin = fopen( argv[0], "r" );
	else
		yyin = stdin;
	yylex();
}

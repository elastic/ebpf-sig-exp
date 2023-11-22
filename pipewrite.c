#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SECRET	"MULUMULU"
#define IN	0
#define OUT	1

int
main(int argc, char *argv[])
{
	int pipes[2];
	pid_t pid;
	char buf[16];
	ssize_t n;
	int i, quiet;

	quiet = argc == 2 && !strcmp("-q", argv[1]);

	if (pipe(pipes) == -1)
		err(1, "pipe");

	pid = fork();
	switch (pid) {
	case -1:
		err(1, "fork");
		break;
	case 0:			/* child */
		n = read(pipes[IN], buf, sizeof(buf));
		switch (n) {
		case -1:
			err(1, "read");
		case 0:
			errx(1, "read EOF");
		default:
			if (!quiet) {
			    printf("read %zd bytes: ", n);
			    for (i = 0; i < n; i++)
				    putchar(buf[i]);
			    putchar('\n');
			}
			printf("DONE\n"); /* this is how we report success */
			exit(0);
		}
		break;
	default:		/* parent */
		n = write(pipes[OUT], SECRET, strlen(SECRET));
		errx(1, "parent not killed, written %zd bytes", n);
	}

	
	return (0);
}

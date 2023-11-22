#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <err.h>

#include <sys/wait.h>

int
main(void)
{
	pid_t pid;
	int st;

	pid = fork();
	switch (pid) {
	case -1:
		err(1, "fork");
	case 0:			/* child */
		printf("FORKED");
		exit(0);
	default:		/* parent */
		waitpid(pid, &st, 0);
		exit(0);	/* should have been killed! */
	}

	printf("finished\n");

	return (0);
}

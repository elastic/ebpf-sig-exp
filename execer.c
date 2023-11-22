#include <bsd/stdlib.h>
#include <unistd.h>
#include <err.h>

int
main(int argc, char *argv[])
{
	if (argc < 2)
		errx(1, "usage: %s binpath [arg..]", getprogname());
	execve(argv[1], argv + 1, NULL);

	return (0);		/* NOTREACHED */
}

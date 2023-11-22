#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage="filepath"

[[ $# -ne 1 || ( -e "$1" && ! -f "$1" ) ]] && usage
truncate -s0 "$1" || exit 1
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:do_linkat
     /curtask->parent->pid == '$$'/
     { signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
test -e "$1__LINK" && rm "$1__LINK"
if ln "$1" "$1__LINK"; then
	die "ln wasn't killed, check the probe!"
fi
[[ -e "$1__LINK" ]] && bad || good

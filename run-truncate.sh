#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage="filepath"

[[ $# -ne 1 || ( -e "$1" && ! -f "$1" ) ]] && usage
truncate -s0 "$1" || exit 1
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:do_sys_ftruncate
     /curtask->parent->pid == '$$'/
     { signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
echo "truncatemeplz" >> "$1" || exit 1
if truncate -s0 "$1"; then
	die "truncate wasn't killed, check the probe!"
fi
[[ -f "$1" && ! -s "$1" ]] && bad || good

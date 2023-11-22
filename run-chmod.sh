#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage="filepath"

[[ $# -ne 1 || ( -e "$1" && ! -f "$1" ) ]] && usage
truncate -s0 "$1" || exit 1
chmod 000 "$1" || exit 1
[[ $(stat -c "%a" "$1") = 0 ]] || exit 1
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:chmod_common
     /str(((struct path *)arg0)->dentry->d_name.name) == "'${1##*/}'"/
     { signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
if chmod 644 "$1"; then
	die "chmod wasn't killed, check the probe!"
fi
[[ $(stat -c "%a" "$1") != 0 ]] && bad || good

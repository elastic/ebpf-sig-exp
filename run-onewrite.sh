#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage="filepath"

case $(uname -m) in
x86_64)  Tp=__x64_sys_write;;
aarch64) Tp=__arm64_sys_write;;
*) echo unsupport arch $(uname -m); exit 1;;
esac
[[ $# -eq 1 ]] || usage
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:'"$Tp"' /comm == "onewrite"/
     {signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
if ./onewrite "$1"; then
	die "onewrite wasn't killed, check the probe!"
fi
[[ -s "$1" ]] && bad || good

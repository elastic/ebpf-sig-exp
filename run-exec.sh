#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage="filepath"

[[ $# -eq 1 ]] || usage
case $(uname -m) in
x86_64)  Tp=__x64_sys_execve;;
aarch64) Tp=__arm64_sys_execve;;
*) echo unsupport arch $(uname -m); exit 1;;
esac
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:'"$Tp"' /comm == "execer"/
     {signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
[[ -f "$1" ]] && rm "$1"
./execer ./onewrite "$1"
[[ -f "$1" ]] && bad || good

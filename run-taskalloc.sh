#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage=""

[[ $# -eq 0 ]] || usage
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:copy_process /comm == "forker"/
     {signal("SIGKILL")}' >/dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
truncate -s0 /tmp/forked
./forker > /tmp/forked
Ret=$?
[[ $Ret -eq 0 && $(cat /tmp/forked) == FORKED ]] && bad || good

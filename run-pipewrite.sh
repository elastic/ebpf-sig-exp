#!/usr/bin/env bash

source helpers.sh

Script=${0##*/}
Usage=""

[[ $# -eq 0 ]] || usage
sudo true || exit 1
sudo bpftrace --unsafe -e 'kprobe:pipe_write
      /comm == "pipewrite"/ {signal("SIGKILL")}' > /dev/null &
trap 'kill $(jobs -p)' EXIT
sleep 2
# -q prints DONE to stdout as we can't check exit code
[[ $(./pipewrite -q) == DONE ]] && bad || good

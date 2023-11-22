#!/usr/bin/env bash

Script=${0##*/}

function usage
{
   echo "usage: $Script [-abh] filepath"
   exit 1
}

Traceflag=a
function dotrace
{
	if [[ $Traceflag = a ]]; then
				echo DOING A
sudo bpftrace --unsafe -e 'kprobe:vfs_open 
 /str(((struct path *)arg0)->dentry->d_name.name) == "'${1##*/}'"/
 { signal("SIGKILL")}'
	elif [[ $Traceflag = b ]]; then
		echo DOING B
sudo bpftrace --unsafe -e 'kprobe:do_sys_openat2 
 /str(uptr(arg1)) == "'$1'"/ { signal("SIGKILL")}'
fi
}

while getopts abh Opt; do
	case "$Opt" in
	a) Traceflag=a;;
	b) Traceflag=b;;
	\?|h) usage
	esac
done
shift $(expr $OPTIND - 1)

[[ $# -eq 1 ]] || usage
truncate -s0 "$1" || exit 1
sudo true || exit 1
(set -m; dotrace $1 > /dev/null &)
trap 'sudo pkill -f bpftrace.*SIGKILL'  EXIT
sleep 2
Gotsig=false
trap 'Gotsig=true' SIGINT SIGTERM
until [[ -s "$1" || $Gotsig = true ]] || ! pgrep bpftrace > /dev/null; do
	./race-openwrite "$1"
done
if [[ -s "$1" ]]; then
	printf "open+write: cracked! check %s\n" "$1"
else
	printf "open+write: untouched, you probably SIGINTed me!\n"
fi
exit 0

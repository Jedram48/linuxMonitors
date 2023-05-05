#!/bin/bash

list=$(ls /proc | grep -E '^[0-9]+$')


printf "%-6s %-6s %-6s %-6s %-6s %-6s %-6s %-12s %-12s\n" "PID" "PPID" "STATE" "PGID" "SID" "TTY" "RSS" "RUN_PROC" "COMM"

for pid in $list
do
	stat=( `sed -E 's/(\([^\s)]+)\s([^)]+\))/\1_\2/g' /proc/$pid/stat 2>/dev/null` )

	pid=${stat[0]}
	comm=${stat[1]}
	state=${stat[2]}
	ppid=${stat[3]}
	pgid=${stat[4]}
	sid=${stat[5]}
	tty=${stat[6]}
	rss=${stat[23]}
	procs=( `ls /proc/$pid/fd/ 2>/dev/null | wc -l` )

	printf "%-6d %-6d %-6c %-6d %-6d %-6d %-6ld %-12d %-12s\n" $pid $ppid $state $pgid $sid $tty $rss $procs $comm
done


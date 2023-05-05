#!/bin/bash

function con_bytes {
	VALUE=$1
	BIGGIFIERS=( B KB MB GB )
	CURRENT_BIGGIFIER=0
	while [ $VALUE -gt 1000 ] ;do
		VALUE=$(($VALUE/1000))
		CURRENT_BIGGIFIER=$((CURRENT_BIGGIFIER+1))
	done
	echo "$VALUE${BIGGIFIERS[$CURRENT_BIGGIFIER]}"
}

	PREV_TOTAL=(0 0 0 0)
	PREV_IDLE=(0 0 0 0)

	rec=$(awk 'NR==3, NR==$NR {sum+=$2;} END{print sum}' /proc/net/dev)
	tra=$(awk 'NR==3, NR==$NR {sum+=$10;} END{print sum}' /proc/net/dev)


while :
do
	slp=1


	new_rec=$(awk 'NR==3, NR==$NR {sum+=$2;} END{print sum}' /proc/net/dev)
	new_tra=$(awk 'NR==3, NR==$NR {sum+=$10;} END{print sum}' /proc/net/dev)

	rec_speed=$(($new_rec-$rec))
	tra_speed=$(($new_tra-$tra))

	rec=$new_rec
	tra=$new_tra

	echo "Receiving trafic: `con_bytes $rec_speed`"
	echo "Transition trafic: `con_bytes $tra_speed`"
	echo ""

	for i in 0 1 2 3
	do
		cpu=$(grep "cpu$i" /proc/stat)
		IFS=' ' read -r -a array <<< "$cpu"
		idle=${array[4]}

		total=0
		for value in "${array[@]:1}"
		do
			total=$((total+value))
		done

		diff_idle=$(($idle-${PREV_IDLE[$i]}))
		diff_total=$(($total-${PREV_TOTAL[$i]}))
		usage=$(((1000*(diff_total-diff_idle)/diff_total+5)/10))

		mhz=$(grep -E "MHz" /proc/cpuinfo)
		clock_speed=(`echo $mhz | sed 's/\n/\n/g'`)

		echo -e "\r${array[0]}: $usage%		${clock_speed[3]} MHz"

		PREV_TOTAL[$i]="$total"
		PREV_IDLE[$i]="$idle"
	done
	echo ""

	echo "PC in run: "
	sec=$(awk '{print $1}' /proc/uptime)
	val=${sec%.*}
	time=( sec min hour )
	curr=0
	while [ $val -gt 60 ]
	do
		temp=$(($val/60))
		echo -n "$((val-60*temp)) ${time[$curr]}	"
		val=$temp
		curr=$(($curr+1))
	done
	echo "$val ${time[$curr]}"
	echo ""

	echo "$(grep "POWER_SUPPLY_CAPACITY=" /sys/class/power_supply/BAT0/uevent)%"
	echo ""

	echo "PC load: "
	echo "1min	5min	10min"
	echo "$(awk '{printf "%.0f",$1*100}' /proc/loadavg)%	 $(awk '{printf "%.0f",$2*100}' /proc/loadavg)% 	$(awk '{printf "%.0f",$3*100}' /proc/loadavg)%"
	echo ""

	memTotal=$(sed -n '1p' /proc/meminfo | awk '{print $2}')
	memAval=$(sed -n '3p' /proc/meminfo | awk '{print $2}')
	memUsage=$((memTotal-memAval))
	echo "Memory usage: $memUsage kB"


 	sleep $slp
 	echo "------------------------------------"

done



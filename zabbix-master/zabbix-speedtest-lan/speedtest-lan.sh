#!/usr/bin/env bash

set -e

CACHE_FILE=/tmp/speedtest-lan.log
LOCK_FILE=/tmp/speedtest-lan.lock

IPERF_NUMBER=1
IPERF_IP[0]="server-web"
IPERF_NAME[0]="Server Web"
IPERF_TR_DL[0]="10"
IPERF_TR_UL[0]="10"

run_speedtest() {
	# Lock
	if [ -e "$LOCK_FILE" ]
	then
		echo "A LAN speedtest is already running" >&2
		exit 2
	fi
	touch "$LOCK_FILE"

	#Invoke rm LOCK_FILE on exit
	trap "rm -rf $LOCK_FILE" EXIT HUP INT QUIT PIPE TERM

	#Variable declaration
	local output timestamp server_id server_sponsor country location ping download upload

	#Check if argument supplied to function, exec iperf3 command and save output
	if [ -z "$1" ]
	then
		exit 2
	else
		download=$(iperf3 -f m -c "$1" -R | grep sender | awk -F " " '{print $7}')
		upload=$(iperf3 -f m -c "$1" | grep sender | awk -F " " '{print $7}')
		#Average of 4 ping
		ping=$(ping -c 4 "$1" | tail -1| awk '{print $4}' | cut -d '/' -f 2)
		CACHE_FILE+="_$1"
	fi

	#Send value to CACHE_FILE
	{
		echo "Ping: $ping ms"
		echo "Download: $download Mbit/s"
		echo "Upload: $upload Mbit/s"
	} > "$CACHE_FILE"

	CACHE_FILE=/tmp/speedtest-lan.log

	# Make sure to remove the lock file (may be redundant)
	rm -rf "$LOCK_FILE"
}

display_help() {
	echo "Usage with this parameters"
	echo
	echo "   -l xxx                 Run the speedtest collector on the server with ip/address xxx"
	echo "   -a, --all              Run the speedtest collector on the all servers listed in array"
	echo "   -g, --get-all          Get all server on which run the speedtest with -a"
	echo "   -c, --cached           Get the result for the last speedtest"
	echo "   -u, --upload           Get the upload speed for the last speedtest"
	echo "   -d, --download         Get the download speed for the last speedtest"
	echo "   -p, --ping             Get the ping value for the last speedtest"
	echo "   -f, --force            Force delete of lock and run the speedtest collector"
	echo "   -h, --help             View this help"
	echo "   -[c|u|d|p] -l xxx      Get the result for the last speedtest on the server with address xxx"
	echo
}

check_cache_exist() {
	if [ ! -e "$1" ]
	then
		echo "Not yet runned the speedtest" >&2
		exit 2
	fi
}

if [ $# -eq 1 ]
then
	case "$1" in
		-f|--force)
			rm -rf "$LOCK_FILE"
			for (( c=0; c<$IPERF_NUMBER; c++ ))
			do  
				run_speedtest "${IPERF_IP[$c]}"
			done
			;;
		-a|--all)
			for (( c=0; c<$IPERF_NUMBER; c++ ))
			do  
				run_speedtest "${IPERF_IP[$c]}"
			done
			;;
		-g|--get-all)
			echo "{"
			echo "\"data\":["
			comma=""
			for (( c=0; c<$IPERF_NUMBER; c++ ))
			do  
				echo "    $comma{\"{#IPERFID}\":\"${IPERF_IP[$c]}\",\"{#IPERFNAME}\":\"${IPERF_NAME[$c]}\",\"{#IPERF_TR_DL}\":\"${IPERF_TR_DL[$c]}\",\"{#IPERF_TR_UL}\":\"${IPERF_TR_UL[$c]}\"}"
				comma=","
			done
			echo "]"
			echo "}"
			;;
		-h|--help)
			display_help
			;;
	esac
elif [ $# -eq 2 ]
then
	if [ $1 = "-l" ]
	then
		run_speedtest "$2"
	fi
elif [ $# -eq 3 ]
then
	if [ $2 = "-l" ]
	then
		case "$1" in
			-c|--cached)
				check_cache_exist "$CACHE_FILE"_"$3"
				cat "$CACHE_FILE"_"$3"
				;;
			-u|--upload)
				check_cache_exist "$CACHE_FILE"_"$3"
				awk '/Upload/ { print $2 }' "$CACHE_FILE"_"$3"
				;;
			-d|--download)
				check_cache_exist "$CACHE_FILE"_"$3"
				awk '/Download/ { print $2 }' "$CACHE_FILE"_"$3"
				;;
			-p|--ping)
				check_cache_exist "$CACHE_FILE"_"$3"
				awk '/Ping/ { print $2 }' "$CACHE_FILE"_"$3"
				;;
		esac
	fi
else
	display_help
fi

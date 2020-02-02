#!/bin/bash

OUTPUT=/tmp/nativememory.out

if [ "$#" -lt 3 ]; then
	echo "usage: $0 <threads> <chunkSizeMB> <chunksPerThread>"
	exit 1
fi

echo "MALLOC_TRIM_THRESHOLD_=${MALLOC_TRIM_THRESHOLD_} ; MALLOC_TOP_PAD_=${MALLOC_TOP_PAD_}"

(java -jar build/libs/nativememory-1.0-SNAPSHOT-all.jar $@ > ${OUTPUT} 2>&1) &
nm_pid=$!


function cleanup {
	kill ${nm_pid}
	echo "killed pid ${nm_pid}"
}

function report {
	date=$(date)
	echo "=========== ${date} ==========="
	#cat /proc/${nm_pid}/status | grep -E '^Rss|^Vm'
	#echo
	pmap -x ${nm_pid} | grep ^total
}

trap cleanup EXIT

# give nativememory some time to start
sleep 10 

nm_output=$(cat ${OUTPUT} | grep ^pid)
echo ${nm_output}

report
sleep 30
report

#while true
#do
#    report
#    sleep 30
#done

#!/usr/bin/env bash

# Concurrency tracking
pids=()

# Sanitize currently just removes any carrige returns that may be interpreted by the http response
sanitize () {
               cleanvalue=$(echo $1 | sed 's/\r//g')
               echo $cleanvalue
}

download () {
               startrange=$1
               endrange=$2
               chunk=$3
               echo "Chunk: $chunk"
               if [ ! -z $endrange ]; then
                   curl -s -H "range: bytes=${startrange}-${endrange}" ${URL} -o "${chunk}.part" &
                   pids+=($!)
               else
                   curl -s -H "range: bytes=${startrange}-" ${URL} -o "${chunk}.part"
                   pids+=($!)

               fi
}

URL=$(sanitize $1)
CONCURRENCY=$(sanitize $2)
FILENAME=$3

if [ -z ${URL} ]; then
               echo "Please enter a URL"
               exit 1
fi

if [ -z ${CONCURRENCY} ]; then
               echo "Please enter a concurrency value"
               exit 1
fi

if [ -z ${FILENAME} ]; then
               echo "No filename specified - using output.file"
               FILENAME="output.file"
fi

if [ -z $(which curl) ]; then
               echo "curl required - either not installed or not in path"
               exit 1
fi


# Content-Length response from server determines the file size required
filesize=$(sanitize $(curl -sI ${URL} | grep -i Content-Length | awk '{print $2}')) || echo "Failed to determinie size"

# Divide the file into multiple parts based on concurrency given
# e.g. if a 1G file is found, and a concurrency of 10 is given
# then download 10 100MB chunks (though data is handled in bytes)
rangestart=0
rangesize=$(sanitize $(($filesize / $CONCURRENCY)))
rangechunk=${rangesize}
for range in $(seq ${CONCURRENCY}); do
               download $rangestart $rangesize $range
               remaining=$((${filesize} - ${rangesize}))
               rangestart=$((${rangesize} + 1))
               rangesize=$((${rangechunk} + ${rangesize}))
               if [ ${remaining} -le ${rangechunk} ]; then
                   echo "Getting last chunk"
                   lastchunk=$((${range} + 1))
                   echo "Lastchunk number: $lastchunk"
                   download $rangestart "" $lastchunk
                   break
               fi

done

for pid in ${pids[*]}; do
               wait $pid
done

echo "Rebuilding chunks..."
for chunk in $(seq $lastchunk); do
               cat $chunk.part >> $FILENAME
               rm $chunk.part
done

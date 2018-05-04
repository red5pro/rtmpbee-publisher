#!/bin/bash
#===================================================================================
#
# FILE: rtmpbee-publisher.sh
#
# USAGE: rtmpbee-publisher.sh [endpoint] [app] [streamName] [amount of streams to start] [amount of time to playback] [flv-file]
#
# EXAMPLE: ./rtmpbee-publisher.sh ipv6west.red5.org live stream1 10 10 bbb_480p.flv
# LOCAL EXAMPLE: ./rtmpbee-publisher.sh localhost:1935 live stream1 10 10 bbb_480p.flv
#
# DESCRIPTION: Creates N-number of RTMP broadcast with file as a live stream.
#
# OPTIONS: see function ’usage’ below
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: Todd Anderson
# COMPANY: Infrared5, Inc.
# VERSION: 1.0.0
#===================================================================================
set -e
endpoint=$1
app=$2
stream_name=$3
amount=$4
timeout=$5
file=$6

#=== FUNCTION ================================================================
# NAME: shutdown
# DESCRIPTION: Shutsdown current process
# PARAMETER 1: The PID.
#===============================================================================
function shutdown {
  pid=$1
  kill -9 "$pid" && echo "PID(${pid}) stopped." || echo "Failure to kill ${pid}."
  echo "Attack ended at $(date '+%d/%m/%Y %H:%M:%S')"
  return 0
}

#=== FUNCTION ================================================================
# NAME: set_timeout
# DESCRIPTION: Set a non-blocking sleep for a PID
# PARAMETER 1: The PID.
# PARAMETER 2: The amount of time to wait before killing process.
#===============================================================================
function set_timeout {
  id=$1
  t=$2
  isLast=$3
  echo "Will kill ${id} in ${t} seconds..."
  if [ $isLast -eq 1 ]; then
    (sleep "$t"; shutdown "$id" || echo "Failure to kill ${id}."; return 0)
  else
    (sleep "$t"; kill -9 "$id" && echo "PID(${id}) stopped." || echo "Failure to kill ${id}.")&
  fi
  return 0
}

dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "Attack deployed at $dt"

# Dispatch.
for ((i=0;i<amount;i++)); do
  name="${stream_name}_${i}"
  target="rtmp://${endpoint}/${app}/${name}"
  stream_file="${file}_${i}"
  cp "$file" "$stream_file"
  # </dev/null tells ffmpeg to not look for input
  ffmpeg -re -stream_loop -1 -fflags +genpts -i "$stream_file" -c copy -f flv "$target" </dev/null > /dev/null 2>$1 &
  isLast=0
  if [ $i -eq $((amount - 1)) ]; then
    isLast=1
  fi
  pid=$!
  echo "Dispatching Bee $i($stream_file) at $target, PID(${pid})..."
  set_timeout "$pid" "$timeout" $isLast
  sleep 0.2
done


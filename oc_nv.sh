#!/bin/bash

CONFIG_FILE="/root/config.txt"
source $CONFIG_FILE
export DISPLAY=:0

if [ -z "$1" ] || [ -z "$2" ] ||  [ -z "$3" ]
then
	echo "Missing variable"
exit 1
fi
# getting number of gpu
IFS=$'\n' read -d '' -r -a gpu_list <<< "$gpu_info"
gpu_number=${#gpu_list[@]}
# splitting OC values devided by comma into arrays
IFS=', ' read -r -a core_clk <<< "$1"
IFS=', ' read -r -a memo_clk <<< "$2"
IFS=', ' read -r -a powr_lim <<< "$3"

# checking user input
function OptionMod() {
  declare -n array=$1
  if [ ${#array[@]} -ge $gpu_number ]; then
    # Already ok
    :
  elif [ ${#array[@]} -eq 1 ]; then
    # Using first for all
    for (( i = 1; i < $gpu_number; i++ )); do
      array+=(${array[0]})
    done
  else
    # Should not be the case, but...
    for (( i = $gpu_number - ${#array[@]}; i < $gpu_number ; i++ )); do
      array+=("0")
    done
  fi
}
OptionMod core_clk
OptionMod memo_clk
OptionMod powr_lim

# Checking if we dealing with 1050 or 1050 Ti
function gpu_check() {
  line_n=$1
  re='[[:space:]]GTX[[:space:]]1050[[:space:]]'
  if [[ "${gpu_info[$line_n]}" =~ $re ]]; then
    true
  else
    false
  fi
}

# Setting Parameters to each gpu
sudo nvidia-smi -pm 1 &
for ((x=0; x<gpu_number; x++))  do
	if gpu_check $x; then
    gpu_type=2
  else
    gpu_type=3
  fi
  echo "Applying CoreOffset: ${core_clk[$x]} MemoryOffset: ${memo_clk[$x]} for GPU $x"
  nvidia-settings -a [gpu:$x]/GpuPowerMizerMode=1 > /dev/null 2>&1 &
  nvidia-settings -a [gpu:$x]/GPUGraphicsClockOffset[$gpu_type]=${core_clk[$x]} > /dev/null 2>&1 &
  nvidia-settings -a [gpu:$x]/GPUMemoryTransferRateOffset[$gpu_type]=${memo_clk[$x]} > /dev/null 2>&1 &
  if [ "${powr_lim[$x]}" -ge "10" ] && [ "${powr_lim[$x]}" -le "400" ]; then
    echo "Applying PowerLimit: ${powr_lim[$x]} watt for GPU $x"
    sudo nvidia-smi --id=$x -pl ${powr_lim[$x]} > /dev/null 2>&1 &
  fi
  sleep 0.2
done

#!/usr/bin/env bash

TempA=40;
TempB=55;
TempC=60;
TempD=65;


ReadTemps() {
	if ! Temps=$(ipmitool sdr type temperature | awk -F"|" '{print $5}' | awk '{print $1}'); then
		echo "FAILED TO READ TEMPERATURE SENSOR" >&2;
		echo "Mode:     auto";
		ipmitool raw 0x30 0x30 0x01 0x01 >& /dev/null;
	fi
	TempPolled=$(echo $Temps | sed 's/ /\n/g' | sort -nr | head -n1);
	echo "HighTemp: $TempPolled";
};

SetMode() {
	if [[ $TempPolled < $TempD ]]; then
		ipmitool raw 0x30 0x30 0x01 0x00 >& /dev/null;
		sleep .2;
	fi

	if [[ $TempPolled < $TempA ]]; then
		echo "FanSpeed: 12%";
		ipmitool raw 0x30 0x30 0x02 0xff 0x0C >& /dev/null;
	elif [[ $TempPolled < $TempB ]]; then
		echo "FanSpeed: 16%";
		ipmitool raw 0x30 0x30 0x02 0xff 0x10 >& /dev/null;
	elif [[ $TempPolled < $TempC ]]; then
		echo "FanSpeed: 20%";
		ipmitool raw 0x30 0x30 0x02 0xff 0x14 >& /dev/null;
	elif [[ $TempPolled < $TempD ]]; then
		echo "FanSpeed: 24%";
		ipmitool raw 0x30 0x30 0x02 0xff 0x18 >& /dev/null;
	else
		echo "FanSpeed: Auto";
		ipmitool raw 0x30 0x30 0x01 0x01 >& /dev/null;
	fi
};

echo -e "\n###################";
date '+%Y-%m-%d %H:%M:%S';
ReadTemps;
SetMode;

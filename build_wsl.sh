#!/bin/bash
if [ -d Prusa-Firmware ]
then
	rm -rf Prusa-Firmware
	echo "removing old directory"
fi
git clone https://github.com/prusa3d/Prusa-Firmware
cd Prusa-Firmware
git checkout tags/v3.7.1
cd ..
python3 skele_patch.py
rc=$?
if [ $rc = 1 ]
then
	echo "failed updating... exiting"
else
    if [ ! -d Hex-files ]
    then
        mkdir Hex-files
        echo "creating Hex-files directory to avoid Prusa build script bug"
	else
		echo "removing old Hex-files directory"
		rm -rf Hex-files
		mkdir Hex-files
    fi
	echo "compiling firmware"
	results=$(./Prusa-Firmware/PF-build.sh 1_75mm_MK3-EINSy10a-E3Dv6full.h EN_ONLY GOLD)
    fwdir=$(echo $results | sed -n -E -e 's/.*Hex-file Folder: ([^ ]+).*/\1/p')
	#IFS=':'; fwinfo=($results); unset IFS;
	#IFS=' '; fwdir=(${fwinfo[11]}); unset IFS;
	echo "copying hex file to builds directory"
	if [ ! -d complete_builds ]
		then
		mkdir complete_builds
	fi
	#fwd=$(echo ${fwdir[0]} | cut -d' ' -f 1)
	fwfile=$(ls $fwdir)
	fwfull=$fwdir'/'$fwfile
	fwnew=$(echo $fwfile | cut -d "-" -f 1-2)
	cp $fwfull complete_builds/$fwnew-MK3-$(date +%Y%m%d).hex
	echo "compiled file is located at: $(pwd)/complete_builds/$fwnew-MK3-$(date +%Y%m%d).hex"
	echo "complete!"
fi

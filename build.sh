#!/bin/bash

#- CM10 nightly building script

###################################
#- Colorize and add text parameters
###################################
red=$(tput setaf 1)             #  Red        - Usage: ${red}
grn=$(tput setaf 2)             #  Green      - Usage: ${grn}
blu=$(tput setaf 4)             #  Blue       - Usage: ${blu}
cya=$(tput setaf 6)             #  Cyan       - Usage: ${cya}
txtbld=$(tput bold)             #  Bold       - Usage: ${txtbld}
bldred=${txtbld}$(tput setaf 1) #  Bold Red   - Usage: ${bldred}
bldgrn=${txtbld}$(tput setaf 2) #  Bold Green - Usage: ${bldgrn}
bldblu=${txtbld}$(tput setaf 4) #  Bold Blue  - Usage: ${bldblu}
bldcya=${txtbld}$(tput setaf 6) #  Bold Cyan  - Usage: ${bldcya}
txtrst=$(tput sgr0)             #  Reset      - Usage: ${txtrst}

#############
#- Initialize
#############
clear
date=$(date -u +%Y%m%d)
echo "${bldcya}CM10 Nightly Build Script${txtrst}"
echo ""

#- Get time of startup
res1=$(date +%s)

#- Check the status of the first parameter
case "$1" in
  clean)
    echo "${bldblu}Cleaning output files${txtrst}"
    rm -r -f out
	echo "";;
	
  sync)
    echo "${bldblu}Syncing latest sources${txtrst}"
	repo sync
	echo "";;
esac

#- Check the status of the second parameter
case "$2" in
  clean)
    echo "${bldblu}Cleaning output files${txtrst}"
    rm -r -f out
	echo "";;
	
  sync)
    echo "${bldblu}Syncing latest sources${txtrst}"
	repo sync
	echo "";;
esac

#- Check the status of the third parameter
case "$3" in
  clean)
    echo "${bldblu}Cleaning output files${txtrst}"
    rm -r -f out
	echo "";;
	
  sync)
    echo "${bldblu}Syncing latest sources${txtrst}"
	repo sync
	echo "";;
esac

#- Check if --no-upload flag is passed. If so, don't upload to goo.im
if [ "$1" = "--no-upload" ] || [ "$2" =  "--no-upload" ] || [ "$3" = "--no-upload" ]
  then
    echo "${bldblu}--no-upload flag specified. Not uploading to goo.im when the build is complete.${txtrst}"
    upload=false
	echo ""
elif [ "$1" != "--no-upload" ] || [ "$2" !=  "--no-upload" ] || [ "$3" = "--no-upload" ]
  then
    echo "${bldblu}Uploading to goo.im when the build is complete.${txtrst}"
    upload=true
	echo ""
fi

#####################################
#- Let's get started on the compiling
#####################################

#- Downloading prebuilts
echo "${bldblu}Downloading prebuilts...${txtrst}"
./vendor/cm/get-prebuilts
echo ""

#- Set up the environment
echo "${bldblu}Setting up the environment...${txtrst}"
source build/envsetup.sh
echo ""

#- Lunching
echo "${bldblu}Lunching...${txtrst}"
lunch cm_marvel-eng
echo ""

#- Enabling CCACHE
echo "${bldblu}Enabling CCACHE...${txtrst}"
export USE_CCACHE=1
echo ""

#- Time to compile this thing!
echo "${bldblu}Building...${txtrst}"
make -j8 bacon

#- Get finished time
res2=$(date +%s)

#####################
#- Finished compiling
#####################

#- Am I uploading this build?
case "$upload" in
  true)
    echo "${bldblu}Uploading to goo.im...${txtrst}"
	scp out/target/product/marvel/cm-10-"$date"-EXPERIMENTAL-marvel-CYANOGEN-NIGHTLY.zip dudeman1996@upload.goo.im:public_html/CM10-Nightlies_marvel/cm-10-"$date"-EXPERIMENTAL-marvel-NIGHTLY.zip
	res3=$(date +%s);;
  false)
    echo "${bldblu}--no-upload flag passed. Not uploading to goo.im${txtrst}"
	echo "";;
esac

#- Give elapsed time
if [ "$upload" = "true" ]
  then
    timeus=$(($res3 - $res1))
	timeum=$(($timeus / 60))
    echo "${bldgrn}Total taken to build & upload: ${txtrst}${grn}$timeum minutes ($timeus seconds)${txtrst}"
else
  times=$(($res2 - $res1))
  timem=$(($times / 60))
  echo "${bldgrn}Time taken to build: ${txtrst}${grn}$timem minutes ($times seconds)${txtrst}"
  echo ""
fi
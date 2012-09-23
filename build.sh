#!/bin/bash

#- CM10 nightly building script

###################################
#- Colourise and add text parameters
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
echo -e '\0033\0143'
clear
date=$(date -u +%Y%m%d)
echo "${bldcya}CM10 Nightly Build Script${txtrst}"
echo ""
#- Get time of startup
res1=$(date -u +%s)

#############################################
#- I need to check what parameters are passed
#############################################

#- If the --dirty flag is passed, set clean=false. Otherwise set clean=true
if [ "$1" = "--dirty" ] || [ "$2" = "--dirty" ] || [ "$3" = "--dirty" ]
then
  clean=false
else
  clean=true
fi

#- If the --no-sync flag is passed, set sync=false. Otherwise set clean=true
if [ "$1" = "--no-sync" ] || [ "$2" = "--no-sync" ] || [ "$3" = "--no-sync" ]
then
  sync=false
else
  sync=true
fi

#- If the --no-upload flag is passed, set upload=false. Otherwise set upload=true
if [ "$1" = "--no-upload" ] || [ "$2" = "--no-upload" ] || [ "$3" = "--no-upload" ]
then
  echo "${bldblu}--no-upload flag specified. Not uploading to goo.im when the build is complete.${txtrst}"
  upload=false
  echo ""
else
  upload=true
fi

##########################################
#- I need to check the status of the clean
#- and sync variables and act accordingly
##########################################
if [ "$sync" = "true" ]
then
  echo "${bldblu}Syncing latest sources...${txtrst}"
  repo sync
  echo ""
  echo "${bldblu}Patching GPS and Camera fixes from CM's gerrit${txtrst}"
  ./patch.sh
  echo ""
elif [ "$sync" = "false" ]
then
  echo "${red}Warning! The --no-sync flag was passed. This could result in a build with outdated sources. Re-run the script without the --no-sync flag to make sure your sources are up to date.${txtrst}"
  echo ""
fi

if [ "$clean" = "true" ]
then
  echo "${bldblu}Cleaning out files${txtrst}"
  make clean
  make clobber
  echo ""
elif [ "$clean" = "false" ]
then
  echo "${red}Warning! The --dirty flag was passed! This will result in a 'dirty build' and could either fail to compile, or the build may not work at all. Use with caution.${txtrst}"
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
res2=$(date -u +%s)

#############################
#- Am I uploading this build?
#############################
if [ "$upload" = "true" ]
then
  read -p "${bldblu}Press enter to upload to goo.im"
  echo ""
  echo "${bldblu}Uploading to goo.im...${txtrst}"
  scp out/target/product/marvel/cm-10-"$date"-EXPERIMENTAL-marvel-CYANOGEN-NIGHTLY.zip dudeman1996@upload.goo.im:public_html/CM10-Nightlies_marvel/cm-10-"$date"-EXPERIMENTAL-marvel-NIGHTLY.zip
  echo ""
  echo "${bldblu}Uploading to mirror...${txtrst}"
  scp out/target/product/marvel/cm-10-"$date"-EXPERIMENTAL-marvel-CYANOGEN-NIGHTLY.zip dudeman1996@75.127.15.79:rommanager/cm-10-"$date"-EXPERIMENTAL-marvel-NIGHTLY.zip
  echo ""
  res3=$(date -u +%s)
elif [ "$upload" = "false" ]
then
  echo "${bldblu}--no-upload flag passed. Not uploading to goo.im${txtrst}"
  echo ""
fi

###################################
#- Time for the elapsed time stuff!
###################################

#- Set time variables
if [ "$upload" = "true" ]
then
  timeus=$(($res3 - $res1))
  timeum=$(($timeus / 60))
  timeuh=$(($timeum / 60))
else
  times=$(($res2 - $res1))
  timem=$(($times / 60))
  timeh=$(($timem / 60))
  echo ""
fi

#- Display elapsed time for build & upload (if applicable)
if [ "$upload" = "true" ] && [ "$timeum" > "60" ]
then
  echo "${bldgrn}Total time taken to build & upload: ${txtrst}${grn}$timeuh hours / $timeum minutes / $timeus seconds${txtrst}"
  echo ""
elif [ "$upload" = "true" ] && [ "$timeum" < "60" ]
then
  echo "${bldgrn}Total time taken to build & upload: ${txtrst}${grn}$timeum minutes / $timeus seconds${txtrst}"
  echo ""
fi

#- Display elapsed time for build
if [ "$upload" = "false" ] && [ "timem" > "60" ]
then
  echo "${bldgrn}Total time taken to build: ${txtrst}${grn}$timeh hours / $timem minutes / $times seconds${txtrst}"
  echo ""
elif [ "$upload" = "false" ] && [ "$timem" < "60" ]
then
  echo "${bldgrn}Total time taken to build: ${txtrst}${grn}$timem minutes / $times seconds${txtrst}"
  echo ""
fi
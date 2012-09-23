#!/bin/bash

#- Patches camera and GPS from CM's gerrit

cd bionic
git fetch http://review.cyanogenmod.com/CyanogenMod/android_bionic refs/changes/31/14631/1 && git format-patch -1 --stdout FETCH_HEAD
cd ..
cd hardware/msm7k
git fetch http://review.cyanogenmod.com/CyanogenMod/android_hardware_msm7k refs/changes/58/15058/3 && git format-patch -1 --stdout FETCH_HEAD
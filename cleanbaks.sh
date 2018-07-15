#!/bin/bash
# clean up old files
keepDays=14
scanDays=30
mnp=bootstrapmainnet
tnp=bootstraptestnet
echo cron clean older than $keepDays days bootstrap data - `date` 
oldFolders=$(ls -lt --time-style=long-iso | grep -oP '[0-9]*-[0-9]*-[0-9]*.*bootstrap.*net[0-9]*')
while [ $keepDays -lt $scanDays ]; do
  foundMainnetName=""
  foundTestnetName=""
  #echo keepDays=$keepDays
  loopDate=$(date -u -d "now -"$keepDays" days" +%Y-%m-%d)
  #echo loopDate=$loopDate
  found=$(echo -e $oldFolders | grep -oP $loopDate)
  #echo found=$found
  if [ "$found" != "" ]; then
    foundMainnetName=$(echo -e $oldFolders | grep -oP $loopDate...:...$mnp[0-9]* | sed s/$loopDate...:...//)
    foundTestnetName=$(echo -e $oldFolders | grep -oP $loopDate...:...$tnp[0-9]* | sed s/$loopDate...:...//)
    echo "found old folder $foundMainnetName $foundTestnetName, deleting $loopDate/ ..."
    echo rm $foundMainnetName $foundTestnetName
  fi
  if [ "$foundMainnetName" != "" ]; then
    rm -rf $foundMainnetName
  fi
  if [ "$foundTestnetName" != "" ]; then
    rm -rf $foundTestnetName
  fi
  let keepDays=keepDays+1
done

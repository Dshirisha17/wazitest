#!/bin/sh
## DBB Demo- DBB Build v1.3 (lkl)
. $HOME/.profile
WorkDir=$1 ; cd $WorkDir
WorkSpace=$2
App=$3
Hlq=$4
BuildMode="$5 $6" # DBB Build modes, for example: --impactBuild, --reset, --fullBuild, '--fullBuild --scanOnly'
zAppBuild=$HOME/dbb-zappbuild/build.groovy
echo "**************************************************************"
# echo "** ./dbb-build.sh on HOST: $(uname -Ia) v1.3"
echo "** WorkDir:" $PWD
echo "** Workspace:" $WorkSpace
echo "** App:" $App
echo "** DBB Build Mode:" $BuildMode
echo "** DBB zAppBuild Path:" $zAppBuild
echo "** DBB_HOME:" $DBB_HOME
echo "** "
echo "\n** Git Status for Build WorkSpace:"
git -C $WorkSpace status
echo "groovyz $zAppBuild --workspace $WorkSpace --application $App -outDir . --hlq $Hlq --logEncoding UTF-8 $BuildMode"
groovyz $zAppBuild --workspace $WorkSpace --application $App -outDir . --hlq $Hlq --logEncoding UTF-8 $BuildMode
if [ "$?" -ne "0" ]; then
 echo "DBB Build Error. Check the build log for details"
 exit 12
fi
## Except for the reset or scanOnly modes, check for "nothing to build" condition and throw an error to stop pipeline
if [[ $BuildMode = '--reset' || $BuildMode = '--scanOnly' ]]; then
 buildlistsize=$(wc -c < $(find . -name buildList.txt))
 if [ $buildlistsize = 0 ]; then
 echo "*** Build Error: No source changes detected. Stopping pipeline. RC=12"
 exit 12
 fi
 else
 echo "*** DBB reset or scanOnly completed"
 fi
exit 0

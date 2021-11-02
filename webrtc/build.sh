#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
ARCH_ARR=(arm arm64)
OUT_DIR="out"
BUILD_TYPE="release"
TARGET_NAME="webrtc"

SRC_DIR=$1 # /data/dev/webrtc_android/src
SRC_BRANCH=$2  # master

if [[ $3 == "debug" ]] ;then
  BUILD_TYPE="debug"
fi

cd $SRC_DIR

git fetch
git reset --hard
git checkout $SRC_BRANCH
gclient sync

SECONDS=0
for CURRENT_ARCH in ${ARCH_ARR[@]}
do
  # copy args.gn
  mkdir -p $OUT_DIR/$CURRENT_ARCH.$BUILD_TYPE
  cp $SCRIPT_DIR/$CURRENT_ARCH.$BUILD_TYPE.args.gn $OUT_DIR/$CURRENT_ARCH.$BUILD_TYPE/args.gn
  gn gen $OUT_DIR/$CURRENT_ARCH.$BUILD_TYPE

  rm -rf $OUT_DIR/$CURRENT_ARCH.$BUILD_TYPE/obj/*.a
  # compile
  autoninja -C $OUT_DIR/$CURRENT_ARCH.$BUILD_TYPE

  if [[ $CURRENT_ARCH == "arm64" ]]; then
    cp $OUT_DIR/$CURRENT_ARCH.$BUILD_TYPE/obj/lib${TARGET_NAME}.a $OUT_DIR/$CURRENT_ARCH.$BUILD_TYPE/obj/lib${TARGET_NAME}64.a
  fi
done

echo "build finished in $SECONDS seconds"
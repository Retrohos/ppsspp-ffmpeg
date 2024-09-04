#!/bin/bash

if [ "$NDK_ROOT" = "" ]; then
    echo "Please set NDK_ROOT to your OpenHarmony NDK location."
    exit 1
fi

NDK_PLATFORM="aarch64-linux-ohos"
NDK_PLATFORM_LIB=$NDK_ROOT/sysroot/usr/lib/$NDK_PLATFORM

NDK_PREBUILTLLVM=$NDK_ROOT/llvm

set -e

GENERAL="\
   --enable-cross-compile \
   --enable-pic \
   --cc=$NDK_PREBUILTLLVM/bin/clang \
   --cross-prefix=$NDK_PREBUILTLLVM/bin/aarch64-unknown-linux-ohos- \
   --ar=$NDK_PREBUILTLLVM/bin/llvm-ar \
   --ld=$NDK_PREBUILTLLVM/bin/clang \
   --nm=$NDK_PREBUILTLLVM/bin/llvm-nm \
   --ranlib=$NDK_PREBUILTLLVM/bin/llvm-ranlib"

MODULES="\
   --disable-avdevice \
   --disable-filters \
   --disable-programs \
   --disable-network \
   --disable-avfilter \
   --disable-postproc \
   --disable-encoders \
   --disable-protocols \
   --disable-hwaccels \
   --disable-doc"

VIDEO_DECODERS="\
   --enable-decoder=h264 \
   --enable-decoder=mpeg4 \
   --enable-decoder=mpeg2video \
   --enable-decoder=mjpeg \
   --enable-decoder=mjpegb"

AUDIO_DECODERS="\
    --enable-decoder=aac \
    --enable-decoder=aac_latm \
    --enable-decoder=atrac3 \
    --enable-decoder=atrac3p \
    --enable-decoder=mp3 \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s8"

DEMUXERS="\
    --enable-demuxer=h264 \
    --enable-demuxer=m4v \
    --enable-demuxer=mpegvideo \
    --enable-demuxer=mpegps \
    --enable-demuxer=mp3 \
    --enable-demuxer=avi \
    --enable-demuxer=aac \
    --enable-demuxer=pmp \
    --enable-demuxer=oma \
    --enable-demuxer=pcm_s16le \
    --enable-demuxer=pcm_s8 \
    --enable-demuxer=wav"

VIDEO_ENCODERS="\
	  --enable-encoder=huffyuv
	  --enable-encoder=ffv1"

AUDIO_ENCODERS="\
	  --enable-encoder=pcm_s16le"

MUXERS="\
  	--enable-muxer=avi"

PARSERS="\
    --enable-parser=h264 \
    --enable-parser=mpeg4video \
    --enable-parser=mpegaudio \
    --enable-parser=mpegvideo \
    --enable-parser=aac \
    --enable-parser=aac_latm"

function build_arm64
{
    # no-missing-prototypes because of a compile error seemingly unique to aarch64.
./configure --logfile=conflog.txt --target-os=linux \
    --prefix=./ohos/arm64 \
    --arch=aarch64 \
    ${GENERAL} \
    --extra-cflags=" --target=aarch64-linux-ohos -no-canonical-prefixes -fdata-sections -ffunction-sections -fno-limit-debug-info -funwind-tables -fPIC -O2 -DOHOS -DOHOS_ARCH=arm64-v8a -DOHOS_PLATFORM=OHOS -DCMAKE_TOOLCHAIN_FILE=${NDK_ROOT}/build/cmake/ohos.toolchain.cmake -Dipv6mr_interface=ipv6mr_ifindex -fasm -fno-short-enums -fno-strict-aliasing -Wno-missing-prototypes" \
    --disable-shared \
    --enable-static \
    --extra-ldflags=" -B$NDK_PREBUILTLLVM/bin/aarch64-unknown-linux-ohos- --target=aarch64-linux-ohos -Wl,--rpath-link,$NDK_PLATFORM_LIB -L$NDK_PLATFORM_LIB  -nostdlib -lc -lm -ldl" \
    --enable-zlib \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
    ${MUXERS} \
    ${PARSERS}

make clean
make -j4 install
}

build_arm64

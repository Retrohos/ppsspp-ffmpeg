#!/bin/bash
#Change NDK to your Android NDK location
NDK=/c/AndroidNDK
PLATFORM=$NDK/platforms/android-21/arch-x86_64/
PREBUILT=$NDK/toolchains/x86_64-4.9/prebuilt/windows-x86_64
PREBUILTLLVM=$NDK/toolchains/llvm/prebuilt/windows-x86_64

set -e

GENERAL="\
   --enable-cross-compile \
   --enable-pic \
   --extra-libs="-latomic" \
   --cc=$PREBUILTLLVM/bin/clang \
   --cross-prefix=$PREBUILT/bin/x86_64-linux-android- \
   --ld=$PREBUILTLLVM/bin/clang \
   --nm=$PREBUILT/bin/x86_64-linux-android-nm"

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

function build_x86_64
{
./configure --logfile=conflog.txt --target-os=linux \
    --prefix=./android/x86_64 \
    --arch=x86_64 \
    ${GENERAL} \
    --sysroot=$PLATFORM \
    --extra-cflags=" --target=x86_64-linux-android -O3 -DANDROID -Dipv6mr_interface=ipv6mr_ifindex -fasm -fno-short-enums -fno-strict-aliasing -fomit-frame-pointer -march=x86-64" \
    --disable-shared \
    --enable-static \
    --extra-ldflags=" -B$PREBUILT/bin/x86_64-linux-android- --target=x86_64-linux-android -Wl,--rpath-link,$PLATFORM/usr/lib64 -L$PLATFORM/usr/lib64 -L$PREBUILT/x86_64-linux-android/lib -nostdlib -lc -lm -ldl -llog" \
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

build_x86_64

#!/usr/bin/env bash

VER="${PPSSPP_VER:-fa50bb1976065c4f8b1b47af227d367fe9771555}" # v1.20.4
URL="https://github.com/hrydgard/ppsspp.git"

SUBMODULES=(ffmpeg ext/armips ext/glslang ext/SPIRV-Cross ext/rapidjson
	    ext/cpu_features ext/rcheevos ext/naett ext/libchdr ext/lua
	    ext/nanosvg ext/aemu_postoffice ext/OpenXR-SDK assets/debugger)

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"
PATCHDIR="${SCRIPT_DIR}/patches"
ASSETDIR="${SCRIPT_DIR}/sce_sys"

if [[ -z "$PS4_HOMEBREW_SDK" ]]; then
    echo "error: PS4_HOMEBREW_SDK is not set"
    exit 1
fi

source "${PS4_HOMEBREW_SDK}/toolchain/orbis.sh" || exit 1

TEMPDIR=$(mktemp -d)
trap 'rm -rf -- "$TEMPDIR"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP

SRCDIR="${TEMPDIR}/ppsspp"
BUILDDIR="${TEMPDIR}/build"
FFMPEGDIR="${TEMPDIR}/ffmpeg"
NPROC="$(getconf _NPROCESSORS_ONLN)"

mkdir "${SRCDIR}" || exit 1
cd "${SRCDIR}" || exit 1

# a tarball would not include the submodules, and a recursive clone would
# fetch a lot more of them than needed
git init -q . || exit 1
git remote add origin "${URL}" || exit 1
git fetch -q --depth 1 origin "${VER}" || exit 1
git checkout -q FETCH_HEAD || exit 1

for SUB in "${SUBMODULES[@]}"; do
    git submodule update -q --init --depth 1 "${SUB}" || exit 1
done

for P in "${PATCHDIR}"/*.patch; do
    git apply "${P}" || exit 1
done
cp -r "${ASSETDIR}" "${SRCDIR}/" || exit 1

# PPSSPP's own FFmpeg (the ffmpeg submodule), with the options its
# linux_x86-64.sh uses, built out of tree
mkdir "${FFMPEGDIR}-build" || exit 1
cd "${FFMPEGDIR}-build" || exit 1
"${SRCDIR}/ffmpeg/configure" \
    --prefix="${FFMPEGDIR}" \
    --enable-cross-compile \
    --arch=x86_64 \
    --target-os=freebsd \
    --cross-prefix="${PS4_HOMEBREW_SDK}/bin/orbis-" \
    --cc="${CC}" \
    --pkg-config="${PKG_CONFIG}" \
    --disable-shared \
    --enable-static \
    --enable-pic \
    --disable-yasm \
    --extra-cflags="-D__STDC_CONSTANT_MACROS -O3" \
    --disable-everything \
    --disable-programs \
    --disable-doc \
    --disable-avdevice \
    --disable-avfilter \
    --disable-postproc \
    --disable-network \
    --disable-iconv \
    --disable-bzlib \
    --disable-lzma \
    --disable-sdl \
    --disable-xlib \
    --enable-zlib \
    --enable-decoder=h264,mpeg4,h263,h263p,mpeg2video,mjpeg,mjpegb \
    --enable-decoder=aac,aac_latm,atrac3,atrac3p,mp3,pcm_s16le,pcm_s8 \
    --enable-demuxer=h264,h263,m4v,mpegps,mpegvideo,avi,mp3,aac \
    --enable-demuxer=pmp,oma,pcm_s16le,pcm_s8,wav \
    --enable-encoder=ffv1,huffyuv,mpeg4,pcm_s16le \
    --enable-muxer=avi \
    --enable-parser=h264,mpeg4video,mpegvideo,aac,aac_latm,mpegaudio \
    --enable-protocol=file >/dev/null || exit 1
make -s -j "${NPROC}" install || exit 1

"${CMAKE}" -S "${SRCDIR}" -B "${BUILDDIR}" \
           -DCMAKE_BUILD_TYPE=Release \
           -DCMAKE_VERBOSE_MAKEFILE=OFF \
           -DUSING_GLES2=ON \
           -DUSING_X11_VULKAN=OFF \
           -DUSE_WAYLAND_WSI=OFF \
           -DUSE_VULKAN_DISPLAY_KHR=ON \
           -DFFMPEG_DIR="${FFMPEGDIR}" \
           -DUSE_SYSTEM_ZSTD=ON \
           -DUSE_SYSTEM_FREETYPE=ON \
           -DUSE_DISCORD=OFF \
           -DUSE_SYSTEM_MINIUPNPC=ON \
           -DARMIPS_USE_STD_FILESYSTEM=ON \
           -DCMAKE_DISABLE_FIND_PACKAGE_Fontconfig=ON || exit 1

"${CMAKE}" --build "${BUILDDIR}" -j "${NPROC}" || exit 1

mv -f "${BUILDDIR}"/*.pkg "${SCRIPT_DIR}/" || exit 1

# PPSSPP for the PS4

A port of the [PPSSPP](https://github.com/hrydgard/ppsspp) PSP emulator
(v1.20.4) to the PS4, built with the
[ps4-homebrew-dev SDK](https://github.com/ps4-homebrew-dev/sdk). This
repository holds the patches against upstream PPSSPP, the package assets,
and a script that builds the pkg. Tested on PS4 Pro and PS5.

## Download
Prebuilt pkgs are on the [releases](https://github.com/ps4-homebrew-dev/ppsspp/releases) page.

## Building
You need git, cmake, and the
[PS4 homebrew SDK](https://github.com/ps4-homebrew-dev/sdk) with the
[pacbrew](https://github.com/ps4-homebrew-dev/pacbrew) packages:

```sh
wget https://github.com/ps4-homebrew-dev/pacbrew/releases/latest/download/ps4-homebrew-dev.tar.gz
sudo tar xf ps4-homebrew-dev.tar.gz -C /
PS4_HOMEBREW_SDK=/opt/ps4-homebrew-sdk ./build.sh
```

The script fetches PPSSPP, applies the patches in `patches/`, builds it and
leaves the pkg next to `build.sh`. Set `PPSSPP_VER` to build another PPSSPP
revision (the patches may need updating for it).

## Usage
- Put your games on USB.
- Saves and settings are kept in `/temp0/ppsspp`.
- Vulkan is the default graphics backend.
- On a PS4 Pro, PPSSPP runs in Pro mode.

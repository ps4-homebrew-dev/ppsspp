# PPSSPP for the PS4

A port of the [PPSSPP](https://github.com/hrydgard/ppsspp) PSP emulator
(v1.20.4) to the PS4, built with the
[ps4-homebrew-dev SDK](https://github.com/ps4-homebrew-dev/sdk). Tested
on PS4 Pro and PS5.

## Building
Install the SDK from
[pacbrew](https://github.com/ps4-homebrew-dev/pacbrew/releases), then:

```
PS4_HOMEBREW_SDK=/opt/ps4-homebrew-sdk ./build.sh
```

The script fetches PPSSPP, applies the patches in `patches/`, builds it and
leaves the pkg in this directory.

## Usage
- Put your games and bios on USB.
- Saves and settings are kept in `/temp0/ppsspp`.
- Vulkan is the default graphics backend.

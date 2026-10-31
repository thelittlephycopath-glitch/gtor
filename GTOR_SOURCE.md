# GTor upstream source

GTor tracks the official Tor Browser Android source as a pinned Git submodule.

- Upstream: https://gitlab.torproject.org/tpo/applications/tor-browser
- Pinned upstream commit: `1f8c6d9758e139aee1da08d170fe59a5b4580e87`
- Upstream branch at import time: `tor-browser-153.6.0esr-16.0-1`
- Source checkout date: 2026-10-28

## Get the source

Clone GTor with submodules enabled:

```bash
git clone --recurse-submodules https://github.com/thelittlephycopath-glitch/gtor.git
```

If GTor is already cloned:

```bash
git submodule update --init --recursive
```

The source is pinned to an exact upstream commit so builds are reproducible. Update the submodule pointer only after reviewing a new upstream revision.

## Android ABI scope

The intended Android release target is **ARM64 only (`arm64-v8a`)**. Do not produce Android `x86`, `x86_64`, or `armeabi-v7a` APK variants. Keep host-side build tools and upstream source files intact: architecture-specific source files are not APK outputs, and deleting them blindly can break the official build system. The ARM64 restriction belongs in the Android build/package configuration.

This source import is not yet an APK build. The official Tor Browser build system and its pinned dependencies must be wired into CI before a release APK can be claimed.

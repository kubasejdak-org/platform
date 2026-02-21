# platform

A CMake-based bootstrap framework that enables building C/C++ projects for Linux and baremetal platforms (with or
without RTOS) from a single codebase. It provides toolchain configuration via CMake variables and platform-specific
entry point abstraction through a unified `appMain()` interface.

Main features:

* **toolchain setup:** configures compiler, architecture flags, and build settings for target platform via CMake
  toolchain files,
* **unified main():** provides platform-specific `main()` implementations that invoke application-defined `appMain()`
  function.

> [!IMPORTANT]
> `platform` requires target project to use CMake.

## Overview

### Technologies

* **Language**: C++23, C17
* **Build System**: CMake (minimum version 3.28)
* **Documentation**: MkDocs with Material theme
* **Static Analysis**: clang-format, clang-tidy
* **CI/CD**: GitHub Actions

### Toolchain Setup

Toolchain configuration is controlled by 2 CMake variables (typically set via CMake presets):

* `PLATFORM` - selects platform from the list of supported ones,
* `TOOLCHAIN` - selects toolchain among those supported by given platform.

These variables select the appropriate toolchain file from `lib/toolchain/<platform>/` which configures the compiler,
supporting tools and defines architecture-specific flags (e.g., `-mcpu=cortex-m4 -mthumb` for ARM).

> [!TIP]
> For Linux `platform` provides also options to enable code coverage and sanitizers.

### Unified `main()`

Target application is required to implement `appMain(int argc, char* argv[])` instead of `main()`. Implementation of
`main()` on selected platform handles platform-specific initialization and CLI arguments preparation before calling
`appMain()`.

Depending on platform it can mean different things:

* **Linux:** calls directly `appMain()` with original arguments,
* **Baremetal:** constructs synthetic `argv[0]` argument and passes it to `appMain()`,
* **RTOS:**  creates an RTOS-specific task wrapper around `appMain()` and starts the scheduler.

This separation allows identical application code to run across all supported platforms without modification. Below you
can see a visualisation of this process:

```mermaid
flowchart TD
    main["main()"] --> Platform{platform}

    Platform -->|Linux| AppMainLinux["appMain()"]
    Platform -->|Baremetal| AppMainBaremetal["appMain()"]
    Platform -->|RTOS| CreateThread[Create thread]
    CreateThread --> Scheduler[Run scheduler]
    Scheduler e1@-->|new thread| AppMainRTOS["appMain()"]

    e1@{ animation: fast }

    classDef mainStyle stroke:#ff6600
    classDef appMainStyle stroke:#00ff00

    class main mainStyle
    class AppMainLinux,AppMainBaremetal,AppMainRTOS appMainStyle
```

## Repository Structure

`platform` follows standard `kubasejdak-org` repository layout for C++ library:

```txt
platform/
├── cmake/                          # CMake build system
│   ├── compilation-flags.cmake     # Internal compilation flags
│   ├── modules/                    # CMake Findxxx.cmake modules for dependencies
│   └── presets/                    # Internal presets helpers
├── lib/                            # Core components
│   ├── main/                       # appMain() entrypoint for given platform
│   │   ├── linux/                  # Entrypoint for Linux
│   │   ├── baremetal-arm/          # Entrypoint for baremetal on ARM
│   │   └── freertos-arm/           # Entrypoint for FreeRTOS on ARM
│   ├── package/                    # Component with repo build, version and git info
│   └── toolchain/                  # Toolchain configurations
│       ├── linux/                  # Toolchain configs for Linux
│       ├── baremetal-arm/          # Toolchain configs for baremetal on ARM
│       └── freertos-arm/           # Toolchain configs for FreeRTOS on ARM
├── examples/                       # Examples of platform usage
├── tools/                          # Internal tools and scripts
├── .devcontainer/                  # Devcontainers configs
├── .github/workflows/              # GitHub Actions configs
└── CMakePresets.json               # Development CMake presets
```

## Development

> [!NOTE]
> This section is relevant when working with `platform` itself, in standalone way. However presets used to build
> `platform` tests and examples can be used as a reference for dependent projects.

### Commands

* **Configure:** `cmake --preset <preset-name> . -B out/build/<preset-name>`
* **Build:** `cmake --build out/build/<preset-name> --parallel`
* **Run tests:** `cd out/build/<preset-name>/bin; ./<binary-name>`
* **Reformat code:** `tools/check-clang-format.sh`
* **Run linter:** `cd out/build/<preset-name>; ../../../tools/check-clang-tidy.sh`
  * Must be launched with clang preset (usually in clang devcontainer)

### Available CMake Presets

* **Native Linux**:
  * **Dependencies provided by target system:** `linux-native-{gcc,clang}-{debug,release}`
* **Cross-compilation**:
  * **Generic ARM64:** `linux-arm64-{gcc,clang}-{debug,release}`
  * **Yocto (via SDK):** `yocto-sdk-{gcc,clang}-{debug,release}`
  * **Baremetal ARMv7:** `baremetal-armv7-*-gcc-{debug,release}`
  * **FreeRTOS ARMv7:** `freertos-armv7-*-gcc-{debug,release}`
* **Sanitizers**: `*-{asan,lsan,tsan,ubsan}` variants

> [!NOTE]
> For local development use `linux-native-conan-gcc-debug` preset.

### Code Quality

* **Zero Warning Policy:** All warnings treated as errors
* **Code Formatting:** clang-format with project-specific style checked
* **Static Analysis:** clang-tidy configuration checked
* **Coverage:** Code coverage reports generated
* **Valgrind:** Tests and examples run under valgrind
* **Sanitizers:** Address, leak, thread, and undefined behavior sanitizers checked

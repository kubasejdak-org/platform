# platform

A CMake-based bootstrap framework that enables building C/C++ projects for Linux and baremetal platforms (with or without RTOS) from a single codebase. It provides toolchain configuration via CMake variables and platform-specific entry point abstraction through a unified `appMain()` interface.

Main features:

* **toolchain setup:** configures compiler, architecture flags, and build settings for target platform via CMake toolchain files,
* **unified main():** provides platform-specific `main()` implementations that invoke application-defined `appMain()` function.

> [!note] `platform` requires target project to use CMake. Several CMake trait are used, which require target project to
> use CMake in canonical way

## Overview

### Toolchain Setup

Toolchain configuration is controlled by 2 CMake variables (typically set via CMake presets):

* `PLATFORM` - selects platform from the list of supported ones,
* `TOOLCHAIN` - selects toolchain among those supported by given platform.

These variables select the appropriate toolchain file from `lib/toolchain/<platform>/` which configures the compiler,
supporting tools and defines architecture-specific flags (e.g., `-mcpu=cortex-m4 -mthumb` for ARM).

> [!note] For Linux `platform` provides also options to enable code coverage and sanitizers.

### Unified `main()`

Application code implements `appMain(int argc, char* argv[])` instead of `main()`. The platform-specific `main()` implementation is linked via `find_package(platform COMPONENTS main)` and handles platform initialization before calling `appMain()`. On Linux, this is a direct passthrough of arguments. On baremetal platforms, `main()` constructs synthetic arguments. On RTOS platforms, `main()` creates a task wrapper around `appMain()` and starts the scheduler. This separation allows identical application code to run across all supported platforms without modification.

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

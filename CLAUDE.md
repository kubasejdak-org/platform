# Platform

## Overview

Platform is a cross-platform abstraction library that provides easy-to-use abstractions for launching applications on various hardware/OS platforms. It solves two problems: configuring the compiler toolchain for a target platform via CMake toolchain files, and abstracting the launch of the main application thread by separating `main()` from the application entry point `appMain()`. This separation allows a single codebase to run on desktop Linux (where `appMain()` is called directly from `main()`), baremetal ARM (where `appMain()` is invoked with synthetic arguments), and FreeRTOS ARM (where `appMain()` runs inside a FreeRTOS task after `vTaskStartScheduler()`). The repo also provides build/git metadata utilities and platform-specific filesystem path discovery. It is consumed by other projects as a CMake dependency via `find_package(platform COMPONENTS ...)` and `Findplatform.cmake`.

## Repository Structure

```
platform/
├── cmake/                                      # CMake build system configuration
│   ├── compilation-flags.cmake                  # Global flags: -Wall -Wextra -Wpedantic -Werror, C17, C++23, -fno-exceptions
│   ├── components.cmake                         # FetchContent-based component loader for find_package() consumers
│   ├── modules/                                 # CMake Find modules for package discovery
│   │   ├── Findplatform.cmake                   # Main module: exposes toolchain, main, package components via FetchContent
│   │   └── Findstm32f4xx.cmake                  # Fetches CMSIS 5, STM32F4 device pack, and HAL driver from GitHub
│   └── presets/                                 # Composable CMake preset building blocks
│       ├── app.json                             # Sanitizer presets (asan, lsan, tsan, ubsan)
│       ├── type.json                            # Build type presets (debug, release)
│       ├── linux.json                           # Linux platform presets (native x64, arm64, yocto; gcc and clang variants)
│       └── baremetal.json                       # Baremetal ARM presets (armv7-m4 bare and FreeRTOS)
├── lib/                                         # Core libraries
│   ├── main/                                    # platform::main - main thread entry point abstraction
│   │   ├── CMakeLists.txt                       # OBJECT library, includes platform-specific subdirectory via ${PLATFORM}
│   │   ├── linux/                               # Linux: direct passthrough from main() to appMain(argc, argv)
│   │   │   ├── main.cpp                         # Entry point implementation
│   │   │   ├── paths.cpp                        # FHS path discovery (install prefix, sysconf, dataroot)
│   │   │   ├── include/platform/paths.hpp       # Public header for path utilities
│   │   │   └── CMakeLists.txt                   # Also defines platform::main-paths library
│   │   ├── baremetal-arm/                        # Baremetal: synthetic argv, minimal syscalls stubs
│   │   │   ├── main.cpp                         # Entry point with synthetic argv[0] = "appMain"
│   │   │   ├── syscalls.cpp                     # Minimal syscall implementations for bare metal
│   │   │   └── CMakeLists.txt                   # Also provides objcopy_generate_bin() function
│   │   └── freertos-arm/                        # FreeRTOS: creates task, starts scheduler
│   │       ├── main.cpp                         # Creates FreeRTOS task wrapping appMain(), calls vTaskStartScheduler()
│   │       ├── syscalls.cpp                     # Minimal syscall implementations for FreeRTOS
│   │       ├── CMakeLists.txt                   # Links against freertos, provides objcopy_generate_bin()
│   │       └── freertos-10.2.1/                 # Bundled FreeRTOS kernel with portable layers
│   │           ├── CMakeLists.txt               # Builds freertos OBJECT library
│   │           ├── *.c                          # FreeRTOS kernel sources (tasks, queues, timers, etc.)
│   │           ├── include/freertos/            # FreeRTOS public headers
│   │           └── portable/                    # Architecture-specific portable layers
│   │               ├── ARM_CM0/                 # Cortex-M0
│   │               ├── ARM_CM3/                 # Cortex-M3
│   │               ├── ARM_CM3_MPU/             # Cortex-M3 with MPU
│   │               ├── ARM_CM4F/                # Cortex-M4F (used by STM32F4)
│   │               ├── ARM_CM7/                 # Cortex-M7
│   │               ├── ARM_CM23/                # Cortex-M23 (secure + non-secure)
│   │               ├── ARM_CM33/                # Cortex-M33 (secure + non-secure)
│   │               ├── ARM_CA9/                 # Cortex-A9
│   │               └── ARM_CA53_64_BIT/         # Cortex-A53 (64-bit)
│   ├── package/                                 # platform::package - build and git metadata
│   │   ├── CMakeLists.txt                       # Runs getGitInfo.cmake at build time to generate git.hpp
│   │   ├── build.cpp                            # Compiler vendor/version and build type detection
│   │   ├── git.cpp                              # Git metadata accessors (tag, branch, commit, user)
│   │   ├── getGitInfo.cmake                     # CMake script that extracts git info into git.hpp from template
│   │   ├── git.hpp.in                           # Template for generated git.hpp header
│   │   └── include/platform/package/            # Public headers
│   │       ├── build.hpp                        # compilerVendor(), compiler(), buildType(), printVersion(), etc.
│   │       └── git.hpp                          # gitTag(), gitBranch(), gitCommit(), gitUserName(), gitUserEmail()
│   └── toolchain/                               # Toolchain configuration files
│       ├── setup.cmake                          # Platform dispatcher: sets OSAL_PLATFORM, output directories, CMAKE_TOOLCHAIN_FILE
│       ├── linux/                               # Linux toolchains
│       │   ├── toolchain.cmake                  # Entry point: selects compiler toolchain (defaults to gcc)
│       │   ├── gcc.cmake                        # Generic GCC toolchain
│       │   ├── gcc-11.cmake                     # GCC 11 specific
│       │   ├── gcc-13.cmake                     # GCC 13 specific
│       │   ├── clang.cmake                      # Generic Clang toolchain
│       │   ├── clang-14.cmake                   # Clang 14 specific
│       │   ├── clang-18.cmake                   # Clang 18 specific
│       │   ├── aarch64-none-linux-gnu-gcc.cmake # ARM64 Linux cross-compile with GCC
│       │   ├── aarch64-none-linux-gnu-clang.cmake # ARM64 Linux cross-compile with Clang
│       │   ├── sanitizers.cmake                 # ASAN, LSAN, TSAN, UBSAN compiler/linker flags
│       │   └── coverage.cmake                   # Code coverage instrumentation (--coverage -fprofile-update=atomic)
│       ├── baremetal-arm/                        # Baremetal ARM toolchains
│       │   ├── toolchain.cmake                  # Entry point: selects ARM EABI toolchain
│       │   └── arm-none-eabi-gcc.cmake          # ARM EABI GCC with Cortex-M4 flags (-mcpu, -mfpu, -mthumb, -Os)
│       └── freertos-arm/                        # FreeRTOS ARM toolchains
│           ├── toolchain.cmake                  # Entry point: selects ARM EABI toolchain, sets FREERTOS_VERSION/PORTABLE
│           └── arm-none-eabi-gcc.cmake          # Same ARM EABI GCC setup as baremetal
├── examples/                                    # Example applications (also serve as integration tests)
│   ├── CMakeLists.txt                           # Includes all example subdirectories
│   ├── hello-world/                             # Minimal appMain() demonstrating platform abstraction
│   ├── init/                                    # Platform-specific hardware initialization
│   │   ├── include/platform/init.hpp            # Common init() interface
│   │   ├── linux/                               # Linux: stub returning true
│   │   ├── baremetal-arm/                        # STM32F4: HAL init, UART4 console, GPIO, clock config
│   │   └── freertos-arm/                        # FreeRTOS on STM32F4: same as baremetal with RTOS awareness
│   ├── package-info/                            # Displays build metadata (compiler, git info)
│   └── paths/                                   # Displays FHS paths (Linux/Unix only)
├── tools/                                       # Development and CI helper scripts
│   ├── check-clang-format.sh                    # Runs clang-format in check mode on the entire repo
│   ├── check-clang-tidy.sh                      # Runs clang-tidy with adjusted compilation database
│   ├── run-clang-format.py                      # Python wrapper for clang-format (parallel execution)
│   ├── run-clang-tidy.py                        # Python wrapper for clang-tidy (parallel execution)
│   ├── adjust-compilation-db.py                 # Filters _deps entries from compile_commands.json
│   └── doxygen.sh                               # Generates Doxygen HTML documentation
├── .devcontainer/                               # VS Code devcontainer configurations
│   ├── gcc-13/devcontainer.json                 # Native x64 development with GCC 13
│   ├── clang-18/devcontainer.json               # Native x64 development with Clang 18
│   ├── aarch64-none-linux-gnu-gcc-13/           # ARM64 Linux cross-compilation
│   └── arm-none-eabi-gcc-13/                    # ARM EABI embedded cross-compilation
├── .github/workflows/                           # GitHub Actions CI pipelines
│   ├── build-test-linux.yml                     # Linux builds, example runs, Valgrind, sanitizers
│   ├── build-test-baremetal.yml                 # Baremetal and FreeRTOS ARM builds for STM32F4
│   ├── static-analysis.yml                      # clang-format and clang-tidy checks
│   └── code-coverage.yml                        # Coverage collection and threshold enforcement (90% line/function)
├── CMakeLists.txt                               # Root: cmake_minimum_required(3.28), find_package(platform), project(platform)
├── CMakePresets.json                            # Aggregates preset files, defines 20 composite configure presets
├── .clang-format                                # Code formatting rules (120 col, 4-space indent)
├── .clang-tidy                                  # Static analysis checks and naming conventions
├── .editorconfig                                # Editor consistency settings
├── CHANGELOG.md                                 # Version history
├── README.md                                    # Project overview
├── CONTRIBUTING.md                              # Contribution guidelines
└── LICENSE                                      # MIT License
```

## Architecture and Design

### Key Components

**`platform::main`** (lib/main/) - OBJECT library providing the main thread entry point abstraction. Each platform subdirectory implements `main()` differently:
- **Linux**: passes `argc`/`argv` directly to `appMain()`. Also exposes `platform::main-paths` for FHS path discovery (`getInstallPrefixPath()`, `getSysConfPath()`, `getDataRootPath()`).
- **Baremetal ARM**: creates synthetic `argv` and calls `appMain(1, argv)`. Provides minimal syscall stubs and `objcopy_generate_bin()` for binary generation.
- **FreeRTOS ARM**: creates a FreeRTOS task wrapping `appMain()`, then calls `vTaskStartScheduler()` (never returns). Supports both static and dynamic memory allocation. Links against bundled FreeRTOS 10.2.1.

**`platform::package`** (lib/package/) - Build and git metadata library. Provides `compilerVendor()`, `compiler()`, `buildType()`, `printVersion()`, `printBuildInfo()` for build info and `gitTag()`, `gitBranch()`, `gitCommit()`, `gitUserName()`, `gitUserEmail()` for git info. The `git.hpp` header is generated at build time via a CMake script that invokes `git`.

**Toolchain system** (lib/toolchain/) - CMake toolchain files that configure `CMAKE_TOOLCHAIN_FILE` based on `PLATFORM` and `TOOLCHAIN` variables. Also sets `OSAL_PLATFORM` (linux/none/freertos) for use by downstream OSAL libraries. Includes sanitizer and coverage support for Linux toolchains.

**`Findplatform.cmake`** (cmake/modules/) - The CMake Find module that external projects use to consume this repository. Uses `FetchContent` to pull individual components (`toolchain`, `main`, `package`) from the source tree.

**`Findstm32f4xx.cmake`** (cmake/modules/) - Fetches CMSIS 5, STM32F4 device package, and HAL driver from GitHub and builds a `stm32f4xx` library target for embedded examples.

### Key Design Patterns

**Platform abstraction via filesystem** - Platform-specific code lives in subdirectories named after the platform (`linux/`, `baremetal-arm/`, `freertos-arm/`). The parent `CMakeLists.txt` uses `add_subdirectory(${PLATFORM})` to include only the relevant implementation at configure time. No runtime polymorphism; all selection is compile-time.

**FetchContent-based component system** - The `Findplatform.cmake` module and `components.cmake` use CMake's `FetchContent` to expose individual library components. Each component maps to a subdirectory under `lib/` and is declared with `SOURCE_SUBDIR` pointing to that path. This allows consumers to pull only the components they need.

**OBJECT library pattern** - Core libraries (`platform-main`, `freertos`) are built as OBJECT libraries with `EXCLUDE_FROM_ALL`. This avoids creating standalone archives and lets object files be linked directly into the consumer's binary, which is important for embedded targets where code size matters.

**Preset inheritance** - CMake presets are composed by inheriting from building blocks: platform presets (e.g. `linux-native-gcc`), build type presets (`debug`/`release`), and optional feature presets (`asan`, `lsan`, `tsan`, `ubsan`). The top-level `CMakePresets.json` combines these into 20 concrete presets.

**Alias targets** - All libraries are exposed with namespaced aliases (`platform::main`, `platform::package`, `platform::main-paths`). Consumers always link against the alias form.

## Usage

### Consuming in Other Projects

Add the platform source directory to your `CMAKE_MODULE_PATH` and use `find_package()` with the desired components:

```cmake
list(APPEND CMAKE_MODULE_PATH "<path-to-platform>/cmake/modules")

# The toolchain component must be found before project() to set CMAKE_TOOLCHAIN_FILE
find_package(platform COMPONENTS toolchain)

project(my-app ASM C CXX)

# Find the runtime components after project()
find_package(platform COMPONENTS main package)
```

### Available Components

| Component     | Target                  | Description                                              |
|---------------|-------------------------|----------------------------------------------------------|
| `toolchain`   | (none, configures CMake)| Sets `CMAKE_TOOLCHAIN_FILE`, `OSAL_PLATFORM`, output dirs|
| `main`        | `platform::main`        | Main thread entry point abstraction                      |
| `package`     | `platform::package`     | Build metadata and git info                              |

On Linux, the `main` component also provides `platform::main-paths` for filesystem path discovery.

### Linking

```cmake
target_link_libraries(my-app
    PRIVATE
        platform::main
        platform::package
)
```

### STM32F4 Support

For STM32F4 Discovery board targets, use the `Findstm32f4xx.cmake` module:

```cmake
find_package(stm32f4xx)
target_link_libraries(my-app PRIVATE stm32f4xx)
```

This fetches CMSIS 5, the STM32F4 device package, and the HAL driver automatically.

### Application Entry Point

Instead of writing `main()`, implement `appMain()`:

```cpp
int appMain(int argc, char* argv[]);
```

The `platform::main` library provides the real `main()` and calls `appMain()` in the appropriate way for each platform.

## Development

### Setup

Development uses VS Code devcontainers. Four pre-configured environments are available in `.devcontainer/`:

| Container                            | Docker Image                                        | Use Case                        |
|--------------------------------------|-----------------------------------------------------|---------------------------------|
| `gcc-13`                             | `kubasejdak/gcc:13-24.04`                           | Native x64 development          |
| `clang-18`                           | `kubasejdak/clang:18-24.04`                         | Native x64 development          |
| `aarch64-none-linux-gnu-gcc-13`      | `kubasejdak/aarch64-none-linux-gnu-gcc:13-24.04`    | ARM64 Linux cross-compilation   |
| `arm-none-eabi-gcc-13`               | `kubasejdak/arm-none-eabi-gcc:13-24.04`             | ARM embedded cross-compilation  |

All containers are based on Ubuntu 24.04, mount host SSH keys and git config, and include VS Code extensions for C++, CMake, Python, and Markdown.

Required tools: CMake 3.28+, a supported compiler (GCC 13 or Clang 18 for native, ARM toolchains for cross-compilation), and Git.

### Building

The project uses CMake presets. Configure and build with:

```bash
cmake --preset <preset-name>
cmake --build --preset <preset-name>
```

#### Available Presets

**Linux native (x64):**

| Preset                              | Compiler  | Build Type | Notes                    |
|--------------------------------------|----------|------------|--------------------------|
| `linux-native-gcc-debug`             | GCC 13   | Debug      |                          |
| `linux-native-gcc-release`           | GCC 13   | Release    |                          |
| `linux-native-clang-debug`           | Clang 18 | Debug      |                          |
| `linux-native-clang-release`         | Clang 18 | Release    |                          |
| `linux-native-clang-debug-asan`      | Clang 18 | Debug      | Address Sanitizer        |
| `linux-native-clang-debug-lsan`      | Clang 18 | Debug      | Leak Sanitizer           |
| `linux-native-clang-debug-tsan`      | Clang 18 | Debug      | Thread Sanitizer         |
| `linux-native-clang-debug-ubsan`     | Clang 18 | Debug      | Undefined Behavior Sanitizer |

**Linux cross-compilation (ARM64):**

| Preset                              | Compiler  | Build Type |
|--------------------------------------|----------|------------|
| `linux-arm64-gcc-debug`              | GCC 13   | Debug      |
| `linux-arm64-gcc-release`            | GCC 13   | Release    |
| `linux-arm64-clang-debug`            | Clang 18 | Debug      |
| `linux-arm64-clang-release`          | Clang 18 | Release    |

**Yocto SDK:**

| Preset                              | Compiler  | Build Type |
|--------------------------------------|----------|------------|
| `yocto-sdk-gcc-debug`                | GCC      | Debug      |
| `yocto-sdk-gcc-release`              | GCC      | Release    |
| `yocto-sdk-clang-debug`              | Clang    | Debug      |
| `yocto-sdk-clang-release`            | Clang    | Release    |

**Embedded ARM (STM32F4 / Cortex-M4):**

| Preset                              | Environment | Build Type |
|--------------------------------------|------------|------------|
| `baremetal-armv7-m4-debug`           | Baremetal  | Debug      |
| `baremetal-armv7-m4-release`         | Baremetal  | Release    |
| `freertos-armv7-m4-debug`            | FreeRTOS   | Debug      |
| `freertos-armv7-m4-release`          | FreeRTOS   | Release    |

#### Compilation Flags

All builds use: `-Wall -Wextra -Wpedantic -Werror` with C17 and C++23 standards. C++ exceptions are disabled (`-fno-exceptions`). Embedded builds add `-Os -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb` with linker section garbage collection.

### Testing

There is no unit test framework. Testing is done via integration tests using example applications:

- **`platform-hello-world-example`** - basic compilation and platform abstraction verification
- **`platform-package-info-example`** - build and git metadata retrieval
- **`platform-paths-example`** - FHS path resolution (Linux/Unix only)

These examples are built and executed across multiple platforms and configurations in CI. Memory safety and correctness are validated through:
- **Valgrind** - heap memory profiling on x64
- **ASAN** - address/memory corruption detection
- **LSAN** - memory leak detection
- **TSAN** - data race detection
- **UBSAN** - undefined behavior detection

Code coverage is collected using `gcov` (GCC) with enforced thresholds of **90% line coverage** and **90% function coverage**.

### Code Style

Code formatting is enforced by **clang-format** (120 column limit, 4-space indent). Static analysis is enforced by **clang-tidy** with a comprehensive set of checks and strict naming conventions:
- Classes: `CamelCase`, abstract classes: `ICamelCase` (prefixed with `I`)
- Functions/variables: `camelBack`
- Private/protected members: `m_camelBack` (prefixed with `m_`)
- Enums: `CamelCase` with `e` prefix for values
- Macros: `UPPER_CASE`
- Namespaces: `lower_case`

Run locally:
```bash
./tools/check-clang-format.sh    # Check formatting
./tools/check-clang-tidy.sh      # Run static analysis (requires compile_commands.json)
```

### CI

CI runs on GitHub Actions with self-hosted runners. All workflows trigger on push, weekly schedule (Saturday 12:00 UTC), and manual dispatch.

**`build-test-linux.yml`** - Linux build and test pipeline:
- `build-x64`: builds all 8 Linux x64 presets (GCC/Clang, debug/release, sanitizers)
- `build-arm64`: cross-compiles 4 ARM64 presets
- `examples-x64`: runs 3 example binaries on x64
- `examples-arm64`: runs 3 example binaries on real ARM64 hardware
- `valgrind-x64`: memory profiling for all examples
- `sanitizers-x64`: runs all examples through each of the 4 sanitizers
- `check-all-linux`: gate job requiring all above to pass

**`build-test-baremetal.yml`** - Embedded build pipeline:
- `build-stm32f4`: compiles 4 embedded presets (baremetal + FreeRTOS, debug + release)
- Hardware test jobs exist but are currently commented out (STM32F4 Discovery via OpenOCD)
- `check-all-baremetal`: gate job

**`static-analysis.yml`** - Code quality pipeline:
- `formatting`: clang-format check
- `linting`: clang-tidy on `linux-native-clang-debug` preset
- `check-all-static`: gate job

**`code-coverage.yml`** - Coverage pipeline:
- `build-coverage`: builds with coverage instrumentation
- `test-coverage`: collects coverage for each example binary
- `generate-coverage-report`: validates 90% line and function coverage thresholds
- `check-all-coverage`: gate job

## Important Notes

- The `toolchain` component must be found **before** `project()` in consuming CMakeLists.txt, because it sets `CMAKE_TOOLCHAIN_FILE` which CMake processes during `project()`.
- The `PLATFORM` variable (linux, baremetal-arm, freertos-arm) is set via CMake presets or cache. It determines which platform-specific code is compiled. There is no runtime platform detection.
- `OSAL_PLATFORM` is derived from `PLATFORM` and is used by downstream OSAL libraries: `linux` maps to `linux`, `baremetal-arm` maps to `none`, `freertos-arm` maps to `freertos`.
- C++ exceptions are globally disabled. Do not use `throw`/`catch` in any code.
- All compiler warnings are treated as errors (`-Werror`). New code must compile cleanly.
- The `examples/` directory serves dual purpose: demonstrating usage and acting as integration tests in CI.
- FreeRTOS 10.2.1 is bundled directly in the source tree (not fetched externally), with portable layers for multiple ARM architectures.
- Embedded toolchains expect specific paths under `/opt/toolchains/` as configured in the devcontainers and CI Docker images.
- Build artifacts go to `${CMAKE_BINARY_DIR}/bin` (executables) and `${CMAKE_BINARY_DIR}/lib` (libraries).

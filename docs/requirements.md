# Platform – Requirements

## Overview

`platform` is a CMake-based bootstrap framework for building C/C++ projects targeting Linux and baremetal ARM platforms
(with or without FreeRTOS) from a single codebase. It abstracts the platform-specific entry-point dispatch mechanism and
provides toolchain configuration via CMake variables, enabling projects to implement a unified `appMain()` function that
works across all supported platforms.

## Functional Requirements

### Component: main

- [ ] **FR-1:** The framework shall provide a platform-specific `main()` entry point that dispatches to an
      application-defined `appMain(int argc, char* argv[])` function.
    - The `appMain()` function is the sole application entry point across all platforms.
    - The return value of `appMain()` shall be forwarded as the process exit code.

- [ ] **FR-2:** On Linux, `main()` shall pass the actual command-line `argc` and `argv` arguments directly to
      `appMain()`.

- [ ] **FR-3:** On baremetal ARM, `main()` shall invoke `appMain()` with `argc=1` and `argv[0]` set to the string
      `"appMain"`.
    - A minimal newlib C runtime (syscalls) shall be provided.
    - Heap memory shall be served via a static 2 KB buffer through `_sbrk()`.
    - File I/O syscalls (`_open`, `_close`, `_read`, `_fstat`, `_lseek`) shall return error codes indicating no support.
    - The application must provide a `consolePrint(const char*, size_t)` function for output.

- [ ] **FR-4:** On FreeRTOS ARM, `main()` shall create a FreeRTOS task that runs `appMain()` and start the FreeRTOS
      scheduler.
    - The application task stack size shall be configurable at compile time via `APPMAIN_STACK_SIZE`.
    - Both static and dynamic FreeRTOS memory allocation models shall be supported.
    - Idle task and timer task memory shall be provided by the framework for static allocation.
    - Time queries via `gettimeofday()` shall use FreeRTOS tick count as the time source.

- [ ] **FR-5:** On Linux, the framework shall provide an optional `platform::main-paths` CMake target exposing
      install-path query functions.
    - `getInstallPrefixPath()` shall return the CMake install prefix path.
    - `getSysConfPath()` shall return the system configuration directory path.
    - `getDataRootPath()` shall return the shared data root directory path.
    - All path values shall be baked in at compile time from CMake install variables.

### Component: package

- [ ] **FR-6:** The framework shall expose the compiler vendor as a compile-time constant string: `"gcc"`, `"clang"`, or
      `"unsupported"`.

- [ ] **FR-7:** The framework shall expose compiler major, minor, and patch version numbers as compile-time integer
      constants.

- [ ] **FR-8:** The framework shall expose the current build type as a compile-time constant string: `"debug"` or
      `"release"`.

- [ ] **FR-9:** The framework shall expose git repository metadata as runtime string values, captured at CMake
      configuration time:
    - Git tag, branch name, commit SHA, committer name, and committer email.
    - When git metadata is unavailable, all values shall fall back to `"N/A"`.
    - Metadata shall be refreshed at every CMake reconfiguration.

- [ ] **FR-10:** The framework shall provide `printVersion()` to print the git tag to standard output, and
      `printBuildInfo()` to print a formatted summary including compiler, build type, git metadata, and build timestamp.

### Component: toolchain

- [ ] **FR-11:** The framework shall configure the compiler, linker, and associated tools for the target platform based
      on the `PLATFORM` and `TOOLCHAIN` CMake variables.
    - Supported `PLATFORM` values: `linux`, `baremetal-arm`, `freertos-arm`.
    - The `toolchain` component must be requested via `find_package` before the `project()` call.

- [ ] **FR-12:** For Linux targets, the framework shall support the following toolchains: `gcc`, `clang`, `gcc-11`,
      `gcc-13`, `clang-14`, `clang-18`, `aarch64-none-linux-gnu-gcc`, `aarch64-none-linux-gnu-clang`.

- [ ] **FR-13:** For baremetal ARM and FreeRTOS ARM targets, the framework shall support the `arm-none-eabi-gcc`
      toolchain, with the binary directory configurable via `BAREMETAL_ARM_TOOLCHAIN_PATH`.

- [ ] **FR-14:** For ARM64 Linux cross-compilation, the toolchain binary directory shall be configurable via
      `LINUX_ARM_TOOLCHAIN_PATH`.

- [ ] **FR-15:** For Linux targets, the framework shall support enabling runtime sanitizers via CMake options: Address
      Sanitizer (`USE_ASAN`), Leak Sanitizer (`USE_LSAN`), Thread Sanitizer (`USE_TSAN`), and Undefined Behavior
      Sanitizer (`USE_UBSAN`).
    - Only one sanitizer may be enabled per build.
    - Optional flags `SANITIZER_DISABLE_FORTIFY` and `SANITIZER_DISABLE_OPTIMIZATION` shall allow further sanitizer
      configuration.

- [ ] **FR-16:** For Linux targets, the framework shall support enabling code coverage instrumentation via the
      `WITH_COVERAGE` CMake option.

- [ ] **FR-17:** The framework shall expose the `OSAL_PLATFORM` preprocessor definition to dependent code reflecting the
      active platform: `linux`, `none` (baremetal), or `freertos`.

- [ ] **FR-18:** For baremetal ARM and FreeRTOS ARM targets, the framework shall provide a CMake helper function
      `objcopy_generate_bin()` to produce raw binary images from ELF outputs.

### CMake Integration

- [ ] **FR-19:** The framework shall be integrable into dependent projects via `find_package(platform COMPONENTS ...)`.
    - Only components listed in `COMPONENTS` shall be processed and built.
    - The framework shall support FetchContent-based download from a Git repository.

## Non-Functional Requirements

- [ ] **NFR-1:** All C++ code shall target the C++23 standard; all C code shall target C17.

- [ ] **NFR-2:** All compiler warnings shall be treated as errors (`-Werror`). Warnings `-Wall`, `-Wextra`, and
      `-Wpedantic` shall be enabled.

- [ ] **NFR-3:** C++ exceptions shall be disabled across all platforms (`-fno-exceptions`).

- [ ] **NFR-4:** Debug builds shall use no optimization (`-O0 -g`) for Linux targets and size-optimized compilation
      (`-Os -g`) for ARM targets.

- [ ] **NFR-5:** Release builds shall use full optimization (`-O3 -DNDEBUG`) for Linux targets and size-optimized
      compilation (`-Os -DNDEBUG`) for ARM targets.

- [ ] **NFR-6:** Code coverage shall meet a minimum of 90% line coverage and 90% function coverage across the test
      suite.

- [ ] **NFR-7:** The `platform::package` git metadata file (`git.hpp`) shall be auto-generated at CMake configuration
      time and shall not be committed to source control.

## Technical Constraints and Requirements

- [ ] **TR-1:** The build system shall require CMake version 3.28 or higher.

- [ ] **TR-2:** The framework shall support the following target platforms: native Linux (x64), cross-compiled Linux
      (ARM64), baremetal ARM (ARMv7 Cortex-M4), and FreeRTOS ARM (ARMv7 Cortex-M4).

- [ ] **TR-3:** The supported FreeRTOS kernel version is `freertos-10.2.1`, selectable via the `FREERTOS_VERSION` CMake
      variable. The portable layer shall be selectable via `FREERTOS_PORTABLE`.

- [ ] **TR-4:** All C++ code shall reside in the `platform::` namespace hierarchy.

- [ ] **TR-5:** Code formatting shall conform to the project's clang-format configuration (120- character column limit,
      4-space indent, Allman brace style, LF line endings).

- [ ] **TR-6:** All clang-tidy checks enabled in the project configuration shall pass with no warnings (treated as
      errors).

- [ ] **TR-7:** The CI pipeline shall validate builds on: native x64 GCC 13 and Clang 18 (debug/release), ARM64
      cross-compiled GCC 13 and Clang 18 (debug/release), all four sanitizer variants (ASAN, LSAN, TSAN, UBSAN),
      baremetal ARMv7-M4 (debug/release), and FreeRTOS ARMv7-M4 (debug/release).

- [ ] **TR-8:** Linux native test builds shall be validated under Valgrind for memory safety.

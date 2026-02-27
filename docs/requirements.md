# Platform – Requirements

## Overview

`platform` is a CMake-based bootstrap framework for building C/C++ projects targeting Linux and baremetal ARM platforms
(with or without FreeRTOS) from a single codebase. It abstracts the platform-specific entry-point dispatch mechanism and
provides toolchain configuration via CMake variables, enabling projects to implement a unified `appMain()` function that
works across all supported platforms.

## Functional Requirements

### Component: main

- [x] **FR-1:** The framework shall support the following target platforms: Linux, baremetal ARM, FreeRTOS ARM.

- [x] **FR-2:** The framework shall provide a platform-specific `main()` entry point that dispatches to an
      application-defined `appMain(int argc, char* argv[])` function. The return value of `appMain()` shall be forwarded
      as the process exit code.
    - On Linux: `main()` shall pass the actual command-line arguments directly to `appMain()`.
    - On baremetal (non-RTOS) targets: `main()` shall invoke `appMain()` with a minimal fixed argument set.
    - On RTOS targets: `main()` shall create the first user thread running `appMain()` and start the scheduler.

- [x] **FR-3:** On non-Linux targets, the framework shall provide a minimal C runtime adaptation layer to support
      application execution without a host operating system.
    - Heap memory shall be available through a statically allocated memory pool.
    - Unsupported I/O operations shall return error codes indicating no support.
    - The application shall be responsible for providing an output mechanism suitable for the target hardware.

- [x] **FR-4:** On RTOS targets, the framework shall provide the RTOS integration necessary to run `appMain()` as the
      first user thread.
    - The application thread stack size shall be configurable at compile time.
    - Both static and dynamic RTOS memory allocation models shall be supported.
    - Required RTOS internal resources (e.g., idle task, timer task) shall be provisioned by the framework when using
      static allocation.
    - Time queries shall use the RTOS tick count as the time source.

- [x] **FR-5:** On Linux, the framework shall optionally provide compile-time access to standard filesystem paths for
      the current installation: the installation prefix, system configuration directory, and shared data root directory,
      with values determined at build configuration time.

### Component: package

- [x] **FR-6:** The framework shall expose compile-time constants describing the build configuration: the compiler
      identity, compiler version (major, minor, and patch), and build type.

- [x] **FR-7:** The framework shall expose git repository metadata as runtime string values, captured at CMake
      configuration time:
    - Git tag, branch name, commit SHA, committer name, and committer email.
    - When git metadata is unavailable, all values shall fall back to `"N/A"`.
    - Metadata shall be refreshed at every CMake reconfiguration.

- [x] **FR-8:** The framework shall provide a function to print the git tag to standard output, and a function to print
      a formatted build summary including compiler, build type, git metadata, and build timestamp.

### Component: toolchain

- [x] **FR-9:** The framework shall configure the compiler, linker, and associated tools for the target platform,
      selectable via build system variables.

- [x] **FR-10:** For Linux targets, the framework shall support GCC and Clang compiler variants for both native
      compilation and cross-compilation to ARM64 targets.

- [x] **FR-11:** For non-Linux (ARM) targets, the framework shall support the appropriate cross-compilation toolchain.
      The path to the compiler shall be configurable.

- [x] **FR-12:** For ARM64 Linux cross-compilation, the path to the compiler shall be configurable.

- [x] **FR-13:** For Linux targets, the framework shall support enabling runtime sanitizers: address, leak, thread, and
      undefined behavior. Only one sanitizer may be enabled per build. Additional sanitizer behavior shall be
      configurable.

- [x] **FR-14:** For Linux targets, the framework shall support enabling code coverage instrumentation.

- [x] **FR-15:** The framework shall integrate with the OSAL library and automatically communicate the appropriate OSAL
      backend for the active platform, without requiring the user to specify it separately.

- [x] **FR-16:** For baremetal ARM and FreeRTOS ARM targets, the framework shall provide a CMake helper function to
      produce raw binary images from ELF outputs.

### CMake Integration

- [x] **FR-17:** The framework shall be integrable into dependent projects via `find_package(platform COMPONENTS ...)`.
    - Only components listed in `COMPONENTS` shall be processed and built.
    - The framework shall support FetchContent-based download from a Git repository.

## Non-Functional Requirements

- [x] **NFR-1:** All C++ code shall target the C++23 standard; all C code shall target C17.

- [x] **NFR-2:** All compiler warnings shall be treated as errors (`-Werror`). Warnings `-Wall`, `-Wextra`, and
      `-Wpedantic` shall be enabled.

- [x] **NFR-3:** C++ exceptions shall be disabled across all platforms (`-fno-exceptions`).

- [x] **NFR-4:** Debug builds shall use no optimization (`-O0 -g`) for Linux targets and size-optimized compilation
      (`-Os -g`) for ARM targets.

- [x] **NFR-5:** Release builds shall use full optimization (`-O3 -DNDEBUG`) for Linux targets and size-optimized
      compilation (`-Os -DNDEBUG`) for ARM targets.

- [x] **NFR-6:** Code coverage shall meet a minimum of 90% line coverage and 90% function coverage across the test
      suite.

## Technical Constraints and Requirements

- [ ] **TR-1:** The build system shall require CMake version 3.28 or higher.

- [ ] **TR-2:** The framework shall support the following target platforms: native Linux (x64), cross-compiled Linux
      (ARM64), baremetal ARM (ARMv7 Cortex-M4), and FreeRTOS ARM (ARMv7 Cortex-M4).

- [ ] **TR-3:** The supported FreeRTOS kernel version is `freertos-10.2.1`, selectable via the `FREERTOS_VERSION` CMake
      variable. The portable layer shall be selectable via `FREERTOS_PORTABLE`.

- [x] **TR-4:** All C++ code shall reside in the `platform::` namespace hierarchy.

- [x] **TR-5:** Code formatting shall conform to the project's clang-format configuration.

- [x] **TR-6:** All clang-tidy checks enabled in the project configuration shall pass with no warnings (treated as
      errors).

- [ ] **TR-7:** The CI pipeline shall validate builds on: native x64 GCC 13 and Clang 18 (debug/release), ARM64
      cross-compiled GCC 13 and Clang 18 (debug/release), all four sanitizer variants (ASAN, LSAN, TSAN, UBSAN),
      baremetal ARMv7-M4 (debug/release), and FreeRTOS ARMv7-M4 (debug/release).

- [x] **TR-8:** Linux native test builds shall be validated under Valgrind for memory safety.

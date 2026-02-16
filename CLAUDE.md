# platform

## Project Type and Technologies

* **Languages**: C17, C++23
* **Build System**: CMake 3.28+
* **Supported Platforms**: Linux (x64, ARM64), Baremetal ARM (Cortex-M), FreeRTOS ARM (Cortex-M/A)
* **Supported Compilers**: gcc-13, clang-18, arm-none-eabi-gcc-13
* **Testing Strategy**: Integration tests via example applications (no unit test framework)
* **CI/CD**: GitHub Actions with self-hosted runners
* **Code Quality**: clang-format, clang-tidy, Valgrind, sanitizers (ASAN/LSAN/TSAN/UBSAN)
* **Coverage Requirements**: 90% line coverage, 90% function coverage

## Repository Structure

### Major Directory Roles

**`cmake/`** - Build system configuration including global compilation flags, FetchContent-based component loader, Find
modules for package discovery, and composable CMake preset building blocks.

**`lib/main/`** - Platform-specific entry point abstraction. Each platform subdirectory (`linux/`, `baremetal-arm/`,
`freertos-arm/`) provides its own `main()` implementation that invokes `appMain()` appropriately. The FreeRTOS
subdirectory bundles FreeRTOS 10.2.1 kernel with portable layers for multiple ARM architectures.

**`lib/package/`** - Build and git metadata library. Provides runtime access to compiler information, build type, and
git repository metadata via code generation at build time.

**`lib/toolchain/`** - CMake toolchain files organized by platform. Sets up compiler, linker flags, cross-compilation
settings, and platform-specific variables like `OSAL_PLATFORM`.

**`examples/`** - Example applications demonstrating platform abstraction usage. These serve dual purpose as both usage
examples and integration tests in CI.

**`tools/`** - Development scripts for code formatting, static analysis, compilation database adjustments, and
documentation generation.

**`.devcontainer/`** - VS Code devcontainer configurations for four development environments: native x64 (GCC/Clang),
ARM64 Linux cross-compilation, and ARM embedded cross-compilation.

**`.github/workflows/`** - CI pipeline definitions for Linux builds/tests, baremetal builds, static analysis, and code
coverage enforcement.

## Architecture and Design

### Core Design Principles

**Compile-time platform abstraction via filesystem** - Platform-specific implementations live in peer subdirectories
named after the target platform (`linux/`, `baremetal-arm/`, `freertos-arm/`). The parent `CMakeLists.txt` selects the
appropriate implementation at configure time using `add_subdirectory(${PLATFORM})` where `PLATFORM` is a CMake cache
variable. This eliminates all runtime polymorphism and ensures only the relevant platform code is compiled.

**Entry point separation** - Application code implements `appMain(int argc, char* argv[])` instead of `main()`. The
`platform::main` library provides the real `main()` function, which handles platform-specific initialization and then
invokes `appMain()`. On Linux, this is a simple passthrough. On baremetal, it constructs synthetic arguments. On
FreeRTOS, it creates a task wrapping `appMain()` and starts the scheduler. This separation allows identical application
code to run across all platforms without modification.

**Two-stage component loading** - Platform consumption happens in two phases: (1) The `toolchain` component must be
loaded **before** `project()` to configure `CMAKE_TOOLCHAIN_FILE`, and (2) Runtime components (`main`, `package`) are
loaded **after** `project()`. This ordering is mandatory because CMake processes the toolchain file during `project()`
initialization.

**OBJECT library pattern for minimal code size** - Core libraries are built as OBJECT libraries with `EXCLUDE_FROM_ALL`.
Object files are linked directly into the final binary rather than being packaged into intermediate static libraries.
This is critical for embedded targets where every byte of flash matters, as it enables better dead code elimination and
avoids archive overhead.

**FetchContent-based component system** - The `Findplatform.cmake` module uses CMake's `FetchContent` to expose
individual components. Each component maps to a subdirectory under `lib/` via `SOURCE_SUBDIR`. Consumers request only
the components they need via `find_package(platform COMPONENTS ...)`, and FetchContent pulls just those subdirectories
from the source tree. This avoids building unused code and keeps consumer builds fast.

**Preset composition for configuration matrix** - CMake presets are composed from modular building blocks defined in
`cmake/presets/`. Base presets define platforms (`linux.json`, `baremetal.json`), build types (`type.json`), and
optional features (`app.json` for sanitizers). The top-level `CMakePresets.json` inherits from these to create 20
concrete presets covering the full configuration matrix. New configurations can be added by composing existing presets
without duplication.

**No runtime platform detection** - The `PLATFORM` variable is set at CMake configure time and never changes during
build or runtime. There are no `#ifdef LINUX` or `#ifdef BAREMETAL` checks in code. Platform selection is purely
structural (which subdirectory gets compiled) rather than conditional (which code paths are enabled).

### Key Components

#### Toolchain Component

**Problem it solves**: CMake needs to know the target platform's compiler, linker, and toolchain configuration before
processing any source code. Different platforms require completely different toolchains (native GCC/Clang for Linux, ARM
EABI GCC for embedded) and compiler flags (e.g., `-mcpu=cortex-m4 -mthumb` for ARM).

**How it works**: The `toolchain` component (`lib/toolchain/setup.cmake`) acts as a dispatcher. Based on the `PLATFORM`
cache variable, it sets `CMAKE_TOOLCHAIN_FILE` to point to the appropriate platform-specific toolchain file under
`lib/toolchain/<platform>/`. Each platform's toolchain file configures the compiler, defines architecture flags, sets
output directories, and derives `OSAL_PLATFORM` for downstream libraries. It also configures optional features like
sanitizers and coverage for Linux.

**Platform-specific behavior**:

* **Linux**: Supports native (x64) and cross-compilation (ARM64, Yocto SDK). Offers GCC and Clang variants with version
  selection. Includes sanitizer configurations (ASAN, LSAN, TSAN, UBSAN) and coverage instrumentation.
* **Baremetal ARM**: Uses ARM EABI GCC with Cortex-M4 flags: `-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb
  -Os`. Enables linker garbage collection for minimal binary size.
* **FreeRTOS ARM**: Same ARM EABI toolchain as baremetal, plus additional variables (`FREERTOS_VERSION`,
  `FREERTOS_PORTABLE`) for FreeRTOS kernel configuration.

**OSAL_PLATFORM mapping**: Downstream OSAL libraries use `OSAL_PLATFORM` to select their platform abstraction:

* `linux` → `linux`
* `baremetal-arm` → `none`
* `freertos-arm` → `freertos`

**Usage pattern**:

```cmake
list(APPEND CMAKE_MODULE_PATH "<path-to-platform>/cmake/modules")
find_package(platform COMPONENTS toolchain)  # MUST be before project()
project(my-app ASM C CXX)
```

#### Main Component

**Problem it solves**: Different platforms have fundamentally different ways of launching an application. Linux programs
start in `main(argc, argv)` with arguments from the shell. Baremetal programs start at a reset handler with no operating
system. FreeRTOS programs need a task created and the scheduler started before any application code runs. Writing
separate entry points for each platform forces code duplication and platform-specific conditionals.

**How it works**: The `platform::main` library (OBJECT library) provides the platform-specific `main()` implementation
and calls the platform-agnostic `appMain(int argc, char* argv[])` that applications implement. The build system includes
only the subdirectory matching `${PLATFORM}` using `add_subdirectory(${PLATFORM})`.

**Platform-specific behavior**:

* **Linux** (`lib/main/linux/main.cpp`): Direct passthrough. The `main()` function simply calls `appMain(argc, argv)`
  and returns its result. Also provides `platform::main-paths` library for FHS path discovery (`getInstallPrefixPath()`,
  `getSysConfPath()`, `getDataRootPath()`).
* **Baremetal ARM** (`lib/main/baremetal-arm/main.cpp`): Creates synthetic `argv` array with a single element `argv[0] =
  "appMain"`, then calls `appMain(1, argv)`. Provides minimal newlib syscall stubs (`_write`, `_sbrk`, `_exit`) and
  `objcopy_generate_bin()` CMake function for binary generation.
* **FreeRTOS ARM** (`lib/main/freertos-arm/main.cpp`): Creates a FreeRTOS task with a wrapper function that calls
  `appMain(1, argv)`, then invokes `vTaskStartScheduler()` which never returns. Supports both static and dynamic memory
  allocation. Links against the bundled FreeRTOS 10.2.1 kernel.

**Key pattern**: Application code is written once and knows nothing about the platform:

```cpp
int appMain(int argc, char* argv[]) {
    // Platform-agnostic application code
    return 0;
}
```

#### Package Component

**Problem it solves**: Applications often need to report build metadata (compiler version, build type, git commit) for
diagnostics, version strings, and debugging. This information exists at build time but needs to be accessible at
runtime. Manually maintaining version strings leads to staleness and inconsistency.

**How it works**: The `platform::package` library provides two categories of metadata:

1. **Build metadata** (`build.cpp`): Runtime detection of compiler vendor/version and build type via preprocessor
   macros. Functions include `compilerVendor()`, `compiler()`, `buildType()`, `printVersion()`, `printBuildInfo()`.

2. **Git metadata** (`git.cpp`): Git repository information extracted at build time. The `CMakeLists.txt` runs
   `getGitInfo.cmake` as a custom command, which invokes `git` commands and generates `git.hpp` from `git.hpp.in`
   template. Functions include `gitTag()`, `gitBranch()`, `gitCommit()`, `gitUserName()`, `gitUserEmail()`.

**Code generation pattern**: The `git.hpp` header is generated at build time, not checked into the repository. This
ensures it always reflects the current git state. The `getGitInfo.cmake` script executes:

```cmake
execute_process(COMMAND git describe --tags ...)
execute_process(COMMAND git rev-parse --abbrev-ref HEAD ...)
# etc.
```

**Usage example**:

```cpp
#include <platform/package/build.hpp>
#include <platform/package/git.hpp>

platform::package::printVersion(std::cout);
std::cout << "Commit: " << platform::package::gitCommit() << "\n";
```

#### FreeRTOS Integration

**What it provides**: A bundled FreeRTOS 10.2.1 kernel with portable layers for multiple ARM architectures, built as an
OBJECT library and automatically linked by the `platform::main` component when `PLATFORM=freertos-arm`.

**Architecture support**: Portable layers included for:

* **Cortex-M**: ARM_CM0, ARM_CM3, ARM_CM3_MPU, ARM_CM4F (used by STM32F4), ARM_CM7, ARM_CM23 (secure/non-secure),
  ARM_CM33 (secure/non-secure)
* **Cortex-A**: ARM_CA9, ARM_CA53_64_BIT

**Why bundled rather than fetched**: FreeRTOS portable layers require careful configuration and platform-specific
adaptations. Bundling ensures version consistency and allows platform-specific patches if needed. The kernel is small
enough that including it directly doesn't bloat the repository.

**Memory allocation**: The FreeRTOS integration supports both `heap_4.c` (dynamic allocation) and static allocation
schemes. The choice is made in `FreeRTOSConfig.h` which consumers must provide.

**Configuration**: Consumers provide `FreeRTOSConfig.h` defining `configCPU_CLOCK_HZ`, stack sizes, tick rate, etc. The
`platform::main` component uses this configuration when creating the task that wraps `appMain()`.

#### STM32F4 Support

**What it provides**: The `Findstm32f4xx.cmake` module fetches CMSIS 5 (ARM Cortex Microcontroller Software Interface
Standard), STM32F4 device package, and STM32F4 HAL driver from GitHub, then builds a `stm32f4xx` library target.

**Why separate from platform**: STM32F4 support is specific to one microcontroller family, while `platform` is intended
to be hardware-agnostic. Separating it into its own Find module keeps the core platform library clean and allows other
hardware vendors (e.g., NXP, TI) to add their own Find modules following the same pattern.

**Usage pattern**:

```cmake
find_package(stm32f4xx)
target_link_libraries(my-app PRIVATE stm32f4xx platform::main)
```

**What gets fetched**:

* CMSIS 5: Core headers for Cortex-M, DSP library, RTOS API
* STM32F4 CMSIS Device: Startup code, system initialization, peripheral register definitions
* STM32F4 HAL Driver: Hardware Abstraction Layer for GPIO, UART, SPI, I2C, timers, etc.

**Examples using it**: The `examples/init/baremetal-arm/` and `examples/init/freertos-arm/` demonstrate STM32F4
initialization including HAL setup, clock configuration, UART4 console, and GPIO.

#### Preset System

**What it provides**: A modular CMake preset architecture that composes 20 concrete build configurations from reusable
building blocks without duplication.

**Preset layers**:

1. **Platform presets** (`cmake/presets/linux.json`, `baremetal.json`): Define base configurations like
   `linux-native-gcc`, `linux-arm64-clang`, `baremetal-armv7-m4`, etc. Set `PLATFORM` variable and platform-specific
   cache entries.
2. **Build type presets** (`cmake/presets/type.json`): Define `debug` and `release` variants setting `CMAKE_BUILD_TYPE`.
3. **Feature presets** (`cmake/presets/app.json`): Define optional features like `asan`, `lsan`, `tsan`, `ubsan` for
   sanitizer support.

**Composition via inheritance**: The top-level `CMakePresets.json` defines concrete presets that inherit from multiple
layers:

```json
{
  "name": "linux-native-clang-debug-asan",
  "inherits": ["linux-native-clang", "debug", "asan"]
}
```

**Benefits**:

* **No duplication**: Shared configuration (e.g., compiler paths) defined once in base preset
* **Easy extension**: Add new platform by creating one new base preset
* **Matrix coverage**: All combinations of platform × build type × features without manual enumeration

### Key Design Patterns

#### Platform Abstraction via Filesystem

**Pattern**: Platform-specific code is organized into peer subdirectories named after the platform (`linux/`,
`baremetal-arm/`, `freertos-arm/`). The parent directory's `CMakeLists.txt` uses `add_subdirectory(${PLATFORM})` to
include only the implementation for the current platform.

**Why it's used**: This pattern eliminates all runtime polymorphism and `#ifdef` conditionals. The compiler only sees
code for one platform, enabling better optimization and preventing accidental cross-platform dependencies. It also makes
the codebase more maintainable by clearly separating platform-specific code from shared code.

**Example**:

```cmake
# lib/main/CMakeLists.txt
add_subdirectory(${PLATFORM})  # Includes linux/, baremetal-arm/, or freertos-arm/
```

**Benefits**:

* Compile-time selection: No runtime overhead
* Clear separation: Easy to identify platform-specific code
* Better optimization: Compiler sees only relevant code
* Prevents mistakes: Can't accidentally call Linux functions on baremetal

#### FetchContent-based Component System

**Pattern**: The `Findplatform.cmake` module declares components using `FetchContent_Declare()` with `SOURCE_SUBDIR`
pointing to subdirectories under `lib/`. When consumers call `find_package(platform COMPONENTS main)`, only the
requested component's subdirectory is populated and built.

**Why it's used**: Traditional CMake Find modules either require pre-installation of libraries or build everything in
the source tree. FetchContent provides a middle ground: selective source tree inclusion without requiring separate
installation steps. This keeps consumer builds fast and avoids building unused code.

**Example**:

```cmake
# Findplatform.cmake
FetchContent_Declare(platform-main
    SOURCE_DIR "${platform_SOURCE_DIR}"
    SOURCE_SUBDIR "lib/main"
)
FetchContent_MakeAvailable(platform-main)
```

**Benefits**:

* Selective builds: Only requested components are compiled
* No installation required: Source tree is used directly
* Standard CMake workflow: Consumers use familiar `find_package()`
* Fast iterations: Changes in platform repo are immediately visible

#### OBJECT Library Pattern

**Pattern**: Core libraries (`platform-main`, `freertos`) are created with `add_library(target OBJECT
EXCLUDE_FROM_ALL)`. Object files are referenced using `$<TARGET_OBJECTS:target>` or linked directly via
`target_link_libraries()`.

**Why it's used**: Embedded targets have severe flash size constraints. OBJECT libraries avoid creating intermediate
`.a` archives, which can interfere with link-time optimization and dead code elimination. They also prevent duplicate
symbols when the same object file needs to be linked into multiple targets.

**Example**:

```cmake
add_library(platform-main OBJECT EXCLUDE_FROM_ALL)
# Consumer links directly against object files
target_link_libraries(my-app PRIVATE platform::main)
```

**Benefits**:

* Minimal binary size: Better dead code elimination
* Faster linking: No intermediate archive creation
* Single compilation: Object files built once, used by multiple targets
* LTO friendly: Link-time optimizer sees all code

#### Preset Inheritance

**Pattern**: CMake presets are defined in multiple layers (platform, type, features) in separate JSON files. Concrete
presets in the root `CMakePresets.json` inherit from multiple base presets using the `"inherits": [...]` field.

**Why it's used**: The project supports 20 build configurations (8 Linux x64 + 4 Linux ARM64 + 4 Yocto + 4 embedded).
Without inheritance, each would require 20+ lines of duplicated JSON. With inheritance, adding a new sanitizer requires
adding just one base preset, and it automatically composes with all compatible platforms.

**Example**:

```json
// cmake/presets/app.json
{"name": "asan", "cacheVariables": {"SANITIZER": "address"}}

// CMakePresets.json
{"name": "linux-native-clang-debug-asan",
 "inherits": ["linux-native-clang", "debug", "asan"]}
```

**Benefits**:

* Configuration reuse: Platform settings defined once
* Matrix coverage: All valid combinations available
* Easy maintenance: Change compiler path in one place
* Clear intent: Preset names describe what they enable

#### Alias Targets

**Pattern**: All libraries define namespaced aliases using `add_library(platform::main ALIAS platform-main)`. Consumers
always link against the alias form (`platform::main`) rather than the real target name (`platform-main`).

**Why it's used**: Aliases provide namespace protection and make it obvious which targets are external dependencies.
They also allow the real target name to change (e.g., `platform-main` → `platform_main`) without breaking consumers.
CMake will error if an alias target doesn't exist, preventing typos from silently succeeding.

**Example**:

```cmake
# lib/main/CMakeLists.txt
add_library(platform-main OBJECT)
add_library(platform::main ALIAS platform-main)

# Consumer
target_link_libraries(my-app PRIVATE platform::main)  # OK
# target_link_libraries(my-app PRIVATE platform-main)  # Would work but discouraged
```

**Benefits**:

* Namespace clarity: Obvious which targets are external
* Typo protection: CMake errors on non-existent aliases
* Future-proof: Internal target names can change
* Convention alignment: Matches modern CMake best practices

### Key Conventions

#### Naming Conventions

**C++ Code** (enforced by clang-tidy):

* Classes: `CamelCase` (e.g., `BuildInfo`, `GitMetadata`)
* Abstract interfaces: `ICamelCase` prefixed with `I` (e.g., `ILogger`)
* Functions and variables: `camelBack` (e.g., `compilerVendor()`, `argc`)
* Private/protected members: `m_camelBack` prefixed with `m_` (e.g., `m_version`, `m_buffer`)
* Enums: `CamelCase` with `e` prefix for values (e.g., `enum class Color { eRed, eGreen }`)
* Macros: `UPPER_CASE` (e.g., `PLATFORM_VERSION_MAJOR`)
* Namespaces: `lower_case` (e.g., `namespace platform`, `namespace package`)

**CMake Targets**:

* Real targets: `<project>-<component>` (e.g., `platform-main`, `platform-package`)
* Alias targets: `<project>::<component>` (e.g., `platform::main`, `platform::package`)
* Internal targets: `<name>` without prefix (e.g., `freertos`, `stm32f4xx`)

**CMake Variables**:

* User-facing cache variables: `UPPER_CASE` (e.g., `PLATFORM`, `TOOLCHAIN`, `SANITIZER`)
* Internal variables: `lower_case` or `camelCase` (e.g., `platform_SOURCE_DIR`)
* Derived variables: `UPPER_CASE` (e.g., `OSAL_PLATFORM` derived from `PLATFORM`)

**Directories**:

* Platform names: `lower-case-with-dashes` (e.g., `baremetal-arm`, `freertos-arm`)
* Library components: `lower_case` (e.g., `main`, `package`, `toolchain`)
* Example applications: `lower-case-with-dashes` (e.g., `hello-world`, `package-info`)

#### CMake Patterns

**Component structure**: Each component under `lib/` has this structure:

```
lib/<component>/
├── CMakeLists.txt              # Creates platform-<component> OBJECT library + alias
├── include/<project>/<component>/  # Public headers
├── *.cpp                       # Shared implementation files
└── <platform>/                 # Platform-specific subdirectories
    ├── CMakeLists.txt
    └── *.cpp
```

**Platform selection**: Parent `CMakeLists.txt` includes platform-specific subdirectory:

```cmake
set(PLATFORM "linux" CACHE STRING "Target platform")
add_subdirectory(${PLATFORM})
```

**Toolchain configuration**: Always follows this pattern in consuming projects:

```cmake
list(APPEND CMAKE_MODULE_PATH "<path>/cmake/modules")
find_package(platform COMPONENTS toolchain)  # BEFORE project()
project(my-app)
find_package(platform COMPONENTS main package)  # AFTER project()
```

**Output directories**: All builds use:

```cmake
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
```

#### Code Standards

**Compiler warnings**: All builds use `-Wall -Wextra -Wpedantic -Werror`. Warnings are errors and must be fixed, not
suppressed. Use `#pragma GCC diagnostic` only for third-party headers.

**Language standards**: C17 for C code, C++23 for C++ code. Set via:

```cmake
set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 23)
```

**Exception handling**: C++ exceptions are globally disabled (`-fno-exceptions`). Do not use `throw`, `catch`, or `try`
in any code. Error handling uses return codes or assertions.

**Memory allocation**: Prefer stack allocation. Heap allocation (if necessary) uses `new`/`delete` manually; no
`unique_ptr` or `shared_ptr` since exception safety isn't needed.

**Header guards**: Use `#pragma once` consistently. No `#ifndef`-based include guards.

#### Platform Variable Mapping

**PLATFORM → OSAL_PLATFORM mapping** (set by toolchain component):

* `PLATFORM=linux` → `OSAL_PLATFORM=linux`
* `PLATFORM=baremetal-arm` → `OSAL_PLATFORM=none`
* `PLATFORM=freertos-arm` → `OSAL_PLATFORM=freertos`

**PLATFORM → main() implementation**:

* `PLATFORM=linux` → `lib/main/linux/main.cpp` (direct passthrough)
* `PLATFORM=baremetal-arm` → `lib/main/baremetal-arm/main.cpp` (synthetic argv)
* `PLATFORM=freertos-arm` → `lib/main/freertos-arm/main.cpp` (FreeRTOS task + scheduler)

**TOOLCHAIN → compiler selection** (per platform):

* Linux: `TOOLCHAIN=gcc|gcc-11|gcc-13|clang|clang-14|clang-18|aarch64-none-linux-gnu-gcc|aarch64-none-linux-gnu-clang`
* Baremetal/FreeRTOS ARM: `TOOLCHAIN=arm-none-eabi-gcc`

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

All containers are based on Ubuntu 24.04, mount host SSH keys and git config, and include VS Code extensions for C++,
CMake, Python, and Markdown.

Required tools: CMake 3.28+, a supported compiler (GCC 13 or Clang 18 for native, ARM toolchains for cross-compilation),
and Git.

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

All builds use: `-Wall -Wextra -Wpedantic -Werror` with C17 and C++23 standards. C++ exceptions are disabled
(`-fno-exceptions`). Embedded builds add `-Os -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb` with linker
section garbage collection.

### Testing

There is no unit test framework. Testing is done via integration tests using example applications:

* **`platform-hello-world-example`** - basic compilation and platform abstraction verification
* **`platform-package-info-example`** - build and git metadata retrieval
* **`platform-paths-example`** - FHS path resolution (Linux/Unix only)

These examples are built and executed across multiple platforms and configurations in CI. Memory safety and correctness
are validated through:

* **Valgrind** - heap memory profiling on x64
* **ASAN** - address/memory corruption detection
* **LSAN** - memory leak detection
* **TSAN** - data race detection
* **UBSAN** - undefined behavior detection

Code coverage is collected using `gcov` (GCC) with enforced thresholds of **90% line coverage** and **90% function
coverage**.

### Code Style

Code formatting is enforced by **clang-format** (120 column limit, 4-space indent). Static analysis is enforced by
**clang-tidy** with a comprehensive set of checks and strict naming conventions:

* Classes: `CamelCase`, abstract classes: `ICamelCase` (prefixed with `I`)
* Functions/variables: `camelBack`
* Private/protected members: `m_camelBack` (prefixed with `m_`)
* Enums: `CamelCase` with `e` prefix for values
* Macros: `UPPER_CASE`
* Namespaces: `lower_case`

Run locally:

```bash
./tools/check-clang-format.sh    # Check formatting
./tools/check-clang-tidy.sh      # Run static analysis (requires compile_commands.json)
```

### CI

CI runs on GitHub Actions with self-hosted runners. All workflows trigger on push, weekly schedule (Saturday 12:00 UTC),
and manual dispatch.

**`build-test-linux.yml`** - Linux build and test pipeline:

* `build-x64`: builds all 8 Linux x64 presets (GCC/Clang, debug/release, sanitizers)
* `build-arm64`: cross-compiles 4 ARM64 presets
* `examples-x64`: runs 3 example binaries on x64
* `examples-arm64`: runs 3 example binaries on real ARM64 hardware
* `valgrind-x64`: memory profiling for all examples
* `sanitizers-x64`: runs all examples through each of the 4 sanitizers
* `check-all-linux`: gate job requiring all above to pass

**`build-test-baremetal.yml`** - Embedded build pipeline:

* `build-stm32f4`: compiles 4 embedded presets (baremetal + FreeRTOS, debug + release)
* Hardware test jobs exist but are currently commented out (STM32F4 Discovery via OpenOCD)
* `check-all-baremetal`: gate job

**`static-analysis.yml`** - Code quality pipeline:

* `formatting`: clang-format check
* `linting`: clang-tidy on `linux-native-clang-debug` preset
* `check-all-static`: gate job

**`code-coverage.yml`** - Coverage pipeline:

* `build-coverage`: builds with coverage instrumentation
* `test-coverage`: collects coverage for each example binary
* `generate-coverage-report`: validates 90% line and function coverage thresholds
* `check-all-coverage`: gate job

## Important Notes

* The `toolchain` component must be found **before** `project()` in consuming CMakeLists.txt, because it sets
  `CMAKE_TOOLCHAIN_FILE` which CMake processes during `project()`.
* The `PLATFORM` variable (linux, baremetal-arm, freertos-arm) is set via CMake presets or cache. It determines which
  platform-specific code is compiled. There is no runtime platform detection.
* `OSAL_PLATFORM` is derived from `PLATFORM` and is used by downstream OSAL libraries: `linux` maps to `linux`,
  `baremetal-arm` maps to `none`, `freertos-arm` maps to `freertos`.
* C++ exceptions are globally disabled. Do not use `throw`/`catch` in any code.
* All compiler warnings are treated as errors (`-Werror`). New code must compile cleanly.
* The `examples/` directory serves dual purpose: demonstrating usage and acting as integration tests in CI.
* FreeRTOS 10.2.1 is bundled directly in the source tree (not fetched externally), with portable layers for multiple ARM
  architectures.
* Embedded toolchains expect specific paths under `/opt/toolchains/` as configured in the devcontainers and CI Docker
  images.
* Build artifacts go to `${CMAKE_BINARY_DIR}/bin` (executables) and `${CMAKE_BINARY_DIR}/lib` (libraries).

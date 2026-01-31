# Overview

Platform project creates an easy-to-use abstraction for launching applications on various OS platforms. Its main goal is
to provide:

* compiler configuration for target platform,
* abstraction of launching main application thread on target platform.

Compiler configuration is provided via CMake toolchain file. It's aim is to set all required CMake variables in order to
allow cross-compilation to the target platform. It also handles the basic set of compilation and linking flags for
particular platform/compiler pair.

Launching main application thread is implemented by distinguishing the `main()` function from the main thread. On
desktop systems first app thread is executing directly code from `main()`. On systems where a dedicated scheduler is
launched (e.g. baremetal RTOS), it is required that in the first thread user has to call some sort of "scheduler start"
function, which usually never returns (at least until all threads are destroyed). Previously mentioned separation
requires, that the main application logic should be placed in `appMain()` function. On desktop systems this function
would be called directly from `main()`. On RTOS systems, this function would be used as feed for a new user thread.

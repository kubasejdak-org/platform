/////////////////////////////////////////////////////////////////////////////////////
///
/// @file
/// @author Kuba Sejdak
/// @copyright MIT License
///
/// Copyright (c) 2026 Kuba Sejdak (kuba.sejdak@gmail.com)
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///
/////////////////////////////////////////////////////////////////////////////////////

#include "platform/package/build.hpp"

#include "platform/package/git.hpp"

#include <format>
#include <iostream>

namespace platform {

void printVersion()
{
    std::cout << gitTag() << "\n";
}

void printBuildInfo()
{
#if defined(__clang__)
    auto compiler = std::format("clang-{}.{}.{}", __clang_major__, __clang_minor__, __clang_patchlevel__);
#elif defined(__GNUC__) || defined(__GNUG__)
    auto compiler = std::format("gcc-{}.{}.{}", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__);
#endif

#ifdef NDEBUG
    const auto* buildType = "release";
#else
    const auto* buildType = "debug";
#endif

    std::cout << "Build info:\n";
    std::cout << std::format("    compiler : {}\n", compiler);
    std::cout << std::format("    type     : {}\n", buildType);
    std::cout << std::format("    tag      : {}\n", gitTag());
    std::cout << std::format("    branch   : {}\n", gitBranch());
    std::cout << std::format("    user     : {} ({})\n", gitUserName(), gitUserEmail());
    std::cout << std::format("    date     : {} {}\n", __DATE__, __TIME__);
}

} // namespace platform

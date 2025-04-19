/////////////////////////////////////////////////////////////////////////////////////
///
/// @file
/// @author Kuba Sejdak
/// @copyright MIT License
///
/// Copyright (c) 2019-2025 Kuba Sejdak (kuba.sejdak@gmail.com)
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

#include <platform/init.hpp>
#include <platform/package/build.hpp>
#include <platform/package/git.hpp>

#include <cstdlib>
#include <format>
#include <iostream>

int appMain(int argc, char** argv)
{
    if (!platform::init())
        return EXIT_FAILURE;

    std::cout << "Build info:\n";
    std::cout << std::format("    compiler       : {}\n", platform::compiler());
    std::cout << std::format("    build type     : {}\n", platform::buildType());

    std::cout << "Using platform:\n";
    std::cout << std::format("    git tag        : {}\n", platform::gitTag());
    std::cout << std::format("    git branch     : {}\n", platform::gitBranch());
    std::cout << std::format("    git commit     : {}\n", platform::gitCommit());
    std::cout << std::format("    git user name  : {}\n", platform::gitUserName());
    std::cout << std::format("    git user email : {}\n", platform::gitUserEmail());

    for (int i = 0; i < argc; ++i)
        std::cout << std::format("argv[{}] = '{}'\n", i, argv[i]);

    std::cout << "PASSED\n";
    return EXIT_SUCCESS;
}

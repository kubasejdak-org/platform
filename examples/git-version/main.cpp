/////////////////////////////////////////////////////////////////////////////////////
///
/// @file
/// @author Kuba Sejdak
/// @copyright MIT License
///
/// Copyright (c) 2019-2024 Kuba Sejdak (kuba.sejdak@gmail.com)
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

#include <platform/git.hpp>
#include <platform/init.hpp>

#include <cstdio>
#include <cstdlib>

// NOLINTNEXTLINE
int appMain(int argc, char* argv[])
{
    if (!platform::init())
        return EXIT_FAILURE;

    std::printf("Using platform:\n");
    std::printf("    git tag        : %s\n", platform::gitTag().data());
    std::printf("    git branch     : %s\n", platform::gitBranch().data());
    std::printf("    git commit     : %s\n", platform::gitCommit().data());
    std::printf("    git user name  : %s\n", platform::gitUserName().data());
    std::printf("    git user email : %s\n", platform::gitUserEmail().data());

    for (int i = 0; i < argc; ++i)
        std::printf("argv[%d] = '%s'\n", i, argv[0]);

    std::printf("PASSED\n");
    return EXIT_SUCCESS;
}

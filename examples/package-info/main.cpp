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
#include <iostream>

int appMain(int argc, char** argv)
{
    if (!platform::init())
        return EXIT_FAILURE;

    std::cout << "Build info:\n";
    std::cout << "    compiler       : " << platform::compiler() << "\n";
    std::cout << "    build type     : " << platform::buildType() << "\n";

    std::cout << "Using platform:\n";
    std::cout << "    git tag        : " << platform::gitTag() << "\n";
    std::cout << "    git branch     : " << platform::gitBranch() << "\n";
    std::cout << "    git commit     : " << platform::gitCommit() << "\n";
    std::cout << "    git user name  : " << platform::gitUserName() << "\n";
    std::cout << "    git user email : " << platform::gitUserEmail() << "\n";

    for (int i = 0; i < argc; ++i)
        std::cout << "argv[" << i << "] = '" << argv[i] << "'\n";

    std::cout << "PASSED\n";
    return EXIT_SUCCESS;
}

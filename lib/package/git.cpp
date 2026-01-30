/////////////////////////////////////////////////////////////////////////////////////
///
/// @file
/// @author Kuba Sejdak
/// @copyright MIT License
///
/// Copyright (c) 2023 Kuba Sejdak (kuba.sejdak@gmail.com)
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

#include "platform/package/git.hpp"
#if __has_include("git.hpp")
    #include "git.hpp"
#else
    #define PLATFORM_GIT_TAG        "N/A" // NOLINT
    #define PLATFORM_GIT_BRANCH     "N/A" // NOLINT
    #define PLATFORM_GIT_COMMIT     "N/A" // NOLINT
    #define PLATFORM_GIT_USER_NAME  "N/A" // NOLINT
    #define PLATFORM_GIT_USER_EMAIL "N/A" // NOLINT
#endif

#include <string_view>

namespace platform {

std::string_view gitTag()
{
    return PLATFORM_GIT_TAG;
}

std::string_view gitBranch()
{
    return PLATFORM_GIT_BRANCH;
}

std::string_view gitCommit()
{
    return PLATFORM_GIT_COMMIT;
}

std::string_view gitUserName()
{
    return PLATFORM_GIT_USER_NAME;
}

std::string_view gitUserEmail()
{
    return PLATFORM_GIT_USER_EMAIL;
}

} // namespace platform

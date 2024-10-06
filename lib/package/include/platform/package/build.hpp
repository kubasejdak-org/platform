/////////////////////////////////////////////////////////////////////////////////////
///
/// @file
/// @author Kuba Sejdak
/// @copyright MIT License
///
/// Copyright (c) 2024-2024 Kuba Sejdak (kuba.sejdak@gmail.com)
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

#pragma once

#include <sstream>
#include <string>
#include <string_view>

namespace platform {

/// Returns compiler vendor name (gcc/clang/unsupported).
/// @return Compiler vendor name (gcc/clang/unsupported).
constexpr std::string_view compilerVendor()
{
#if defined(__GNUC__) || defined(__GNUG__)
    return "gcc";
#elif defined(__clang__)
    return "clang";
#else
    return "unsupported";
#endif
}

/// Returns compiler major version.
/// @return Compiler major version.
constexpr int compilerMajor()
{
#if defined(__GNUC__) || defined(__GNUG__)
    return __GNUC__;
#elif defined(__clang__)
    return __clang_major__;
#else
    return 0;
#endif
}

/// Returns compiler minor version.
/// @return compiler minor version.
constexpr int compilerMinor()
{
#if defined(__GNUC__) || defined(__GNUG__)
    return __GNUC_MINOR__;
#elif defined(__clang__)
    return __clang_minor__;
#else
    return 0;
#endif
}

/// Returns compiler patch version.
/// @return compiler patch version.
constexpr int compilerPatch()
{
#if defined(__GNUC__) || defined(__GNUG__)
    return __GNUC_PATCHLEVEL__;
#elif defined(__clang__)
    return __clang_patchlevel__;
#else
    return 0;
#endif
}

/// Return compiler name with version.
/// @return Compiler name with version.
inline std::string compiler()
{
    if (compilerVendor() == "unsupported")
    {
        return "unsupported";
    }

    std::stringstream ss;
    ss << compilerVendor() << "-" << compilerMajor() << "." << compilerMinor() << "." << compilerPatch();
    return ss.str();
}

/// Returns build type (debug/release).
/// @return Build type (debug/release).
constexpr std::string_view buildType()
{
#ifdef NDEBUG
    return "release";
#else
    return "debug";
#endif
}

} // namespace platform

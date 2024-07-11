/////////////////////////////////////////////////////////////////////////////////////
///
/// @file
/// @author Kuba Sejdak
/// @copyright MIT License
///
/// Copyright (c) 2017-2024 Kuba Sejdak (kuba.sejdak@gmail.com)
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

#include <sys/time.h>
#include <sys/types.h>

#include <array>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <ctime>
#include <type_traits>

/// Implements the console capability by defining what should happen with messages intended for stdout.
/// @param message      Message to be printed.
/// @param size         Size of the message.
/// @return Number of processed bytes.
/// @note This function is called by the _write() syscall.
extern int consolePrint(const char* message, std::size_t size);

extern "C" {

// NOLINTNEXTLINE
caddr_t _sbrk(intptr_t increment)
{
    constexpr int cBufferSize = 2 * 1024;
    static std::array<char, cBufferSize> buffer;
    static std::size_t offset = 0;

    std::size_t prevOffset = offset;

    if (offset + increment > buffer.size())
        return nullptr;

    offset += increment;
    return reinterpret_cast<caddr_t>(&buffer.at(prevOffset));
}

// NOLINTNEXTLINE
int _write(int /*unused*/, const void* buf, size_t count)
{
    return consolePrint(reinterpret_cast<const char*>(buf), count);
}

size_t fwrite(const void* ptr, size_t /*unused*/, size_t nmemb, FILE* /*unused*/)
{
    return _write(0, std::remove_const_t<char*>(ptr), nmemb);
}

// NOLINTNEXTLINE
int _gettimeofday(struct timeval* tp, void* /*unused*/)
{
    if (tp != nullptr) {
        tp->tv_usec = 0;
        tp->tv_sec = 0;
    }

    return 0;
}

time_t timegm(struct tm* tm)
{
    return mktime(tm);
}

} // extern "C"

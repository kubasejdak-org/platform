/////////////////////////////////////////////////////////////////////////////////////
///
/// @file
/// @author Kuba Sejdak
/// @copyright MIT License
///
/// Copyright (c) 2017 Kuba Sejdak (kuba.sejdak@gmail.com)
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

#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <sys/stat.h>
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

int _write(int /*unused*/, const void* buf, size_t count)
{
    return consolePrint(reinterpret_cast<const char*>(buf), count);
}

int _open(const char* /*unused*/, int /*unused*/, int /*unused*/)
{
    return -1; // Not supported
}

int _close(int /*unused*/)
{
    return -1; // Not supported
}

int _read(int /*unused*/, void* /*unused*/, size_t /*unused*/)
{
    return -1; // Not supported
}

int _fstat(int /*unused*/, struct stat* /*unused*/)
{
    return -1; // Not supported
}

int _isatty(int /*unused*/)
{
    return 1; // Treat all file descriptors as TTY
}

int _lseek(int /*unused*/, int /*unused*/, int /*unused*/)
{
    return -1; // Not supported
}

int _getpid()
{
    return 1; // Single process system
}

int _kill(int /*unused*/, int /*unused*/)
{
    return -1; // Not supported
}

size_t fwrite(const void* ptr, size_t /*unused*/, size_t nmemb, FILE* /*unused*/)
{
    return _write(0, std::remove_const_t<char*>(ptr), nmemb);
}

int _gettimeofday(struct timeval* tp, void* /*unused*/)
{
    if (tp != nullptr) {
        constexpr std::uint32_t cUsInMs = 1000;
        constexpr std::uint32_t cUsInSec = 1000000;
        auto nowUs = static_cast<std::uint32_t>(xTaskGetTickCount()) * cUsInMs;
        auto nowSec = nowUs / cUsInSec;
        tp->tv_usec = nowUs - (nowSec * cUsInSec);
        tp->tv_sec = nowSec;
    }

    return 0;
}

time_t timegm(struct tm* tm)
{
    return mktime(tm);
}

} // extern "C"

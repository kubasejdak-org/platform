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

#include "platform/init.hpp"

#include <stm32f4xx.h>

#include <cstddef>
#include <cstdint>
#include <type_traits>

// NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)
UART_HandleTypeDef uart{};

extern "C" {

void HAL_MspInit()
{
    __HAL_RCC_SYSCFG_CLK_ENABLE(); // NOLINT
    __HAL_RCC_PWR_CLK_ENABLE();    // NOLINT
}

void HAL_UART_MspInit(UART_HandleTypeDef* /*unused*/)
{
    __HAL_RCC_GPIOC_CLK_ENABLE(); // NOLINT

    GPIO_InitTypeDef config{};
    config.Pin = GPIO_PIN_10;
    config.Mode = GPIO_MODE_AF_PP;
    config.Pull = GPIO_PULLUP;
    config.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    config.Alternate = GPIO_AF8_UART4;
    HAL_GPIO_Init(GPIOC, &config); // NOLINT
}

} // extern "C"

int consolePrint(const char* message, std::size_t size)
{
    constexpr std::uint32_t cTimeout = 1000;
    auto result = HAL_UART_Transmit(&uart, std::remove_const_t<std::uint8_t*>(message), size, cTimeout);
    return (result == HAL_OK) ? int(size) : 0;
}

static bool consoleInitUart()
{
    __HAL_RCC_UART4_CLK_ENABLE(); // NOLINT

    uart.Instance = UART4; // NOLINT
    constexpr std::uint32_t cConsoleBaudrate = 115200;
    uart.Init.BaudRate = cConsoleBaudrate;
    uart.Init.WordLength = UART_WORDLENGTH_8B;
    uart.Init.StopBits = UART_STOPBITS_1;
    uart.Init.Parity = UART_PARITY_NONE;
    uart.Init.Mode = UART_MODE_TX;
    uart.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    uart.Init.OverSampling = UART_OVERSAMPLING_16;
    auto result = HAL_UART_Init(&uart);
    return result == HAL_OK;
}

namespace platform {

bool init()
{
    if (HAL_Init() != HAL_OK)
        return false;

    return consoleInitUart();
}

} // namespace platform

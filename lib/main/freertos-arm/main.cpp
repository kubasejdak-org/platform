/////////////////////////////////////////////////////////////////////////////////////
///
/// @file
/// @author Kuba Sejdak
/// @copyright MIT License
///
/// Copyright (c) 2019 Kuba Sejdak (kuba.sejdak@gmail.com)
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

#include <array>
#include <cstdlib>
#include <type_traits>

#if configSUPPORT_STATIC_ALLOCATION
extern "C" void vApplicationGetIdleTaskMemory(StaticTask_t** ppxIdleTaskTCBBuffer,
                                              StackType_t** ppxIdleTaskStackBuffer,
                                              uint32_t* pulIdleTaskStackSize)
{
    /* If the buffers to be provided to the Idle task are declared inside this
    function then they must be declared static – otherwise they will be allocated on
    the stack and so not exists after this function exits. */
    static StaticTask_t xIdleTaskTCB;
    static StackType_t uxIdleTaskStack[configMINIMAL_STACK_SIZE];

    /* Pass out a pointer to the StaticTask_t structure in which the Idle task’s
    state will be stored. */
    *ppxIdleTaskTCBBuffer = &xIdleTaskTCB;

    /* Pass out the array that will be used as the Idle task’s stack. */
    *ppxIdleTaskStackBuffer = uxIdleTaskStack;

    /* Pass out the size of the array pointed to by *ppxIdleTaskStackBuffer.
    Note that, as the array is necessarily of type StackType_t,
    configMINIMAL_STACK_SIZE is specified in words, not bytes. */
    *pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}

    #if configUSE_TIMERS
extern "C" void vApplicationGetTimerTaskMemory(StaticTask_t** ppxTimerTaskTCBBuffer,
                                               StackType_t** ppxTimerTaskStackBuffer,
                                               uint32_t* pulTimerTaskStackSize)
{
    /* If the buffers to be provided to the Timer task are declared inside this
    function then they must be declared static – otherwise they will be allocated on
    the stack and so not exists after this function exits. */
    static StaticTask_t xTimerTaskTCB;
    static StackType_t uxTimerTaskStack[configTIMER_TASK_STACK_DEPTH];

    /* Pass out a pointer to the StaticTask_t structure in which the Timer
    task’s state will be stored. */
    *ppxTimerTaskTCBBuffer = &xTimerTaskTCB;

    /* Pass out the array that will be used as the Timer task’s stack. */
    *ppxTimerTaskStackBuffer = uxTimerTaskStack;

    /* Pass out the size of the array pointed to by *ppxTimerTaskStackBuffer.
    Note that, as the array is necessarily of type StackType_t,
    configTIMER_TASK_STACK_DEPTH is specified in words, not bytes. */
    *pulTimerTaskStackSize = configTIMER_TASK_STACK_DEPTH;
}
    #endif
#endif

/// Main application entry point.
/// @param argc         Number of the commandline arguments.
/// @param argv         Array of commandline arguments containing argc strings.
/// @return Exit code of the application.
/// @note This function should be provided/implemented by the application.
extern int appMain(int argc, char** argv);

/// Default name that is passed to the application as argv[0].
constexpr const char* cMainThreadName = "appMain";

/// Wrapper thread that will execute the main application code.
static void mainThread(void* /*unused*/)
{
    std::array<char*, 1> appArgv = {std::remove_const_t<char*>(cMainThreadName)};
    appMain(appArgv.size(), appArgv.data());
}

/// Main executable entry point.
/// @return Exit code of the application.
/// @note This function passes one hardcoded commandline argument to the application, to fulfill the requirement
/// that argv[0] contains the name of the binary.
/// @note Depending on the value of the configSUPPORT_STATIC_ALLOCATION and configSUPPORT_DYNAMIC_ALLOCATION
/// macro definitions (which should be defined in the FreeRTOSConfig.h in the application code), this function creates
/// the application thread using static or dynamic API of the FreeRTOS threading module.
int main()
{
    static TaskHandle_t thread = nullptr;
#if configSUPPORT_STATIC_ALLOCATION
    static StaticTask_t threadBuffer{};
    static std::array<StackType_t, APPMAIN_STACK_SIZE> stack{};

    thread = xTaskCreateStatic(mainThread,
                               cMainThreadName,
                               stack.size(),
                               nullptr,
                               tskIDLE_PRIORITY,
                               stack.data(),
                               &threadBuffer);
    if (thread == nullptr)
        return EXIT_FAILURE;

#elif configSUPPORT_DYNAMIC_ALLOCATION
    auto result = xTaskCreate(mainThread, cMainThreadName, APPMAIN_STACK_SIZE, nullptr, tskIDLE_PRIORITY, &thread);
    if (result != pdPASS)
        return EXIT_FAILURE;
#endif

    vTaskStartScheduler();
    return EXIT_SUCCESS;
}

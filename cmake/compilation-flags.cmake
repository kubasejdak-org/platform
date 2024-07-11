add_compile_options(-Wall -Wextra -Wpedantic -Werror "$<$<COMPILE_LANGUAGE:C>:-std=c17>" "$<$<COMPILE_LANGUAGE:CXX>:-std=c++23;-fno-exceptions>")

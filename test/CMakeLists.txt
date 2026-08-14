cmake_minimum_required(VERSION 3.14)
project(p101_tool_support_tests C CXX)
enable_testing()

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
add_compile_definitions(_POSIX_C_SOURCE=200809L)

option(P101_TEST_COVERAGE "Instrument the code under test" OFF)
set(P101_COVERAGE_FLAGS "")
if(P101_TEST_COVERAGE)
    set(P101_COVERAGE_FLAGS --coverage)
endif()

set(P101_PUBLIC_INCLUDE_DIRS "" CACHE STRING "Extra p101 include dirs")
set(P101_PUBLIC_LINK_DIRS "" CACHE STRING "Extra p101 link dirs")
separate_arguments(P101_PUBLIC_INCLUDE_DIRS_LIST NATIVE_COMMAND "${P101_PUBLIC_INCLUDE_DIRS}")
separate_arguments(P101_PUBLIC_LINK_DIRS_LIST NATIVE_COMMAND "${P101_PUBLIC_LINK_DIRS}")
foreach(library IN ITEMS ERROR JSON RECORD)
    string(TOLOWER "${library}" library_name)
    find_library(P101_${library}_LIBRARY NAMES p101_${library_name} PATHS ${P101_PUBLIC_LINK_DIRS_LIST} NO_DEFAULT_PATH)
    if(NOT P101_${library}_LIBRARY)
        find_library(P101_${library}_LIBRARY NAMES p101_${library_name})
    endif()
    if(NOT P101_${library}_LIBRARY)
        message(FATAL_ERROR "Could not find p101_${library_name}")
    endif()
endforeach()

add_library(p101_tool_support_under_test STATIC
        ../src/diagnostic.c
        ../src/lesson_catalog.c
        ../src/receipt.c
        ../src/report.c)
target_include_directories(p101_tool_support_under_test PUBLIC
        ../include
        ${P101_PUBLIC_INCLUDE_DIRS_LIST})
target_compile_definitions(p101_tool_support_under_test PRIVATE P101_TOOL_SUPPORT_TESTING=1)
target_compile_options(p101_tool_support_under_test PRIVATE ${P101_COVERAGE_FLAGS})
target_link_libraries(p101_tool_support_under_test PUBLIC
        ${P101_ERROR_LIBRARY}
        ${P101_JSON_LIBRARY}
        ${P101_RECORD_LIBRARY})

foreach(test_name IN ITEMS diagnostic receipt report)
    add_executable(test_${test_name} test_${test_name}.c)
    target_link_libraries(test_${test_name} PRIVATE p101_tool_support_under_test)
    target_compile_options(test_${test_name} PRIVATE ${P101_COVERAGE_FLAGS})
    target_link_options(test_${test_name} PRIVATE ${P101_COVERAGE_FLAGS})
    add_test(NAME test_${test_name} COMMAND test_${test_name})
endforeach()

add_executable(p101_receipt_cli_under_test ../src/receipt_cli.c)
target_link_libraries(p101_receipt_cli_under_test PRIVATE p101_tool_support_under_test)
target_compile_options(p101_receipt_cli_under_test PRIVATE ${P101_COVERAGE_FLAGS})
target_link_options(p101_receipt_cli_under_test PRIVATE ${P101_COVERAGE_FLAGS})

add_executable(p101_receipt_fixture receipt_fixture.c)
target_link_libraries(p101_receipt_fixture PRIVATE p101_tool_support_under_test)
target_compile_options(p101_receipt_fixture PRIVATE ${P101_COVERAGE_FLAGS})
target_link_options(p101_receipt_fixture PRIVATE ${P101_COVERAGE_FLAGS})

add_test(NAME test_receipt_cli
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/test_receipt_cli.sh"
                "$<TARGET_FILE:p101_receipt_cli_under_test>"
                "$<TARGET_FILE:p101_receipt_fixture>")

add_executable(test_headers_cxx test_headers.cpp)
target_include_directories(test_headers_cxx PRIVATE ../include ${P101_PUBLIC_INCLUDE_DIRS_LIST})
target_link_libraries(test_headers_cxx PRIVATE p101_tool_support_under_test)
add_test(NAME test_headers_cxx COMMAND test_headers_cxx)

if(CMAKE_C_COMPILER_ID MATCHES "Clang|GNU")
    target_compile_options(p101_tool_support_under_test PRIVATE -Wall -Wextra -Werror -pedantic-errors)
    foreach(test_name IN ITEMS diagnostic receipt report)
        target_compile_options(test_${test_name} PRIVATE -Wall -Wextra -Werror -pedantic-errors)
    endforeach()
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    target_compile_options(test_headers_cxx PRIVATE -Wall -Wextra -Werror -pedantic-errors)
endif()

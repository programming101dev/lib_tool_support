set(PROJECT_NAME "p101_tool_support")
set(PROJECT_VERSION "0.0.1")
set(PROJECT_DESCRIPTION "Shared diagnostics, lesson routing, reports, and receipts")
set(PROJECT_LANGUAGE "C")

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(STANDARD_FLAGS -D_POSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700 -Werror)
set(DARWIN_STANDARD_FLAGS -D_DARWIN_C_SOURCE)
set(LINUX_STANDARD_FLAGS -D_GNU_SOURCE)
set(BSD_STANDARD_FLAGS -D_BSD_SOURCE -D__BSD_VISIBLE)

set(LIBRARY_TARGETS p101_tool_support)
set(EXECUTABLE_TARGETS p101_receipt)
set(p101_tool_support_SOURCES src/diagnostic.c src/lesson_catalog.c src/receipt.c src/report.c)
set(p101_tool_support_HEADERS
        include/p101_tool_support/diagnostic.h
        include/p101_tool_support/lesson_catalog.h
        include/p101_tool_support/receipt.h
        include/p101_tool_support/report.h)
set(p101_tool_support_LINK_LIBRARIES p101_error p101_json p101_record)
set(p101_receipt_SOURCES src/receipt_cli.c)
set(p101_receipt_OUTPUT_NAME p101-tool-receipt)
set(p101_receipt_LINK_LIBRARIES p101_tool_support p101_error)

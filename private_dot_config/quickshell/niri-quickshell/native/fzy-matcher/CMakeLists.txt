cmake_minimum_required(VERSION 3.21)
project(NiriQuickshellFzyMatcher LANGUAGES C CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)

qt_standard_project_setup(REQUIRES 6.5)

set(FZY_GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/fzy)
set(FZY_GENERATED_SRC_DIR ${FZY_GENERATED_DIR}/src)
file(MAKE_DIRECTORY ${FZY_GENERATED_SRC_DIR})
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/fzy/src/config.def.h
    ${FZY_GENERATED_DIR}/config.h
    COPYONLY
)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/fzy/src/match.c
    ${FZY_GENERATED_SRC_DIR}/match.c
    COPYONLY
)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/fzy/src/match.h
    ${FZY_GENERATED_SRC_DIR}/match.h
    COPYONLY
)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/fzy/src/bonus.h
    ${FZY_GENERATED_SRC_DIR}/bonus.h
    COPYONLY
)

qt_add_library(niriquickshellfzymatcherplugin MODULE
    src/fzymatcher.h
    src/fzymatcher.cpp
    src/plugin.cpp
    ${FZY_GENERATED_SRC_DIR}/match.c
)

target_include_directories(niriquickshellfzymatcherplugin PRIVATE
    ${FZY_GENERATED_SRC_DIR}
)

target_link_libraries(niriquickshellfzymatcherplugin PRIVATE
    Qt6::Core
    Qt6::Qml
)

set_target_properties(niriquickshellfzymatcherplugin PROPERTIES
    OUTPUT_NAME niriquickshellfzymatcherplugin
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/NiriQuickshell/FzyMatcher
)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/NiriQuickshell/FzyMatcher)
file(WRITE ${CMAKE_BINARY_DIR}/NiriQuickshell/FzyMatcher/qmldir
"module NiriQuickshell.FzyMatcher\nplugin niriquickshellfzymatcherplugin\nclassname NiriQuickshellFzyMatcherPlugin\n")

install(TARGETS niriquickshellfzymatcherplugin
    LIBRARY DESTINATION NiriQuickshell/FzyMatcher
)
install(FILES ${CMAKE_BINARY_DIR}/NiriQuickshell/FzyMatcher/qmldir
    DESTINATION NiriQuickshell/FzyMatcher
)

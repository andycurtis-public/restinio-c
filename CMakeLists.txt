# SPDX-FileCopyrightText: 2024-2025 Knode.ai
# SPDX-License-Identifier: Apache-2.0
# Maintainer: Andy Curtis <contactandyc@gmail.com>
cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Project Configuration
project(restinio-c VERSION 0.1.1 LANGUAGES C CXX)

# Variables
set(INCLUDE_DIR_NAME "restinio-c")
set(EXTRA_FILES README.md CHANGELOG.md)
# set(CUSTOM_PACKAGES a-memory-library)
set(THIRD_PARTY_PACKAGES fmt nonstd::expected-lite asio restinio)

set(SOURCE_FILES src/restinio_c.cpp src/handlers/restinio_path.c)

find_package(a-cmake-library REQUIRED)

include(LibraryConfig)
include(LibraryBuild)

# Testing
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

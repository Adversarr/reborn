cmake_minimum_required(VERSION 3.10)

project(arch)

set(CMAKE_CXX_STANDARD 17)

file(GLOB_RECURSE SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_library(arch ${SRCS})
target_include_directories(arch PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)




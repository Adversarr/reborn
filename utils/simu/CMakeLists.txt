cmake_minimum_required(VERSION 3.10)

project(simu)

set(CMAKE_CXX_STANDARD 17)

include(cmake/cpm.cmake)

CPMAddPackage(NAME coost
  GITHUB_REPOSITORY idealvin/coost
  VERSION 3.0.0)

file(GLOB_RECURSE srcs src/*.cpp src/*.c)
file(GLOB_RECURSE heads include/*.hpp include/*.h)
include_directories(include)


add_executable(simulator ${srcs} ${heads})

target_link_libraries(simulator PUBLIC coost::co arch)




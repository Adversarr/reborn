cmake_minimum_required(VERSION 3.17)
project(minias)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
include_directories(include)
include(cmake/cpm.cmake)

file(GLOB SOURCE_FILE src/*.c src/*.cpp)

CPMAddPackage(NAME coost
  GITHUB_REPOSITORY idealvin/coost
  VERSION 3.0.0)


add_executable(minias ${SOURCE_FILE})

target_link_libraries(minias PUBLIC coost::co)

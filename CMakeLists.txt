cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
project(json_test VERSION 0.1.0 LANGUAGES CXX)

# Common
include(third_party/compat/compat.cmake)

# Soureces
file(GLOB_RECURSE sources src/*.hpp src/*.cpp)

# Application
assign_source_group(${sources})
add_executable(${PROJECT_NAME} ${sources})
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME $<LOWER_CASE:${PROJECT_NAME}>)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR} src)

# Install
install(TARGETS ${PROJECT_NAME} DESTINATION bin)

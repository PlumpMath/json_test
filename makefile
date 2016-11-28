# Make
MAKEFLAGS += --no-print-directory

# Compiler
CC	:= clang
CXX	:= clang++

# Build Type
BUILD	?= Debug

# Project
PROJECT	:= $(shell grep "^project" CMakeLists.txt | cut -c9- | cut -d" " -f1)
CURRENT	:= $(shell grep "^CMAKE_BUILD_TYPE:STRING" build/CMakeCache.txt 2>/dev/null | cut -c25-)

# Sources
SOURCES	:= $(shell find src -type f)

# Targets
all: build/CMakeCache.txt $(SOURCES)
	@cmake --build build

build/CMakeCache.txt: build CMakeLists.txt
	@if [ "$(CURRENT)" != "$(BUILD)" ]; then make clean; mkdir -p build; fi
	@cd build && CC="$(CC)" CXX="$(CXX)" cmake -DCMAKE_BUILD_TYPE=$(BUILD) -DCMAKE_INSTALL_PREFIX:PATH=.. ..

build:
	@mkdir -p build

clean:
	rm -rf build

run: all
	build/$(PROJECT)

install: build
	@if [ "$(CURRENT)" != "Release" ]; then make clean; mkdir -p build; fi
	@cd build && CC="$(CC)" CXX="$(CXX)" cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. ..
	@cmake --build build --target install

format: build/CMakeCache.txt
	@cmake --build build --target format

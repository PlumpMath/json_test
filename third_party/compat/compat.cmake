cmake_policy(VERSION 3.2)

if(NOT COMPAT)
  # Options
  if(NOT WARNINGS_MSVC)
    set(WARNINGS_MSVC "/W4")
  endif()

  if(NOT WARNINGS_LLVM)
    set(WARNINGS_LLVM "-Wextra -Werror -Wno-unused-function -Wno-unused-parameter -Wno-unused-variable")
  endif()

  if(NOT SANITIZE_LLVM)
    #set(SANITIZE_LLVM "address,undefined")
    #set(SANITIZE_LLVM "undefined,thread")
  endif()

  # Common Options
  if(CMAKE_C_COMPILER_ID OR CMAKE_CXX_COMPILER_ID)
    if(MSVC)
      # CRT
      foreach(flag
          CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
          CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE)
        if(${flag} MATCHES "/MD")
          string(REPLACE "/MD" "/MT" ${flag} "${${flag}}")
        endif()
        if(CMAKE_VS_PLATFORM_TOOLSET MATCHES "_xp")
          set(${flag} "${${flag}} /arch:IA32")
        endif()
      endforeach()

      # Unicode
      if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /utf-8")
      endif()

      # Definitions
      add_definitions(-D_UNICODE -DUNICODDE -DWIN32_LEAN_AND_MEAN -DNOMINMAX)
      add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE -D_ATL_SECURE_NO_DEPRECATE)
      add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS)

      # Windows SDK
      if(CMAKE_VS_PLATFORM_TOOLSET MATCHES "_xp")
        add_definitions(-DWINVER=0x0501 -D_WIN32_WINNT=0x0501)
      else()
        add_definitions(-DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00)
      endif()

      # Linker
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /manifestuac:NO /ignore:4099")
    else()
      # Linker
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pthread")
    endif()
  endif()

  # C Compiler Options
  if(CMAKE_C_COMPILER_ID)
    set(CMAKE_C_STANDARD 11)
    set(CMAKE_C_STANDARD_REQUIRED ON)
    set(CMAKE_C_EXTENSIONS OFF)
    if(MSVC AND NOT "${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
      set(CMAKE_C_FLAGS "${WARNINGS_MSVC} ${CMAKE_C_FLAGS}")
    else()
      set(CMAKE_C_FLAGS "${WARNINGS_LLVM} ${CMAKE_C_FLAGS}")
    endif()
    if(NOT MSVC AND SANITIZE_LLVM AND CMAKE_BUILD_TYPE MATCHES "Debug")
      file(READ "/proc/version" proc_version)
      if(NOT proc_version MATCHES "Microsoft")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=${SANITIZE_LLVM} -fno-omit-frame-pointer")
      endif()
    endif()
  endif()

  # C++ Compiler Options
  if(CMAKE_CXX_COMPILER_ID)
    if(MSVC AND NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
      set(CMAKE_CXX_FLAGS "/std:c++latest ${WARNINGS_MSVC} ${CMAKE_CXX_FLAGS}")
    else()
      set(CMAKE_CXX_FLAGS "-std=c++1z ${WARNINGS_LLVM} ${CMAKE_CXX_FLAGS}")
    endif()
    include_directories(SYSTEM "${CMAKE_CURRENT_LIST_DIR}/include/common")
    if(MSVC)
      include_directories(SYSTEM "${CMAKE_CURRENT_LIST_DIR}/include/msvc")
    else()
      include_directories(SYSTEM "${CMAKE_CURRENT_LIST_DIR}/include/llvm")
    endif()
    if(NOT MSVC AND SANITIZE_LLVM AND CMAKE_BUILD_TYPE MATCHES "Debug")
      file(READ "/proc/version" proc_version)
      if(NOT proc_version MATCHES "Microsoft")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=${SANITIZE_LLVM} -fno-omit-frame-pointer")
      endif()
    endif()
  endif()

  # Functions
  if(NOT assign_source_group)
    function(assign_source_group)
      foreach(source IN ITEMS ${ARGN})
        if(IS_ABSOLUTE ${source})
          file(RELATIVE_PATH source "${CMAKE_CURRENT_SOURCE_DIR}" "${source}")
        endif()
        get_filename_component(source_path "${source}" PATH)
        if(MSVC)
          string(REPLACE "/" "\\" source_path "${source_path}")
        endif()
        source_group("${source_path}" FILES "${source}")
      endforeach()
    endfunction(assign_source_group)
  endif()

  # Include Guard
  set(COMPAT true)
endif()

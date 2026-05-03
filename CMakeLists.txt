cmake_minimum_required(VERSION 3.21.1)

project(Rx8_HeadUnitApp LANGUAGES CXX)

# --------------------------------------------------
# Core setup
# --------------------------------------------------

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(BUILD_QDS_COMPONENTS OFF CACHE BOOL "Build Qt Design Studio components")
option(LINK_INSIGHT "Link Qt Insight Tracker library" OFF)

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Quick3D Quick3DAssetUtils Multimedia SerialPort)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Quick3D Quick3DAssetUtils Multimedia SerialPort)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

if(POLICY CMP0169)
    cmake_policy(SET CMP0169 NEW)
endif()

# --------------------------------------------------
# Dependencies
# --------------------------------------------------

find_package(PkgConfig REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Threads REQUIRED)

pkg_check_modules(LIBUSB REQUIRED libusb-1.0)
pkg_check_modules(AVCODEC REQUIRED libavcodec)
pkg_check_modules(AVFORMAT REQUIRED libavformat)
pkg_check_modules(AVUTIL REQUIRED libavutil)
pkg_check_modules(SWSCALE REQUIRED libswscale)
pkg_check_modules(SWRESAMPLE REQUIRED libswresample)

find_program(XXD_EXECUTABLE xxd REQUIRED)

# --------------------------------------------------
# CarPlay embedded resources (font + background)
# --------------------------------------------------

set(CARPLAY_RESOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/carplay/resource)
set(CARPLAY_AUTOGEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/carplay_autogen)

file(MAKE_DIRECTORY ${CARPLAY_AUTOGEN_DIR})

add_custom_command(
    OUTPUT ${CARPLAY_AUTOGEN_DIR}/font_data.cpp
    COMMAND ${XXD_EXECUTABLE} -i -n font
            ${CARPLAY_RESOURCE_DIR}/font.ttf
            ${CARPLAY_AUTOGEN_DIR}/font_data.cpp
    DEPENDS ${CARPLAY_RESOURCE_DIR}/font.ttf
)

add_custom_command(
    OUTPUT ${CARPLAY_AUTOGEN_DIR}/background_data.cpp
    COMMAND ${XXD_EXECUTABLE} -i -n background
            ${CARPLAY_RESOURCE_DIR}/background.bmp
            ${CARPLAY_AUTOGEN_DIR}/background_data.cpp
    DEPENDS ${CARPLAY_RESOURCE_DIR}/background.bmp
)

# --------------------------------------------------
# Sources
# --------------------------------------------------

set(APP_SOURCES
    src/main.cpp
    src/app_environment.h
    src/import_qml_components_plugins.h
    src/teensy/TeensyGateway.cpp
    src/teensy/TeensyGateway.h
)

set(CARPLAY_SOURCES
    src/carplay/CarPlayConfig.cpp
    src/carplay/CarPlayConfig.h
    src/carplay/CarPlayEngine.cpp
    src/carplay/CarPlayEngine.h
    src/carplay/CarPlayView.cpp
    src/carplay/CarPlayView.h

    src/carplay/application.cpp
    src/carplay/application.h
    src/carplay/decoder.cpp
    src/carplay/decoder.h
    src/carplay/interface.cpp
    src/carplay/interface.h
    src/carplay/pcm_audio.cpp
    src/carplay/pcm_audio.h
    src/carplay/pipe_listener.cpp
    src/carplay/pipe_listener.h
    src/carplay/recorder.cpp
    src/carplay/recorder.h
    src/carplay/renderer.cpp
    src/carplay/renderer.h
    src/carplay/settings.cpp
    src/carplay/settings.h

    src/carplay/common/logger.cpp
    src/carplay/common/logger.h

    src/carplay/protocol/aes_cipher.cpp
    src/carplay/protocol/connection.cpp
    src/carplay/protocol/usb_buffer.cpp

    ${CARPLAY_AUTOGEN_DIR}/font_data.cpp
    ${CARPLAY_AUTOGEN_DIR}/background_data.cpp
)

# --------------------------------------------------
# Executable
# --------------------------------------------------

qt_add_executable(${CMAKE_PROJECT_NAME}
    ${APP_SOURCES}
    ${CARPLAY_SOURCES}
)

qt6_standard_project_setup()

# --------------------------------------------------
# Includes
# --------------------------------------------------

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/carplay

    ${LIBUSB_INCLUDE_DIRS}
    ${AVCODEC_INCLUDE_DIRS}
    ${AVFORMAT_INCLUDE_DIRS}
    ${AVUTIL_INCLUDE_DIRS}
    ${SWSCALE_INCLUDE_DIRS}
    ${SWRESAMPLE_INCLUDE_DIRS}
)

# --------------------------------------------------
# Compile / Link
# --------------------------------------------------

target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE
    ${LIBUSB_CFLAGS_OTHER}
    ${AVCODEC_CFLAGS_OTHER}
    ${AVFORMAT_CFLAGS_OTHER}
    ${AVUTIL_CFLAGS_OTHER}
    ${SWSCALE_CFLAGS_OTHER}
    ${SWRESAMPLE_CFLAGS_OTHER}
)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Quick3D
    Qt6::Quick3DAssetUtils
    Qt6::Qml
    Qt6::Multimedia
    Qt6::SerialPort

    OpenSSL::SSL
    OpenSSL::Crypto
    Threads::Threads

    ${LIBUSB_LIBRARIES}
    ${AVCODEC_LIBRARIES}
    ${AVFORMAT_LIBRARIES}
    ${AVUTIL_LIBRARIES}
    ${SWSCALE_LIBRARIES}
    ${SWRESAMPLE_LIBRARIES}
)

# --------------------------------------------------
# Settings deploy
# --------------------------------------------------

add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${CMAKE_PROJECT_NAME}>/carplay
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_CURRENT_SOURCE_DIR}/src/carplay/settings.txt
            $<TARGET_FILE_DIR:${CMAKE_PROJECT_NAME}>/carplay/settings.txt
)

if (BUILD_QDS_COMPONENTS)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/QmlComponents.cmake)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/QmlModules.cmake)

if (LINK_INSIGHT)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/Insight.cmake)
endif()


# --------------------------------------------------
# Install / Raspberry Pi runtime
# --------------------------------------------------

install(TARGETS ${CMAKE_PROJECT_NAME}
    RUNTIME DESTINATION .
)

install(FILES src/carplay/settings.txt
    DESTINATION carplay
)

install(PROGRAMS scripts/launch-rpi.sh
    DESTINATION .
    RENAME launch.sh
)

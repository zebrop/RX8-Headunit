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

set(BUILD_QDS_COMPONENTS ON CACHE BOOL "Build design studio components")
option(LINK_INSIGHT "Link Qt Insight Tracker library" ON)

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia)

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
# FastCarPlay resources
# --------------------------------------------------

set(FASTCARPLAY_RESOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/integrations/carplay/fastcarplay/resource)
set(FASTCARPLAY_AUTOGEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/fastcarplay_autogen)

file(MAKE_DIRECTORY ${FASTCARPLAY_AUTOGEN_DIR})

add_custom_command(
    OUTPUT ${FASTCARPLAY_AUTOGEN_DIR}/font_data.cpp
    COMMAND ${XXD_EXECUTABLE} -i -n font
            ${FASTCARPLAY_RESOURCE_DIR}/font.ttf
            ${FASTCARPLAY_AUTOGEN_DIR}/font_data.cpp
    DEPENDS ${FASTCARPLAY_RESOURCE_DIR}/font.ttf
)

add_custom_command(
    OUTPUT ${FASTCARPLAY_AUTOGEN_DIR}/background_data.cpp
    COMMAND ${XXD_EXECUTABLE} -i -n background
            ${FASTCARPLAY_RESOURCE_DIR}/background.bmp
            ${FASTCARPLAY_AUTOGEN_DIR}/background_data.cpp
    DEPENDS ${FASTCARPLAY_RESOURCE_DIR}/background.bmp
)

# --------------------------------------------------
# Sources
# --------------------------------------------------

set(APP_SOURCES
    app/main.cpp
    app/CarPlayConfig.cpp
    app/CarPlayConfig.h
    app/app_environment.h
    app/import_qml_components_plugins.h
    Rx8_HeadUnit.qrc
)

set(CARPLAY_SOURCES
    integrations/carplay/CarPlayEngine.cpp
    integrations/carplay/CarPlayEngine.h
    integrations/carplay/CarPlayView.cpp
    integrations/carplay/CarPlayView.h
)

set(FASTCARPLAY_SOURCES
    integrations/carplay/fastcarplay/application.cpp
    integrations/carplay/fastcarplay/application.h
    integrations/carplay/fastcarplay/decoder.cpp
    integrations/carplay/fastcarplay/decoder.h
    integrations/carplay/fastcarplay/interface.cpp
    integrations/carplay/fastcarplay/interface.h
    integrations/carplay/fastcarplay/pcm_audio.cpp
    integrations/carplay/fastcarplay/pcm_audio.h
    integrations/carplay/fastcarplay/recorder.cpp
    integrations/carplay/fastcarplay/recorder.h
    integrations/carplay/fastcarplay/renderer.cpp
    integrations/carplay/fastcarplay/renderer.h
    integrations/carplay/fastcarplay/settings.cpp
    integrations/carplay/fastcarplay/settings.h

    integrations/carplay/fastcarplay/common/logger.cpp
    integrations/carplay/fastcarplay/common/logger.h

    integrations/carplay/fastcarplay/protocol/aes_cipher.cpp
    integrations/carplay/fastcarplay/protocol/connection.cpp
    integrations/carplay/fastcarplay/protocol/usb_buffer.cpp

    ${FASTCARPLAY_AUTOGEN_DIR}/font_data.cpp
    ${FASTCARPLAY_AUTOGEN_DIR}/background_data.cpp
)

# --------------------------------------------------
# Executable
# --------------------------------------------------

qt_add_executable(${CMAKE_PROJECT_NAME}
    ${APP_SOURCES}
    ${CARPLAY_SOURCES}
    ${FASTCARPLAY_SOURCES}
)

qt6_standard_project_setup()

# --------------------------------------------------
# Includes
# --------------------------------------------------

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/app
    ${CMAKE_CURRENT_SOURCE_DIR}/integrations/carplay
    ${CMAKE_CURRENT_SOURCE_DIR}/integrations/carplay/fastcarplay

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
    Qt6::Qml
    Qt6::Multimedia

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
            ${CMAKE_CURRENT_SOURCE_DIR}/integrations/carplay/fastcarplay/settings.txt
            $<TARGET_FILE_DIR:${CMAKE_PROJECT_NAME}>/carplay/settings.txt
)

if (BUILD_QDS_COMPONENTS)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/QmlComponents.cmake)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/QmlModules.cmake)

if (LINK_INSIGHT)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/Insight.cmake)
endif()


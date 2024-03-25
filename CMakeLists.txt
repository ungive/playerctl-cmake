cmake_minimum_required(VERSION 3.27)
project(playerctl)

find_file(PLAYERCTL_TEST NAMES playerctl playerctl-2.4.1 PATHS ${CMAKE_CURRENT_SOURCE_DIR} CMAKE_FIND_ROOT_PATH_BOTH)
if (NOT PLAYERCTL_TEST)
    message("downloading playerctl")
    set(PCTL_TAR_FILE ${CMAKE_CURRENT_SOURCE_DIR}/v2.4.1.tar.gz)
    file(DOWNLOAD https://github.com/altdesktop/playerctl/archive/v2.4.1.tar.gz ${PCTL_TAR_FILE})
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf ${PCTL_TAR_FILE}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
    
    file(REMOVE ${PCTL_TAR_FILE})
endif(NOT PLAYERCTL_TEST)

find_file(PLAYERCTL NAMES playerctl playerctl-2.4.1 PATHS ${CMAKE_CURRENT_SOURCE_DIR} CMAKE_FIND_ROOT_PATH_BOTH)

find_package(PkgConfig REQUIRED)

pkg_check_modules(GOBJECT REQUIRED IMPORTED_TARGET gobject-2.0>=2.38)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-unix-2.0)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(glib_mkenums)
include(gdbus_codegen)

set(PLAYERCTL_SRC_DIR ${PLAYERCTL}/playerctl)
set(PLAYERCTL_GEN_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/gen)
set(PLAYERCTL_GEN_DIR ${PLAYERCTL_GEN_INCLUDE_DIR}/playerctl)

set(PLAYERCTL_VERSION 2.4.1)
set(PLAYERCTL_MAJOR_VERSION 2)
set(PLAYERCTL_MINOR_VERSION 4)
set(PLAYERCTL_MICRO_VERSION 1)
set(PLAYERCTL_RELEASE_DATE "September 21, 2021")
configure_file(
    ${PLAYERCTL_SRC_DIR}/playerctl-version.h.in
    ${PLAYERCTL_GEN_DIR}/playerctl-version.h
)

glib_mkenums(
    ${PLAYERCTL_GEN_DIR}
    playerctl-enum-types
    ${PLAYERCTL_SRC_DIR}/playerctl.h
    ${PLAYERCTL_SRC_DIR}/playerctl-player.h
    ${PLAYERCTL_SRC_DIR}/playerctl-player-manager.h
    ${PLAYERCTL_SRC_DIR}/playerctl-player-name.h
    ${PLAYERCTL_GEN_DIR}/playerctl-version.h
)

gdbus_codegen(
    ${PLAYERCTL}/data/mpris-dbus-interface.xml
    ${PLAYERCTL_GEN_DIR}/playerctl-generated.h
    --c-generate-autocleanup all
    --header
)
gdbus_codegen(
    ${PLAYERCTL}/data/mpris-dbus-interface.xml
    ${PLAYERCTL_GEN_DIR}/playerctl-generated.c
    --c-generate-autocleanup all
    --body
)

set(PLAYERCTL_SOURCES
    ${PLAYERCTL_SRC_DIR}/playerctl.h
    ${PLAYERCTL_SRC_DIR}/playerctl-player.h
    ${PLAYERCTL_SRC_DIR}/playerctl-player-manager.h
    ${PLAYERCTL_SRC_DIR}/playerctl-player-name.h
    ${PLAYERCTL_SRC_DIR}/playerctl-player-name.c
    ${PLAYERCTL_SRC_DIR}/playerctl-formatter.c
    ${PLAYERCTL_SRC_DIR}/playerctl-player.c
    ${PLAYERCTL_SRC_DIR}/playerctl-common.c
    ${PLAYERCTL_SRC_DIR}/playerctl-player-manager.c
    # generated
    ${PLAYERCTL_GEN_DIR}/playerctl-version.h
    ${PLAYERCTL_GEN_DIR}/playerctl-enum-types.h
    ${PLAYERCTL_GEN_DIR}/playerctl-enum-types.c
    ${PLAYERCTL_GEN_DIR}/playerctl-generated.c
    ${PLAYERCTL_GEN_DIR}/playerctl-generated.h
)

set(PLAYERCTL_CLI_SOURCES
    ${PLAYERCTL_SRC_DIR}/playerctl-cli.c
    # generated
    ${PLAYERCTL_GEN_DIR}/playerctl-enum-types.h
    ${PLAYERCTL_GEN_DIR}/playerctl-enum-types.c
)

# set(CMAKE_SHARED_LINKER_FLAGS ${CMAKE_SHARED_LINKER_FLAGS} "-Wl,--version-script,${CMAKE_CURRENT_SOURCE_DIR}/playerctl/data/playerctl.syms")
# set_property(TARGET playerctl APPEND_STRING PROPERTY LINK_FLAGS " -Wl,--version-script,${CMAKE_CURRENT_SOURCE_DIR}/playerctl/data/playerctl.syms")

add_library(playerctl SHARED ${PLAYERCTL_SOURCES})
set_target_properties(playerctl PROPERTIES VERSION ${PLAYERCTL_VERSION} SOVERSION ${PLAYERCTL_MAJOR_VERSION})
target_include_directories(playerctl PUBLIC ${PLAYERCTL} ${PLAYERCTL}/playerctl ${PLAYERCTL_GEN_DIR} ${PLAYERCTL_GEN_INCLUDE_DIR})
target_compile_definitions(playerctl PUBLIC PLAYERCTL_COMPILATION)
target_compile_definitions(playerctl PUBLIC G_LOG_DOMAIN="playerctl")
target_link_libraries(playerctl PUBLIC PkgConfig::GIO PkgConfig::GOBJECT)

add_executable(playerctl-cli ${PLAYERCTL_CLI_SOURCES})
target_include_directories(playerctl-cli PUBLIC ${PLAYERCTL} ${PLAYERCTL}/playerctl ${PLAYERCTL_GEN_DIR} ${PLAYERCTL_GEN_INCLUDE_DIR})
target_link_libraries(playerctl-cli PUBLIC playerctl PkgConfig::GIO PkgConfig::GOBJECT)

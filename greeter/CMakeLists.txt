CMAKE_MINIMUM_REQUIRED(VERSION 2.8.7)
PROJECT(GREETER)
INCLUDE(global_settings)

SET(Boost_USE_STATIC_LIBS OFF)
FIND_PACKAGE(Boost
    COMPONENTS chrono system unit_test_framework
    REQUIRED)

INCLUDE(
    ${WORLD_ROOT}/lib/cmake/world/WorldTargets.cmake
)

INCLUDE_DIRECTORIES(
    ${Boost_INCLUDE_DIRS}
    ${WORLD_ROOT}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/sources
)

ADD_SUBDIRECTORY(sources)

FIND_PACKAGE(Boost COMPONENTS chrono python REQUIRED)
FIND_PACKAGE(PythonLibs REQUIRED)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${PYTHON_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
)

ADD_LIBRARY(world-static
    STATIC
    world
)
INSTALL(
    TARGETS world-static
    DESTINATION lib
    EXPORT WorldTargets
)

ADD_LIBRARY(world-shared
    SHARED
    world
)
INSTALL(
    TARGETS world-shared
    DESTINATION lib
    EXPORT WorldTargets
)

ADD_EXECUTABLE(turn_world-static
    turn
)
TARGET_LINK_LIBRARIES(turn_world-static
    world-static
    ${Boost_CHRONO_LIBRARY}
)
INSTALL(
    TARGETS turn_world-static
    DESTINATION bin
)

ADD_EXECUTABLE(turn_world-shared
    turn
)
TARGET_LINK_LIBRARIES(turn_world-shared
    world-shared
    ${Boost_CHRONO_LIBRARY}
)
INSTALL(
    TARGETS turn_world-shared
    DESTINATION bin
)

ADD_LIBRARY(world-python
    SHARED
    world_extension
)
TARGET_LINK_LIBRARIES(world-python
    world-shared
    ${Boost_PYTHON_LIBRARY}
    ${PYTHON_LIBRARIES}
)
CONFIGURE_PYTHON_EXTENSION(world-python
    "world"
    "../../lib"
)
INSTALL(
    TARGETS world-python
    DESTINATION python/world
    EXPORT WorldTargets
)

INSTALL(
    EXPORT WorldTargets
    DESTINATION lib/cmake/world
)

INSTALL(
    FILES world.h
    DESTINATION include/world
)

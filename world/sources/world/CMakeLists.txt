ADD_SUBDIRECTORY(tests)

ADD_LIBRARY(world-static
    STATIC
    world
)

ADD_LIBRARY(world-shared
    SHARED
    world
)
SET_TARGET_PROPERTIES(world-shared
    PROPERTIES
        COMPILE_FLAGS "-DWORLD_SOURCE -DWORLD_SHARED_LINK"
)
TARGET_LINK_LIBRARIES(world-shared
    ${Boost_CHRONO_LIBRARY}
    ${Boost_TIMER_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
)

ADD_EXECUTABLE(turn_world-static
    turn
)
TARGET_LINK_LIBRARIES(turn_world-static
    world-static
    ${Boost_CHRONO_LIBRARY}
    ${Boost_TIMER_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
)

ADD_EXECUTABLE(turn_world-shared
    turn
)
TARGET_LINK_LIBRARIES(turn_world-shared
    world-shared
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
    TARGETS world-static world-shared turn_world-static turn_world-shared
    EXPORT WorldTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
# IF(WIN32)
#     INSTALL(
#         TARGETS world-shared
#         EXPORT WorldTargets
#         RUNTIME DESTINATION lib
#     )
# ELSE()
#     INSTALL(
#         TARGETS world-shared
#         EXPORT WorldTargets
#         LIBRARY DESTINATION lib
#     )
# ENDIF()
INSTALL(
    TARGETS world-python
    EXPORT WorldTargets
    DESTINATION python/world
)
INSTALL(
    FILES config.h world.h
    DESTINATION include/world
)
INSTALL(
    EXPORT WorldTargets
    DESTINATION lib/cmake/world
)

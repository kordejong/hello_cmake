FIND_PACKAGE(Boost COMPONENTS chrono python system REQUIRED)
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
IF(${HC_ENABLE_FIXUP_BUNDLE})
    INSTALL(
        TARGETS world-shared
        DESTINATION bin
        EXPORT WorldTargets
    )
ELSE()
    INSTALL(
        TARGETS world-shared
        DESTINATION lib
        EXPORT WorldTargets
    )
ENDIF()

ADD_EXECUTABLE(turn_world-static
    turn
)
TARGET_LINK_LIBRARIES(turn_world-static
    world-static
    ${Boost_CHRONO_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
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
    ${Boost_SYSTEM_LIBRARY}
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
IF(${HC_ENABLE_FIXUP_BUNDLE})
    CONFIGURE_PYTHON_EXTENSION(world-python
        "world"
        "../../bin"
    )
ELSE()
    CONFIGURE_PYTHON_EXTENSION(world-python
        "world"
        "../../lib"
    )
ENDIF()
INSTALL(
    TARGETS world-python
    DESTINATION python/world
    EXPORT WorldTargets
)

IF(NOT ${HC_ENABLE_FIXUP_BUNDLE})
    INSTALL(
        EXPORT WorldTargets
        DESTINATION lib/cmake/world
    )
ENDIF()

INSTALL(
    FILES world.h
    DESTINATION include/world
)

IF(HC_ENABLE_FIXUP_BUNDLE)
    IF(UNIX AND NOT APPLE)
        SET_TARGET_PROPERTIES(
            turn_world-static
            PROPERTIES
                INSTALL_RPATH "\$ORIGIN"
        )
        SET_TARGET_PROPERTIES(
            turn_world-shared
            PROPERTIES
                INSTALL_RPATH "\$ORIGIN"
        )
    ENDIF()

    IF(APPLE)
        SET(APPS
            "\${CMAKE_INSTALL_PREFIX}/turn_world-static.app"
            "\${CMAKE_INSTALL_PREFIX}/turn_world-shared.app"
        )
    ELSEIF(WIN32)
        SET(APPS
            "\${CMAKE_INSTALL_PREFIX}/bin/turn_world-static.exe"
            "\${CMAKE_INSTALL_PREFIX}/bin/turn_world-shared.exe"
        )
    ELSE()
        SET(APPS
            "\${CMAKE_INSTALL_PREFIX}/bin/turn_world-static"
            "\${CMAKE_INSTALL_PREFIX}/bin/turn_world-shared"
        )
    ENDIF()

    SET(DIRS
        ${Boost_LIBRARY_DIRS}
    )

    INSTALL(CODE "
            INCLUDE(BundleUtilities)
            FOREACH(APP ${APPS})
                FIXUP_BUNDLE(
                    \"\${APP}\"
                    \"\"
                    \"${DIRS}\")
            ENDFOREACH()
        "
        COMPONENT Runtime)

    # Install stuff not detected by FIXUP_BUNDLE.
    FOREACH(NAME ${Boost_PYTHON_LIBRARY} ${PYTHON_LIBRARIES})
        GET_FILENAME_COMPONENT(REAL_PATH ${NAME} REALPATH)
        SET(REAL_PATHS ${REAL_PATHS} ${REAL_PATH})
    ENDFOREACH()
    INSTALL(FILES ${REAL_PATHS} DESTINATION bin)
ENDIF()

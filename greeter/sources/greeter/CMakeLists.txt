SET(Boost_USE_STATIC_LIBS OFF)
FIND_PACKAGE(Boost COMPONENTS chrono system REQUIRED)

INCLUDE(
    ${WORLD_ROOT}/lib/cmake/world/WorldTargets.cmake
)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${WORLD_ROOT}/include
)

ADD_EXECUTABLE(greeter-static
    # MACOSX_BUNDLE
    main.cc
)
TARGET_LINK_LIBRARIES(greeter-static
    world-static
    ${Boost_CHRONO_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
)
INSTALL(
    TARGETS greeter-static
    DESTINATION bin
)

ADD_EXECUTABLE(greeter-shared
    # MACOSX_BUNDLE
    main.cc
)
TARGET_LINK_LIBRARIES(greeter-shared
    world-shared
    ${Boost_CHRONO_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
)
INSTALL(
    TARGETS greeter-shared
    DESTINATION bin
)

# INSTALL(
#     TARGETS greeter-static greeter-shared
#     BUNDLE DESTINATION . COMPONENT Runtime
#     RUNTIME DESTINATION bin COMPONENT Runtime
# )

IF(HC_ENABLE_FIXUP_BUNDLE)
    # GET_TARGET_PROPERTY(
    #     TURN_WORLD-STATIC_LOCATION
    #     turn_world-static
    #     LOCATION
    # )
    # GET_TARGET_PROPERTY(
    #     TURN_WORLD-SHARED_LOCATION
    #     turn_world-shared
    #     LOCATION
    # )
    # GET_TARGET_PROPERTY(
    #     WORLD-PYTHON_LOCATION
    #     world-python
    #     LOCATION
    # )

    # INSTALL(
    #     FILES ${TURN_WORLD-STATIC_LOCATION} ${TURN_WORLD-SHARED_LOCATION}
    #     DESTINATION bin
    #     PERMISSIONS
    #         WORLD_READ GROUP_READ OWNER_READ
    #         WORLD_EXECUTE GROUP_EXECUTE OWNER_EXECUTE
    # )
    # INSTALL(
    #     FILES ${WORLD-PYTHON_LOCATION}
    #     DESTINATION python/world
    # )

    IF(UNIX AND NOT APPLE)
        SET_TARGET_PROPERTIES(
            greeter-static
            PROPERTIES
                INSTALL_RPATH "\$ORIGIN"
        )
        SET_TARGET_PROPERTIES(
            greeter-shared
            PROPERTIES
                INSTALL_RPATH "\$ORIGIN"
        )
    ENDIF()

    IF(APPLE)
        SET(APPS
            # ${TURN_WORLD-STATIC_LOCATION}
            # ${TURN_WORLD-SHARED_LOCATION}
            "\${CMAKE_INSTALL_PREFIX}/greeter-static.app"
            "\${CMAKE_INSTALL_PREFIX}/greeter-shared.app"
        )
    ELSEIF(WIN32)
        SET(APPS
            # ${TURN_WORLD-STATIC_LOCATION}
            # ${TURN_WORLD-SHARED_LOCATION}
            "\${CMAKE_INSTALL_PREFIX}/bin/greeter-static.exe"
            "\${CMAKE_INSTALL_PREFIX}/bin/greeter-shared.exe"
        )
    ELSE()
        SET(APPS
            # ${TURN_WORLD-STATIC_LOCATION}
            # ${TURN_WORLD-SHARED_LOCATION}
            "\${CMAKE_INSTALL_PREFIX}/bin/greeter-static"
            "\${CMAKE_INSTALL_PREFIX}/bin/greeter-shared"
        )
    ENDIF()

    SET(DIRS
        ${WORLD_ROOT}/lib
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
ENDIF()

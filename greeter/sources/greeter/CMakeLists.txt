INCLUDE(
    ${WORLD_ROOT}/lib/cmake/world/WorldTargets.cmake
)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${WORLD_ROOT}/include
)

ADD_EXECUTABLE(greeter-static
    MACOSX_BUNDLE
    main.cc
)
TARGET_LINK_LIBRARIES(greeter-static
    world-static
)

ADD_EXECUTABLE(greeter-shared
    MACOSX_BUNDLE
    main.cc
)
TARGET_LINK_LIBRARIES(greeter-shared
    world-shared
)

INSTALL(
    TARGETS greeter-static greeter-shared
    BUNDLE DESTINATION . COMPONENT Runtime
    RUNTIME DESTINATION bin COMPONENT Runtime
)

IF(HC_ENABLE_FIXUP_BUNDLE)
    IF(UNIX AND NOT APPLE)
        SET_TARGET_PROPERTIES(
            greeter-shared
            PROPERTIES
                INSTALL_RPATH "\$ORIGIN"
        )
    ENDIF()

    IF(APPLE)
        SET(APPS "\${CMAKE_INSTALL_PREFIX}/greeter-shared.app")
    ELSEIF(WIN32)
        SET(APPS "\${CMAKE_INSTALL_PREFIX}/bin/greeter-shared.exe")
    ELSE()
        SET(APPS "\${CMAKE_INSTALL_PREFIX}/bin/greeter-shared")
    ENDIF()

    INSTALL(CODE "
            INCLUDE(BundleUtilities)
            FIXUP_BUNDLE(
                \"${APPS}\"
                \"\"
                \"${WORLD_ROOT}\")
        "
        COMPONENT Runtime)
                # \"${WORLD_ROOT}/lib\")
ENDIF()

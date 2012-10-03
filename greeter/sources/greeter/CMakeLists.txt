INCLUDE(
    ${WORLD_PREFIX}/lib/cmake/hcworld/HCWorldTargets.cmake
)
INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${WORLD_PREFIX}/include
)
ADD_EXECUTABLE(hcgreeter-static
    MACOSX_BUNDLE
    main.cc
)
TARGET_LINK_LIBRARIES(
    hcgreeter-static
    hcworld-static
)
ADD_EXECUTABLE(hcgreeter-shared
    MACOSX_BUNDLE
    main.cc
)
TARGET_LINK_LIBRARIES(
    hcgreeter-shared
    hcworld-shared
)
INSTALL(
    TARGETS hcgreeter-static hcgreeter-shared
    BUNDLE DESTINATION . COMPONENT Runtime
    RUNTIME DESTINATION bin COMPONENT Runtime
)
IF(ENABLE_FIXUP_BUNDLE)
    IF(UNIX AND NOT APPLE)
        SET_TARGET_PROPERTIES(
            hcgreeter-shared
            PROPERTIES
                INSTALL_RPATH "\$ORIGIN"
        )
    ENDIF()

    IF(APPLE)
        SET(APPS "\${CMAKE_INSTALL_PREFIX}/hcgreeter-shared.app")
    ELSEIF(WIN32)
        SET(APPS "\${CMAKE_INSTALL_PREFIX}/bin/hcgreeter-shared.exe")
    ELSE()
        SET(APPS "\${CMAKE_INSTALL_PREFIX}/bin/hcgreeter-shared")
    ENDIF()

    INSTALL(CODE "
            INCLUDE(BundleUtilities)
            FIXUP_BUNDLE(
                \"${APPS}\"
                \"\"
                \"${WORLD_PREFIX}\")
        "
        COMPONENT Runtime)
                # \"${WORLD_PREFIX}/lib\")
ENDIF()

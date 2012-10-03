INCLUDE(
    ${WORLD_PREFIX}/lib/cmake/hcworld/HCWorldTargets.cmake
)
INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${WORLD_PREFIX}/include
)
ADD_EXECUTABLE(hcgreeter-static
    main.cc
)
TARGET_LINK_LIBRARIES(
    hcgreeter-static
    hcworld-static
)
ADD_EXECUTABLE(hcgreeter-shared
    main.cc
)
TARGET_LINK_LIBRARIES(
    hcgreeter-shared
    hcworld-shared
)
INSTALL(
    TARGETS hcgreeter-static hcgreeter-shared
    DESTINATION bin
)
IF(ENABLE_FIXUP_BUNDLE)
    IF(UNIX AND NOT APPLE)
        SET_TARGET_PROPERTIES(
            hcgreeter-shared
            PROPERTIES
                INSTALL_RPATH "\$ORIGIN"
        )
    ENDIF()
    SET(APPS "\${CMAKE_INSTALL_PREFIX}/bin/hcgreeter-shared")
    INSTALL(CODE "
            INCLUDE(BundleUtilities)
            FIXUP_BUNDLE(
                \"${APPS}\"
                \"\"
                \"${WORLD_PREFIX}/lib\")
        "
        COMPONENT Runtime)
ENDIF()

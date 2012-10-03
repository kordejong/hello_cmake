IF(UNIX)
    IF(APPLE)
    ELSE()
        # Update the rpath of exes and dlls.
        SET(CMAKE_SKIP_BUILD_RPATH FALSE)

        # During a build, don't put the rpath to the install location
        # in the exes and dlls yet.
        SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

        # During installation, use this rpath setting. This assumes that
        # all dll's are installed in <install prefix>/lib.
        SET(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib")

        # During installation, don't put the path to the imported dlls
        # in the exes and dlls.
        SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
    ENDIF()
ENDIF()

MACRO(CONFIGURE_PYTHON_EXTENSION EXTENTION_TARGET EXTENSION_NAME)
    SET_TARGET_PROPERTIES(${EXTENTION_TARGET}
        PROPERTIES
            OUTPUT_NAME "${EXTENSION_NAME}"
    )

    # Configure suffix and prefix, depending on the Python OS conventions.
    IF(WIN32)
        SET_TARGET_PROPERTIES(${EXTENTION_TARGET}
            PROPERTIES
                SUFFIX ".pyd"
        )
    ELSEIF(APPLE)
        SET_TARGET_PROPERTIES(${EXTENTION_TARGET}
            PROPERTIES
                SUFFIX ".so"
        )
    ELSE()
        SET_TARGET_PROPERTIES(${EXTENTION_TARGET}
            PROPERTIES
                PREFIX ""
        )
    ENDIF()
ENDMACRO(CONFIGURE_PYTHON_EXTENSION)

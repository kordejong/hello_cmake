ENABLE_TESTING()
SET(BOOST_TEST_RUNTIME_PARAMETERS --log_level all)

INCLUDE(CPack)

# Whether or not to create a bundle with all prerequisites included.
SET(HC_ENABLE_FIXUP_BUNDLE ON CACHE BOOL
    "Configure to create a bundle instead of for a regular install")

IF(UNIX)
    SET(CPACK_GENERATOR "TGZ")

    IF(APPLE)
        SET(CPACK_BINARY_DRAGNDROP ON)

        # Mac doesn't have rpath, it has install name. See the otool and
        # install_name_tool commands.

        # During a build, don't put the install name of the install location
        # in the exes and dlls yet. Use the install names found in the dlls
        # that we link against. If those are absolute (they should), then we
        # can run the targets from the build location, which is Good.
        SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

        # During installation, use this install name setting. This assumes
        # that all dll's are installed in <install prefix>/lib.
        # SET(CMAKE_INSTALL_NAME_DIR "@executable_path/../lib")

        SET(CMAKE_INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib")
    ELSE()
        # Update the rpath of exes and dlls.
        SET(CMAKE_SKIP_BUILD_RPATH FALSE)

        # During a build, don't put the rpath to the install location
        # in the exes and dlls yet.
        SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

        # During installation, use this rpath setting. This assumes that
        # all dll's are installed in <install prefix>/lib.
        SET(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib")

        # During installation, put the path to the imported dlls in the exes
        # and dlls.
        SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    ENDIF()
ELSEIF(WIN32)
    SET(CPACK_GENERATOR "ZIP")

    # TODO Make sure our exes/dlls find only our dlls.
ENDIF()


MACRO(CONFIGURE_PYTHON_EXTENSION
        EXTENTION_TARGET
        EXTENSION_NAME
        RPATH)
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
                PREFIX ""
                SUFFIX ".so"
                # INSTALL_NAME_DIR "@executable_path/${RPATH}"
        )
    ELSE()
        SET_TARGET_PROPERTIES(${EXTENTION_TARGET}
            PROPERTIES
                PREFIX ""
                INSTALL_RPATH "\$ORIGIN/${RPATH}"
        )
    ENDIF()
ENDMACRO(CONFIGURE_PYTHON_EXTENSION)

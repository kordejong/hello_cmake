ENABLE_TESTING()

SET(BOOST_TEST_RUNTIME_PARAMETERS --log_level all)

ADD_DEFINITIONS(
    # Turn off automatic linking. It is confusing.
    -DBOOST_ALL_NO_LIB
)

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)

IF(UNIX)
    IF(APPLE)
        # Mac doesn't have rpath, it has install name. See the otool and
        # install_name_tool commands.

        # The install name of a shared library is a path name which tells
        # the linker where the library can be found at runtime. These install
        # names get copied into exes and dlls at link time. At runtime, the
        # loader knows where to find dlls.

        # During a build, don't put the install name of the install location
        # in the exes and dlls yet. Use the install names found in the dlls
        # that we link against. If those are absolute (they should), then we
        # can run the targets from the build location, which is Good.
        SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

        # During installation, use this install name setting. This assumes
        # that all dll's are installed in <install prefix>/lib.
        # This doesn't work for Python extensions which aren't installed
        # in <prefix>/bin. These dlls get the relative install name copied
        # in at link time, but at runtime, the shared libs they depend on
        # won't be found at this location. A fixup is needed which updates
        # the paths to the project's shared libs (replace
        # @executable_path/../lib by @executable_path/../../lib).
        # TODO Replace executable_path by loader_path?
        # SET(CMAKE_INSTALL_NAME_DIR "@executable_path/../lib")

        # For now, put the install prefix in install name. Absolute path names
        # always work, but the installation isn't relocatable anymore.
        SET(CMAKE_INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib")
    ELSE()
        # Update the rpath of exes and dlls.
        SET(CMAKE_SKIP_BUILD_RPATH FALSE)

        # During a build, don't put the rpath to the install location
        # in the exes and dlls yet.
        SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

        # During installation, use this rpath setting. This assumes that
        # all dll's are installed in <install prefix>/lib.
        # SET(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib")
        SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

        # During installation, put the path to external (3rd party and
        # imported) dlls in the exes and dlls.
        SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    ENDIF()
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
                # INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
        )
    ELSE()
        SET_TARGET_PROPERTIES(${EXTENTION_TARGET}
            PROPERTIES
                PREFIX ""
                INSTALL_RPATH "\$ORIGIN/${RPATH}"
        )
    ENDIF()
ENDMACRO(CONFIGURE_PYTHON_EXTENSION)

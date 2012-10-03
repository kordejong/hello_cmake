CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(GREETER)

# Whether or not to create a bundle with all prerequisites included.
SET(ENABLE_FIXUP_BUNDLE ON)

INCLUDE(global_settings)
ADD_SUBDIRECTORY(sources)

IF(APPLE)
    SET(CPACK_BINARY_DRAGNDROP ON)
ENDIF()
INCLUDE(CPack)

FIND_PACKAGE(Boost COMPONENTS python REQUIRED)
FIND_PACKAGE(PythonLibs REQUIRED)
INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${PYTHON_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
)
ADD_LIBRARY(hcworld-static
    STATIC
    world.cc
)
ADD_LIBRARY(hcworld-shared
    SHARED
    world.cc
)
ADD_LIBRARY(hcworld-python
    SHARED
    world_extension.cc
)
TARGET_LINK_LIBRARIES(hcworld-python
    hcworld-shared
    ${Boost_LIBRARIES}
    ${PYTHON_LIBRARIES}
)
CONFIGURE_PYTHON_EXTENSION(hcworld-python
    "hcworld"
)
INSTALL(
    TARGETS hcworld-static
    DESTINATION lib
    EXPORT HCWorldTargets
)
IF(APPLE)
    INSTALL(
        TARGETS hcworld-shared hcworld-python
        DESTINATION .
        EXPORT HCWorldTargets
    )
ELSE()
    INSTALL(
        TARGETS hcworld-shared hcworld-python
        DESTINATION lib
        EXPORT HCWorldTargets
    )
ENDIF()
INSTALL(
    FILES world.h
    DESTINATION include/world
)
INSTALL(
    EXPORT HCWorldTargets
    DESTINATION lib/cmake/hcworld
)

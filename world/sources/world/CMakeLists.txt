INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)
ADD_LIBRARY(hcworld-static
    STATIC
    world.cc
)
ADD_LIBRARY(hcworld-shared
    SHARED
    world.cc
)
INSTALL(
    TARGETS hcworld-static
    DESTINATION lib
    EXPORT HCWorldTargets
)
INSTALL(
    TARGETS hcworld-shared
    DESTINATION lib
    EXPORT HCWorldTargets
)
INSTALL(
    FILES world.h
    DESTINATION include/world
)
INSTALL(
    EXPORT HCWorldTargets
    DESTINATION lib/cmake/hcworld
)

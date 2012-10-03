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
    EXPORT hcworld-targets
)
INSTALL(
    TARGETS hcworld-shared
    DESTINATION bin
    EXPORT hcworld-targets
)
INSTALL(
    FILES world.h
    DESTINATION include/world
)
INSTALL(
    EXPORT hcworld-targets
    DESTINATION lib/hcworld
)

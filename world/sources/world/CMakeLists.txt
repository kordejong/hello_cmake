INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)
ADD_LIBRARY(hcworld
    SHARED
    world.cc
)
INSTALL(
    TARGETS hcworld
    RUNTIME bin
    LIBRARY lib
)

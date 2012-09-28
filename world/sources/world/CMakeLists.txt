INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)
ADD_LIBRARY(hcworld
    STATIC # SHARED
    world.cc
)
INSTALL(
    TARGETS hcworld
    # RUNTIME DESTINATION bin
    # LIBRARY DESTINATION lib
    DESTINATION lib
    EXPORT hcworld-targets
)
# ADD_CUSTOM_TARGET(headers
#     SOURCES world.h
# )
INSTALL(
    FILES world.h
    DESTINATION include/world
    # EXPORT hcworld-targets
)
INSTALL(
    EXPORT hcworld-targets
    DESTINATION lib/hcworld
)

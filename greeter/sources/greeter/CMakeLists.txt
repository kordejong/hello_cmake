INCLUDE(
    ${WORLD_PREFIX}/lib/hcworld
)
INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${WORLD_PREFIX}/include
)
ADD_EXECUTABLE(hcgreeter
    main.cc
)
TARGET_LINK_LIBRARIES(
    hcgreeter
    hcworld
)
INSTALL(
    TARGETS hcgreeter
    RUNTIME DESTINATION bin
)

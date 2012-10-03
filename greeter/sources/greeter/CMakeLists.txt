INCLUDE(
    ${WORLD_PREFIX}/lib/hcworld/hcworld-targets.cmake
)
INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${WORLD_PREFIX}/include
)
ADD_EXECUTABLE(hcgreeter-static
    main.cc
)
TARGET_LINK_LIBRARIES(
    hcgreeter-static
    hcworld-static
)
ADD_EXECUTABLE(hcgreeter-shared
    main.cc
)
TARGET_LINK_LIBRARIES(
    hcgreeter-shared
    hcworld-shared
)
INSTALL(
    TARGETS hcgreeter-static hcgreeter-shared
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)

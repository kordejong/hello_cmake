ADD_EXECUTABLE(world_test world_test)
TARGET_LINK_LIBRARIES(world_test
    world-shared
)

ADD_TEST(world_test ${CMAKE_CURRENT_BINARY_DIR}/world_test
    $BOOST_TEST_RUNTIME_PARAMETERS)

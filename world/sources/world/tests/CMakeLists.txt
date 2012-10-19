ADD_EXECUTABLE(world_test world_test)
TARGET_LINK_LIBRARIES(world_test
    world-shared
)

ADD_TEST(NAME world_test
    COMMAND world_test $BOOST_TEST_RUNTIME_PARAMETERS)

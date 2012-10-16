ADD_EXECUTABLE(world_test world_test)
TARGET_LINK_LIBRARIES(world_test
    world-shared
    ${Boost_CHRONO_LIBRARY}
    ${Boost_TIMER_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
)

ADD_TEST(world_test ${CMAKE_CURRENT_BINARY_DIR}/world_test
    $BOOST_TEST_RUNTIME_PARAMETERS)

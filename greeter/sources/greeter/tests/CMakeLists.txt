ADD_EXECUTABLE(greeter_test greeter_test)
TARGET_LINK_LIBRARIES(greeter_test
    world-shared
    ${Boost_CHRONO_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
)

ADD_TEST(NAME greeter_test
    COMMAND greeter_test $BOOST_TEST_RUNTIME_PARAMETERS)

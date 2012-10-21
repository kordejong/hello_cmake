ADD_SUBDIRECTORY(tests)

ADD_EXECUTABLE(greeter-static
    main
)
TARGET_LINK_LIBRARIES(greeter-static
    world-static
    ${Boost_CHRONO_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
)

ADD_EXECUTABLE(greeter-shared
    main
)
TARGET_LINK_LIBRARIES(greeter-shared
    world-shared
    ${Boost_CHRONO_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
)

INSTALL(
    TARGETS greeter-static greeter-shared
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

#include <sstream>
#define BOOST_TEST_MODULE greeter tests
#include <boost/test/included/unit_test.hpp>
#include "world/world.h"
#include "greeter/greeter.h"


BOOST_AUTO_TEST_SUITE(greeter)


BOOST_AUTO_TEST_CASE(greeter)
{
    hc::World world;
    std::ostringstream stream;
    hc::greet(world, stream);
    BOOST_CHECK_EQUAL(stream.str(), "Hello Earth!\n");
}


BOOST_AUTO_TEST_SUITE_END()

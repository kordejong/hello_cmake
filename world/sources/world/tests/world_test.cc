#define BOOST_TEST_MODULE world test
#include <boost/test/included/unit_test.hpp>
#include "world/world.h"


BOOST_AUTO_TEST_SUITE(world)


BOOST_AUTO_TEST_CASE(name)
{
    hc::World world;
    BOOST_CHECK_EQUAL(world.name(), "Earth");
}


BOOST_AUTO_TEST_CASE(spin)
{
    hc::World world;
    BOOST_CHECK_NO_THROW(world.spin());
}


BOOST_AUTO_TEST_SUITE_END()

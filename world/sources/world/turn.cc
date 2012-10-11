#include <cstdlib>
#include <iostream>
#include <boost/timer/timer.hpp>
#include "world/world.h"


int main(
    int argc,
    char** argv)
{
    // This drags in a dependency on the boost.timer library.
    boost::timer::auto_cpu_timer timer;

    std::cout << "Spinning the world...";
    hc::World world;
    world.spin();
    std::cout << std::endl;

    return EXIT_SUCCESS;
}

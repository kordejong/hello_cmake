#include <iostream>
#include "world/world.h"


int main(
        int argc,
        char** argv)
{
    hc::World world;
    std::cout << world.name() << std::endl;
    // hc::Greeter greeter;

    // greeter.greet(world, std::ostream);

    return EXIT_SUCCESS;
}

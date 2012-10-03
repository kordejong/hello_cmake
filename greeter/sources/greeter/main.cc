#include <cstdlib>
#include <iostream>
#include "world/world.h"
#include "greeter/greeter.h"


int main(
        int /* argc */,
        char** /* argv */)
{
    hc::World world;
    hc::greet(world, std::cout);
    return EXIT_SUCCESS;
}

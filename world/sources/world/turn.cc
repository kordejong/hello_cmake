#include <cstdlib>
#include <boost/chrono.hpp>
#include "world/world.h"


int main(
    int argc,
    char** argv)
{
    namespace bc = boost::chrono;

    bc::system_clock::time_point start = boost::chrono::system_clock::now();

    hc::World world;
    world.turn();

    bc::duration<double> duration = boost::chrono::system_clock::now() - start;

    std::cout << "Turning the world took " << duration.count() << " seconds\n";

    return EXIT_SUCCESS;
}

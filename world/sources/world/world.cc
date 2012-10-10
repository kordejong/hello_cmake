#include <cmath>
#include "world/world.h"


hc::World::World()

    : _name("World")

{
}


hc::World::~World()
{
}


std::string const& hc::World::name() const
{
    return _name;
}


void hc::World::turn()
{
    // Burn some time.
    for(long i = 0; i < 1000000; ++i) {
        std::sqrt(123.456L);
    }
}

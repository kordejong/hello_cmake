#include "world/world.h"


hc::World::World()

    : _name("World")

{
}


hc::World::~World()
{
}


std::string hc::World::name() const
{
  return _name;
}

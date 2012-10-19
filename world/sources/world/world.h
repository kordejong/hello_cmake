#ifndef INCLUDED_HELLO_CMAKE_WORLD_WORLD
#define INCLUDED_HELLO_CMAKE_WORLD_WORLD


#include <string>
#include "world/config.h"


namespace hc {

class WORLD_DECL World
{

public:

                   World               ();

                   ~World              ();

    std::string const& name            () const;

    // double         age                 () const;

    void           spin                ();

private:

    std::string    _name;

};

} // namespace hc

#endif

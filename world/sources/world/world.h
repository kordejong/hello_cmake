#ifndef INCLUDED_HELLO_CMAKE_WORLD
#define INCLUDED_HELLO_CMAKE_WORLD


#include <string>


namespace hc {

class World
{

public:

                   World               ();

                   ~World              ();

    std::string const& name            () const;

private:

    std::string    _name;

};

} // namespace hc

#endif

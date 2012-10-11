#include <cmath>
#include <boost/chrono.hpp>
// #include <boost/random.hpp>
#include "world/world.h"


hc::World::World()

    : _name("Earth")

{
}


hc::World::~World()
{
}


std::string const& hc::World::name() const
{
    return _name;
}


// double hc::World::age() const
// {
//   typedef boost::random::normal_distribution<double> Distribution;
//   typedef boost::random::mt19937 NumberGenerator;
//   typedef boost::variate_generator<NumberGenerator&, Distribution> Generator;
// 
//   Distribution distribution(4.54e+9, 45.4e+6);
//   NumberGenerator number_generator;
//   Generator generator(number_generator, distribution);
// 
//   return generator();
// }


/*!
  This function drags in a dependency on the boost.chrono library.
*/
void hc::World::spin()
{
    namespace bc = boost::chrono;

    bc::system_clock::time_point start = boost::chrono::system_clock::now();

    // Burn some time, spinning is hard.
    for(long i = 0; i < 10000000; ++i) {
        std::sqrt(123.456L);
    }

    bc::duration<double> duration = boost::chrono::system_clock::now() - start;

    // return duration.count();
}

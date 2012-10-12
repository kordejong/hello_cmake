#include <Python.h>
#include <boost/python.hpp>
#include "world/world.h"


BOOST_PYTHON_MODULE(world)
{
  namespace bp = boost::python;

  bp::class_<hc::World>("World")
      .add_property("name", bp::make_function(&hc::World::name,
          bp::return_value_policy<bp::copy_const_reference>()))
      ;
}

#include <Python.h>
#include <boost/python.hpp>
#include "world/world.h"


BOOST_PYTHON_MODULE(hcworld)
{
  namespace bp = boost::python;

  bp::class_<hc::World>("World")
      .def("name", &hc::World::name,
          bp::return_value_policy<bp::reference_existing_object>())
      ;
}

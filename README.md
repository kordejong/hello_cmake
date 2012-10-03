hello_cmake
===========

Project for trying out CMake code.

The hello_cmake repository contains two projects managed by CMake build scripts. The first project, called `world`, builds a static and shared library. The second project, called `greeter`, builds an executable that depends on the functionality of the `world` project.

Requirements:
* For the `greeter` project it should be easy to find the targets provided by the `world` project. The `world` project must export its targets and `greeter` must import `world`'s targets.
* After building `greeter`'s executable it must be possible to run the executable without changing the environment settings. `world`'s shared library must be found.
* After installing the `greeter` project, it must be possible to run the executable without changing the environment settings.
* After moving the install location of the `greeter` project, it must be possible to run the executable without changing the environment settings.

See also:
* http://www.vtk.org/Wiki/CMake/Tutorials/Exporting_and_Importing_Targets
* CMake RPATH wiki page.
* HDF5 installs manifest file on Windows. We may need that too.

Notes:
* Targets may depend on shared libraries not build by projects, like boost, icu, qt, etc. If we can assume these will exist at the same location on the install machine, we can set `CMAKE_INSTALL_RPATH_USE_LINK_PATH` to `TRUE`. Otherwise we may need to ship these libraries ourselves, and set `CMAKE_INSTALL_RPATH_USE_LINK_PATH` to `FALSE`.

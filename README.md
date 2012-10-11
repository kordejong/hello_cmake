hello_cmake
===========
Project for trying out CMake code.

Requirements:
* After building a project, one must be able to use the targets without have to tweak the environment settings. Other project's and 3rd party shared libraries the project's targets depend on must be found.
* After installing a project, and tweaking the environment settings to find other project's and 3rd party shared libraries, one must be able to use the targets.
* After installing a project's package, one must be able to use the targets with a minimal amount of environment setting tweaks. At most, the user should have to add a single entry to PATH and/or PYTHONPATH.
* It must be possible  to move a directory containing an installed package. This should not have an effect on the useability of the software.

This project is about meeting these requirements. There is a minimal amount of C++ source code in this project. Just enough to make sure that there are some interesting dependencies between various targets and 3rd party shared libraries.

The hello_cmake repository contains two projects managed by CMake build scripts. The first project, called `world`, builds targets with these dependencies:
* static library
* shared library
* application -> `world`'s static library and 3rd party shared library.
* application -> `world`'s shared library and 3rd party shared library.
* python extension -> `world`'s shared library and 3rd party shared libraries.

The second project, called `greeter`, builds targets with these dependencies:
* application -> `world`'s static library and 3rd party shared library.
* application -> `world`'s shared library and 3rd party shared library.

Notes:
* Targets often depend on shared libraries not build by the installed project, like boost, icu, qt, etc. If we can assume these will exist at the same location on the install machine, we can set `CMAKE_INSTALL_RPATH_USE_LINK_PATH` to `TRUE`. Otherwise we may need to ship these libraries ourselves, and set `CMAKE_INSTALL_RPATH_USE_LINK_PATH` to `FALSE`.
* Don't confuse installing a project with packaging a project. During installation, you normally don't install targets of other projects. They should already be installed. During packaging, you may want to put all kinds of stuff in the package, including 3rd party shared libraries and shared libraries from several of your own projects.
* `FIXUP_BUNDLE` can be used to copy prerequisites of exes and dlls into the install area to create a self-contained 'bundle'. This can be used to create self-contained packages.

See also:
* http://www.vtk.org/Wiki/CMake/Tutorials/Exporting_and_Importing_Targets
* CMake RPATH wiki page.
* HDF5 installs manifest file on Windows. We may need that too.
* http://www.cmake.org/Wiki/BundleUtilitiesExample

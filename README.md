hello_cmake
===========
Project for trying out CMake code.

Requirements
------------
* After *building a project*, one must be able to use the targets without have to tweak the environment settings. Other project's and 3rd party shared libraries the project's targets depend on must be found.
* After *installing a project*, and tweaking the environment settings to find other project's and 3rd party shared libraries (setting LD_LIBRARY_PATH on *nix, for example), one must be able to use the targets.
* After *installing a project's package*, one must be able to use the targets with a minimal amount of environment setting tweaks. At most, the user should have to add a single entry to PATH and/or PYTHONPATH. I should not be necessary to set environment variables specifically for the project's exes and dlls to find other dlls.
* It must be possible to move a directory containing an installed package. This should not have an effect on the useability of the software. The package should be self-contained.
* All of the above should work on Linux, Windows and MacOS.

This project is about figuring out how to use CMake to meet these requirements. There is a minimal amount of C++ source code in this project. Just enough to make sure that there are some interesting dependencies between various targets and 3rd party shared libraries.

Targets
-------
The hello_cmake repository contains two projects managed by CMake build scripts. The first project, called `world`, builds targets with these dependencies:
* static library
* shared library
* application -> `world`'s static library and 3rd party shared library.
* application -> `world`'s shared library and 3rd party shared library.
* python extension -> `world`'s shared library and 3rd party shared libraries.

The second project, called `greeter`, builds targets with these dependencies:
* application -> `world`'s static library and 3rd party shared library.
* application -> `world`'s shared library and 3rd party shared library.

The project contains a script called `build_hello_cmake.sh` that builds, installs, unpacks, moves the sources and built targets, and tests whether the above mentioned requirements are met. This script can be called by yet another script as folows (example for Linux, using a bash script):

```bash
hello_cmake_root=<path to>/hello_cmake
build_hello_cmake=$hello_cmake_root/environment/scripts/build_hello_cmake.sh
boost_root="$<path to boost>"
python_root="$<path to python>"
ld_library_path="$boost_root/lib:$python_root/lib"

cmake_options="
    -DCMAKE_PREFIX_PATH="$python_root"
    -DBOOST_ROOT="$boost_root"
    -DHC_ENABLE_FIXUP_BUNDLE:BOOL=OFF
"

HELLO_CMAKE_ROOT=$hello_cmake_root $build_hello_cmake "$ld_library_path" \
    $cmake_options
```

To detect whether all shared libraries are found in the different usage scenarios, this script can be called like this:

```bash
build_hello_cmake_on_linux.sh 2>&1 | tee messages.txt
cat messages.txt | grep "not found"
```

All is well if the last command doesn't print anything.

Notes
-----
* Targets often depend on shared libraries not build by the installed project, like boost, icu, qt, etc. If we can assume these will exist at the same location on the install machine, we can set `CMAKE_INSTALL_RPATH_USE_LINK_PATH` to `TRUE`. Otherwise we may need to ship these libraries ourselves, and set `CMAKE_INSTALL_RPATH_USE_LINK_PATH` to `FALSE`.
* Don't confuse installing a project with packaging a project. During installation, you normally don't install targets of other projects. They should already be installed. During packaging, you may want to put all kinds of stuff in the package, including 3rd party shared libraries and shared libraries from several of your own projects.
* `FIXUP_BUNDLE` can be used to copy prerequisites of exes and dlls into the install area to create a self-contained 'bundle'. This can be used to create self-contained packages.

See also:
* http://www.vtk.org/Wiki/CMake/Tutorials/Exporting_and_Importing_Targets
* CMake RPATH wiki page.
* HDF5 installs manifest file on Windows. We may need that too.
* http://www.cmake.org/Wiki/BundleUtilitiesExample
* http://www.vtk.org/Wiki/CMake/Tutorials/How_to_create_a_ProjectConfig.cmake_file


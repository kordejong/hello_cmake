#!/usr/bin/env bash
set -e
set -x

build_type="Release"
build_root="$HOME/tmp"

# Build and install the world project. -----------------------------------------
world_source="$HELLO_CMAKE/world"
world_build="$build_root/world_build"
world_install="$build_root/world_install"

cd $build_root
rm -fr $world_build $world_install
mkdir $world_build
cd $world_build

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=$build_type -DCMAKE_INSTALL_PREFIX=$world_install $world_source
cmake --build . --target install

# Build and install the greeter project. ---------------------------------------
greeter_source="$HELLO_CMAKE/greeter"
greeter_build="$build_root/greeter_build"
greeter_install="$build_root/greeter_install"

cd $build_root
rm -fr $greeter_build $greeter_install
mkdir $greeter_build
cd $greeter_build

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=$build_type -DWORLD_PREFIX=$world_install -DCMAKE_INSTALL_PREFIX=$greeter_install $greeter_source
# make VERBOSE=1
cmake --build . --target install

# Run executable. --------------------------------------------------------------

# From build location. Targets are allowed to depend on world's install
# location.
$greeter_build/sources/greeter/hcgreeter-static
$greeter_build/sources/greeter/hcgreeter-shared

# Move world's install location to make sure its targets are not used by
# greeter's targets.
mv $world_install ${world_install}_moved

# From install location. Targets are not allowed to depend on world's install
# location.
$greeter_install/bin/hcgreeter-static
$greeter_install/bin/hcgreeter-shared

# Move greeter's install location to make sure its targets don't depend on the
# install location.
mv $greeter_install ${greeter_install}_moved
${greeter_install}_moved/bin/hcgreeter-static
${greeter_install}_moved/bin/hcgreeter-shared

find $greeter_install

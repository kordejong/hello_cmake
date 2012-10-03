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

cmake -G "Unix Makefiles" -DCMAKE_MODULE_PATH=$HELLO_CMAKE/environment/templates/cmake -DCMAKE_BUILD_TYPE=$build_type -DCMAKE_INSTALL_PREFIX=$world_install $world_source
cmake --build . --target install

# Build and install the greeter project. ---------------------------------------
greeter_source="$HELLO_CMAKE/greeter"
greeter_build="$build_root/greeter_build"
greeter_install="$build_root/greeter_install"

cd $build_root
rm -fr $greeter_build $greeter_install
mkdir $greeter_build
cd $greeter_build
cmake -G "Unix Makefiles" -DCMAKE_MODULE_PATH=$HELLO_CMAKE/environment/templates/cmake -DCMAKE_BUILD_TYPE=$build_type -DWORLD_PREFIX=$world_install -DCMAKE_INSTALL_PREFIX=$greeter_install $greeter_source
# make VERBOSE=1
cd ..

cmake --build $greeter_build
cmake --build $greeter_build --target install
cmake --build $greeter_build --target package

# Run executable. --------------------------------------------------------------
if [ `uname -o 2>/dev/null` ]; then
    os=`uname -o`
else
    os=`uname`
fi

check_dependencies() {
    target=$1
    if [ $os == "GNU/Linux" ]; then
        chrpath --list $target
        ldd $target
    elif [ $os == "Darwin" ]; then
        otool -L $target
    elif [ $os == "Cygwin" ]; then
        cygcheck $target
    else
        echo "Unknown OS"
        exit 1
    fi
}

# From build location. Targets are allowed to depend on world's install
# location.
$greeter_build/sources/greeter/hcgreeter-static
check_dependencies $greeter_build/sources/greeter/hcgreeter-shared
$greeter_build/sources/greeter/hcgreeter-shared

# We cannot run the executable from the install location since it depends on
# the world shared library which is installed somewhere else.

# From install location.
$greeter_install/bin/hcgreeter-static
check_dependencies $greeter_install/bin/hcgreeter-shared
$greeter_install/bin/hcgreeter-shared

# Move world's install location to make sure its targets are not used by
# greeter's targets.
rm -fr ${world_install}_moved
mv $world_install ${world_install}_moved

# From install location. Targets are not allowed to depend on world's install
# location.
$greeter_install/bin/hcgreeter-static
check_dependencies $greeter_install/bin/hcgreeter-shared
$greeter_install/bin/hcgreeter-shared

# Move greeter's install location to make sure its targets don't depend on the
# install location.
rm -fr ${greeter_install}_moved
mv $greeter_install ${greeter_install}_moved
${greeter_install}_moved/bin/hcgreeter-static
check_dependencies ${greeter_install}_moved/bin/hcgreeter-shared
${greeter_install}_moved/bin/hcgreeter-shared

find ${greeter_install}_moved


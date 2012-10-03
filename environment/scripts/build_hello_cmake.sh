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
cmake -G "Unix Makefiles" -DCMAKE_MODULE_PATH=$HELLO_CMAKE/environment/templates/cmake -DCMAKE_BUILD_TYPE=$build_type -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DWORLD_PREFIX=$world_install -DCMAKE_INSTALL_PREFIX=$greeter_install $greeter_source
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

function executable_name() {
    local prefix=$1
    local target=$2
    local variable_name=$3

    if [ $os == "GNU/Linux" ]; then
        eval $variable_name=$prefix/$target
    elif [ $os == "Darwin" ]; then
        eval $variable_name=$prefix/$target.app/Contents/MacOS/$target
    elif [ $os == "Cygwin" ]; then
        eval $variable_name=$prefix/$target.exe
    else
        echo "Unknown OS"
        exit 1
    fi
}

function execute() {
    local prefix=$1
    local target=$2
    executable_name $prefix $target executable
    $executable
}

function check_dependencies() {
    local prefix=$1
    local target=$2
    executable_name $prefix $target executable

    if [ $os == "GNU/Linux" ]; then
        chrpath --list $executable
        ldd $executable
    elif [ $os == "Darwin" ]; then
        otool -L $executable
    elif [ $os == "Cygwin" ]; then
        cygcheck $executable
    else
        echo "Unknown OS"
        exit 1
    fi
}

# From build location.
# Targets are allowed to depend on world's install location.
# TODO Darwin: How to get the install name of world's dll in the exe?
if [ $os != "Darwin" ]; then
    execute $greeter_build/sources/greeter hcgreeter-static
    check_dependencies $greeter_build/sources/greeter hcgreeter-shared
    execute $greeter_build/sources/greeter hcgreeter-shared
fi

# From install location.
if [ $os == "Darwin" ]; then
    execute $greeter_install hcgreeter-static
    check_dependencies $greeter_install hcgreeter-shared
    execute $greeter_install hcgreeter-shared
else
    execute $greeter_install/bin hcgreeter-static
    check_dependencies $greeter_install/bin hcgreeter-shared
    execute $greeter_install/bin hcgreeter-shared
fi

# Move world's install location to make sure its targets are not used by
# greeter's targets.
rm -fr ${world_install}_moved
mv $world_install ${world_install}_moved

# From install location.
# Targets are not allowed to depend on world's install location.
if [ $os == "Darwin" ]; then
    execute $greeter_install hcgreeter-static
    check_dependencies $greeter_install hcgreeter-shared
    execute $greeter_install hcgreeter-shared
else
    execute $greeter_install/bin hcgreeter-static
    check_dependencies $greeter_install/bin hcgreeter-shared
    execute $greeter_install/bin hcgreeter-shared
fi

# Move greeter's install location to make sure its targets don't depend on the
# install location.
rm -fr ${greeter_install}_moved
mv $greeter_install ${greeter_install}_moved

if [ $os == "Darwin" ]; then
    execute ${greeter_install}_moved hcgreeter-static
    check_dependencies ${greeter_install}_moved hcgreeter-shared
    execute ${greeter_install}_moved hcgreeter-shared
else
    execute ${greeter_install}_moved/bin hcgreeter-static
    check_dependencies ${greeter_install}_moved/bin hcgreeter-shared
    execute ${greeter_install}_moved/bin hcgreeter-shared
fi

find ${greeter_install}_moved

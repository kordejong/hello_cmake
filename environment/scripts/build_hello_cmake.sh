#!/usr/bin/env bash
set -e

ld_library_path="$1"

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


function extension_name() {
    local prefix=$1
    local target=$2
    local variable_name=$3

    if [ $os == "GNU/Linux" ]; then
        eval $variable_name=$prefix/$target.so
    elif [ $os == "Darwin" ]; then
        eval $variable_name=$prefix/$target.app/Contents/MacOS/$target.pyd
    elif [ $os == "Cygwin" ]; then
        eval $variable_name=$prefix/$target.pyd
    else
        echo "Unknown OS"
        exit 1
    fi
}


function execute() {
    local prefix=$1
    local target=$2
    local ld_library_path=$3
    executable_name $prefix $target executable
    LD_LIBRARY_PATH="$ld_library_path" $executable
}


function check_dependencies() {
    local executable=$1
    local ld_library_path=$2
    echo $executable
    if [ $os == "GNU/Linux" ]; then
        chrpath --list $executable
        LD_LIBRARY_PATH="$ld_library_path" ldd $executable
    elif [ $os == "Darwin" ]; then
        otool -L $executable
    elif [ $os == "Cygwin" ]; then
        cygcheck $executable
    else
        echo "Unknown OS"
        exit 1
    fi
}


function check_exe_dependencies() {
    local prefix=$1
    local target=$2
    local ld_library_path=$3
    executable_name $prefix $target executable
    check_dependencies $executable $ld_library_path
}


function check_pyd_dependencies() {
    local prefix=$1
    local target=$2
    local ld_library_path=$3
    extension_name $prefix $target extension
    check_dependencies $extension $ld_library_path
}


function print_message() {
    local message=$1
    echo "*********************************************************************"
    echo "* $message"
    echo "*********************************************************************"
}


function package_name() {
    local project_name=$1
    local variable_name=$2

    if [ $os == "GNU/Linux" ]; then
        eval $variable_name=$project_name-0.1.1-Linux.tar.gz
    elif [ $os == "Darwin" ]; then
        eval $variable_name=$project_name-0.1.1-Darwin.tar.gz
    elif [ $os == "Cygwin" ]; then
        eval $variable_name=$project_name-0.1.1-Windows.zip
    else
        echo "Unknown OS"
        exit 1
    fi
}


function split_package_extension() {
    local file_name=$1
    local variable_name=$2
    # local file_name=$(basename "$file_name")
    # local extension="${file_name##*.}"

    if [ $os == "GNU/Linux" ]; then
        file_name="${file_name%.tar.gz}"
    elif [ $os == "Darwin" ]; then
        file_name="${file_name%.tar.gz}"
    elif [ $os == "Cygwin" ]; then
        file_name="${file_name%.zip}"
    else
        echo "Unknown OS"
        exit 1
    fi

    eval $variable_name=$file_name
}


function unpack_package() {
    local project_name=$1
    local build_root=$2
    local unpack_root=$3
    local variable_name=$4
    local cwd=`pwd`
    package_name $project_name pkg_name
    cd $unpack_root
    tar zxf $build_root/$pkg_name
    cd $cwd
    split_package_extension $pkg_name prefix
    eval $variable_name=$unpack_root/$prefix
}


if [ ! $HELLO_CMAKE_ROOT ]; then
  echo "Set HELLO_CMAKE_ROOT to the location of the hello_cmake sources"
  exit 1
fi


build_type="Release"
build_root="$HOME/tmp"


# set -x

# Build, install, package the world project. -----------------------------------
world_source="$HELLO_CMAKE_ROOT/world"
world_build="$build_root/world_build"
world_install="$build_root/world_install"
world_unpack="$build_root/world_unpack"

cmake_options="
    -DCMAKE_MODULE_PATH="$HELLO_CMAKE_ROOT/environment/templates/cmake"
    -DCMAKE_BUILD_TYPE=$build_type
    -DCMAKE_INSTALL_PREFIX="$world_install"
"

cd $build_root
rm -fr $world_build $world_install $world_unpack
mkdir $world_build $world_unpack
cd $world_build
cmake $cmake_options $world_source
cd ..

cmake --build $world_build
print_message "Dependencies in $world_build."
check_exe_dependencies $world_build/sources/world turn_world-shared
check_pyd_dependencies $world_build/sources/world world
execute $world_build/sources/world turn_world-static
execute $world_build/sources/world turn_world-shared

cmake --build $world_build --target install
print_message "Dependencies in $world_install."
check_exe_dependencies $world_install/bin turn_world-shared $ld_library_path
check_pyd_dependencies $world_install/python/world world $ld_library_path
execute $world_install/bin turn_world-static $ld_library_path
execute $world_install/bin turn_world-shared $ld_library_path

### cmake --build $world_build --target package
### unpack_package "WORLD" $world_build $world_unpack prefix
### print_message "Dependencies in $prefix."
### check_exe_dependencies $prefix/bin turn_world-shared
### check_pyd_dependencies $prefix/python/world world
### execute $prefix/bin turn_world-static
### execute $prefix/bin turn_world-shared

exit 0

# Build and install the greeter project. ---------------------------------------
greeter_source="$HELLO_CMAKE_ROOT/greeter"
greeter_build="$build_root/greeter_build"
greeter_install="$build_root/greeter_install"

cmake_options="
    -DCMAKE_MODULE_PATH="$HELLO_CMAKE_ROOT/environment/templates/cmake"
    -DCMAKE_BUILD_TYPE=$build_type
    -DCMAKE_INSTALL_PREFIX="$greeter_install"
    -DWORLD_ROOT="$world_install"
"

cd $build_root
rm -fr $greeter_build $greeter_install
mkdir $greeter_build
cd $greeter_build
cmake $cmake_options $greeter_source
cd ..
cmake --build $greeter_build
cmake --build $greeter_build --target install
cmake --build $greeter_build --target package

# Run executable. --------------------------------------------------------------
# From build location.
# Targets are allowed to depend on world's install location.
# TODO Darwin: How to get the install name of world's dll in the exe?
if [ $os != "Darwin" ]; then
    execute $greeter_build/sources/greeter hcgreeter-static
    check_exe_dependencies $greeter_build/sources/greeter hcgreeter-shared
    execute $greeter_build/sources/greeter hcgreeter-shared
fi

# From install location.
if [ $os == "Darwin" ]; then
    execute $greeter_install hcgreeter-static
    check_exe_dependencies $greeter_install hcgreeter-shared
    execute $greeter_install hcgreeter-shared
else
    execute $greeter_install/bin hcgreeter-static
    check_exe_dependencies $greeter_install/bin hcgreeter-shared
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
    check_exe_dependencies $greeter_install hcgreeter-shared
    execute $greeter_install hcgreeter-shared
else
    execute $greeter_install/bin hcgreeter-static
    check_exe_dependencies $greeter_install/bin hcgreeter-shared
    execute $greeter_install/bin hcgreeter-shared
fi

# Move greeter's install location to make sure its targets don't depend on the
# install location.
rm -fr ${greeter_install}_moved
mv $greeter_install ${greeter_install}_moved

if [ $os == "Darwin" ]; then
    execute ${greeter_install}_moved hcgreeter-static
    check_exe_dependencies ${greeter_install}_moved hcgreeter-shared
    execute ${greeter_install}_moved hcgreeter-shared
else
    execute ${greeter_install}_moved/bin hcgreeter-static
    check_exe_dependencies ${greeter_install}_moved/bin hcgreeter-shared
    execute ${greeter_install}_moved/bin hcgreeter-shared
fi

find ${greeter_install}_moved

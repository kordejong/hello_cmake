#!/usr/bin/env bash
set -e

cmake_generator="$1"
ld_library_path="$2"
shift
shift
general_cmake_options="$*"

check_world_dependencies=1
check_greeter_dependencies=1

width_in_characters=$(tput cols)
eval printf -v header_line '%.0s-' {1..$width_in_characters}

if [ `uname -o 2>/dev/null` ]; then
    os=`uname -o`
else
    os=`uname`
fi

build_type="Release"

export CTEST_OUTPUT_ON_FAILURE=1


function executable_name() {
    local prefix=$1
    local target=$2
    local start_location=$3
    local variable_name=$4

    if [ $os == "GNU/Linux" ]; then
        eval $variable_name=$prefix/$target
    elif [ $os == "Darwin" ]; then
        if [ $start_location == "package_build" ]; then
            # eval $variable_name=$prefix/$target.app/Contents/MacOS/$target
            eval $variable_name=$prefix/$target
        elif [ $start_location == "unpack" ]; then
            # eval $variable_name=$prefix/$target.app/Contents/MacOS/$target
            eval $variable_name=$prefix/$target
        else
            eval $variable_name=$prefix/$target
        fi
    elif [ $os == "Cygwin" ]; then
        if [ $start_location == "install_build" ]; then
            eval $variable_name=$prefix/$build_type/$target.exe
        else
            eval $variable_name=$prefix/$target.exe
        fi
    else
        echo "Unknown OS"
        exit 1
    fi
}


function extension_name() {
    local prefix=$1
    local target=$2
    local start_location=$3
    local variable_name=$4

    if [ $os == "GNU/Linux" ]; then
        eval $variable_name=$prefix/$target.so
    elif [ $os == "Darwin" ]; then
        eval $variable_name=$prefix/$target.so
        # eval $variable_name=$prefix/$target.app/Contents/MacOS/$target.pyd
    elif [ $os == "Cygwin" ]; then
        if [ $start_location == "install_build" ]; then
            eval $variable_name=$prefix/$build_type/$target.pyd
        else
            eval $variable_name=$prefix/$target.pyd
        fi
    else
        echo "Unknown OS"
        exit 1
    fi
}


function execute() {
    local prefix=$1
    local target=$2
    local start_location=$3
    local ld_library_path=$4
    local ext_project_root=$5

    executable_name $prefix $target $start_location executable

    if [ "$ext_project_root" != "" ]; then
        if [ $os == "Cygwin" ]; then
            ld_library_path="`cygpath -u $ext_project_root`/bin:$ld_library_path"
        fi
    fi

    if [ $os == "GNU/Linux" ]; then
        $executable
    elif [ $os == "Darwin" ]; then
        $executable
    elif [ $os == "Cygwin" ]; then
        if [ $start_location == "install_build" ]; then
            ld_library_path="`cygpath -u $prefix`/../lib/$build_type:$ld_library_path"
        else
            ld_library_path="`cygpath -u $prefix`/../lib:$ld_library_path"
        fi
        PATH="$ld_library_path:$PATH" $executable
    else
        echo "Unknown OS"
        exit 1
    fi
}


try_python_extension() {
    local python_path=$1
    local start_location=$2
    local ld_library_path=$3
    local script="import world; \
        print(\"Hello {} from Python!\".format(world.World().name))"

    if [ $os == "GNU/Linux" ]; then
        PYTHONPATH=$python_path python -c "$script"
    elif [ $os == "Darwin" ]; then
        PYTHONPATH=$python_path python -c "$script"
    elif [ $os == "Cygwin" ]; then
        if [ $start_location == "install_build" ]; then
            ld_library_path="`cygpath -u $python_path`/../lib/$build_type:$ld_library_path"
            python_path="$python_path/$build_type"
        else
            ld_library_path="`cygpath -u $python_path`/../../bin:$ld_library_path"
        fi
        PATH="$ld_library_path:$PATH" \
            PYTHONPATH=$python_path python -c "$script"
    else
        echo "Unknown OS"
        exit 1
    fi
}


function run_tests() {
    local prefix=$1
    local ld_library_path=$2
    local ext_project_root=$3

    if [ "$ext_project_root" != "" ]; then
        if [ $os == "Cygwin" ]; then
            ld_library_path="`cygpath -u $ext_project_root`/bin:$ld_library_path"
        fi
    fi

    if [ $os == "GNU/Linux" ]; then
        cmake --build $wrld_inst_bld --config $build_type --target test
    elif [ $os == "Darwin" ]; then
        cmake --build $wrld_inst_bld --config $build_type --target test
    elif [ $os == "Cygwin" ]; then
        PATH="$ld_library_path:`cygpath -u $prefix`/lib/$build_type:$PATH" \
            cmake --build $prefix --config $build_type --target run_tests
    else
        echo "Unknown OS"
        exit 1
    fi
}


function check_dependencies() {
    local executable=$1
    local start_location=$2
    local ld_library_path=$3
    echo $executable
    if [ $os == "GNU/Linux" ]; then
        chrpath --list $executable
        ldd $executable
    elif [ $os == "Darwin" ]; then
        otool -L $executable
    elif [ $os == "Cygwin" ]; then
        if [ $start_location == "install_build" ]; then
            ld_library_path="`dirname \`cygpath -u $executable\``/../../lib/$build_type:$ld_library_path"
        else
            ld_library_path="`dirname \`cygpath -u $executable\``/../lib:$ld_library_path"
        fi
        PATH="$ld_library_path:$PATH" cygcheck $executable
    else
        echo "Unknown OS"
        exit 1
    fi
}


function check_exe_dependencies() {
    local prefix=$1
    local target=$2
    local start_location=$3
    local ld_library_path=$4
    local ext_project_root=$5

    if [ "$ext_project_root" != "" ]; then
        if [ $os == "Cygwin" ]; then
            ld_library_path="`cygpath -u $ext_project_root`/bin:$ld_library_path"
        # else
        #     ld_library_path="$ext_project_root/lib:$ld_library_path"
        fi
    fi

    executable_name $prefix $target $start_location executable
    check_dependencies $executable $start_location $ld_library_path
}


function check_pyd_dependencies() {
    local prefix=$1
    local target=$2
    local start_location=$3
    local ld_library_path=$4
    extension_name $prefix $target $start_location extension
    check_dependencies $extension $start_location $ld_library_path
}


function print_message() {
    local message=$1
    echo $header_line
    echo "$message"
}


function new_test() {
    local message=$1
    echo $header_line
    echo "$message"
    echo $header_line
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


os=`uname -o`
build_type="Release"
build_root="$HOME/tmp"
if [ $os == "Cygwin" ]; then
    build_root=`cygpath -m $build_root`
fi


# Build, install, package the world project. -----------------------------------
wrld_src="$HELLO_CMAKE_ROOT/world"
wrld_inst_bld="$build_root/world_install_build"
wrld_pkg_bld="$build_root/world_package_build"
wrld_inst="$build_root/world_install"
wrld_unpk="$build_root/world_unpack"

world_cmake_options="
    -DCMAKE_MODULE_PATH:PATH="$HELLO_CMAKE_ROOT/environment/templates/cmake"
    -DCMAKE_BUILD_TYPE=$build_type
    # -DCMAKE_INSTALL_PREFIX:PATH="$wrld_inst"
    $general_cmake_options
"

cd $build_root
rm -fr $wrld_inst_bld $wrld_pkg_bld $wrld_inst $wrld_unpk
mkdir $wrld_inst_bld $wrld_pkg_bld $wrld_unpk

# Configure for standard install target, without creating a self-contained
# package.
set -e
cd $wrld_inst_bld
cmake -G "$cmake_generator" $world_cmake_options $wrld_src
cd ..

# Exectute from build directory should just work. It is fine if paths to
# external dlls are hardcoded in the exes and dlls. It is not fine if
# environment settings like LD_LIBRARY_PATH on Linux are needed to be able
# to use the targets.
new_test "Execute from install build directory"
cmake --build $wrld_inst_bld --config $build_type
if [ $check_world_dependencies == 1 ]; then
    print_message "Dependencies in $wrld_inst_bld:"
    check_exe_dependencies $wrld_inst_bld/bin turn_world-static \
        "install_build" $ld_library_path
    check_exe_dependencies $wrld_inst_bld/bin turn_world-shared \
        "install_build" $ld_library_path
    check_pyd_dependencies $wrld_inst_bld/lib world "install_build" $ld_library_path
fi
run_tests $wrld_inst_bld $ld_library_path
execute $wrld_inst_bld/bin turn_world-static "install_build" $ld_library_path
execute $wrld_inst_bld/bin turn_world-shared "install_build" $ld_library_path
try_python_extension $wrld_inst_bld/lib "install_build" $ld_library_path

# Exectute from install directory should work, given the ld_library_path.
new_test "Execute from install directory"
cmake --build $wrld_inst_bld --config $build_type --target install
if [ $check_world_dependencies == 1 ]; then
    print_message "Dependencies in $wrld_inst:"
    check_exe_dependencies $wrld_inst/bin turn_world-static "install" \
        $ld_library_path
    check_exe_dependencies $wrld_inst/bin turn_world-shared "install" \
        $ld_library_path
    check_pyd_dependencies $wrld_inst/python/world world "install" $ld_library_path
fi
execute $wrld_inst/bin turn_world-static "install" $ld_library_path
execute $wrld_inst/bin turn_world-shared "install" $ld_library_path
try_python_extension $wrld_inst/python/world "install" $ld_library_path

### # Configure for package target, creating a self-contained package.
### cd $wrld_pkg_bld
### cmake $world_cmake_options -DHC_ENABLE_FIXUP_BUNDLE:BOOL=ON $wrld_src
### cd ..
### 
### # Exectute from build directory should just work. Absolute paths to shared
### # libs baked into exes and dlls.
### new_test "Execute from package build directory"
### cmake --build $wrld_pkg_bld --config $build_type
### if [ $check_world_dependencies == 1 ]; then
###     print_message "Dependencies in $wrld_pkg_bld:"
###     check_exe_dependencies $wrld_pkg_bld/sources/world turn_world-static "package_build"
###     check_exe_dependencies $wrld_pkg_bld/sources/world turn_world-shared "package_build"
###     check_pyd_dependencies $wrld_pkg_bld/sources/world world
### fi
### execute $wrld_pkg_bld/sources/world turn_world-static "package_build"
### execute $wrld_pkg_bld/sources/world turn_world-shared "package_build"
### PYTHONPATH=$wrld_pkg_bld/sources/world python -c "import world; \
###     print(\"Hello {} from Python!\".format(world.World().name))"
### 
### # Exectute from unpack directory should just work. Relative paths to shared
### # libs baked into exes and dlls.
### new_test "Execute from unpack directory"
### cmake --build $wrld_pkg_bld --config $build_type --target package
### unpack_package "WORLD" $wrld_pkg_bld $wrld_unpk prefix
### if [ $check_world_dependencies == 1 ]; then
###     print_message "Dependencies in $prefix:"
###     check_exe_dependencies $prefix/bin turn_world-static "unpack"
###     check_exe_dependencies $prefix/bin turn_world-shared "unpack"
###     check_pyd_dependencies $prefix/python/world world
### fi
### execute $prefix/bin turn_world-static "unpack"
### execute $prefix/bin turn_world-shared "unpack"
### PYTHONPATH=$prefix/python/world python -c "import world; \
###     print(\"Hello {} from Python!\".format(world.World().name))"

# Build, install, package the greeter project. ---------------------------------
grtr_src="$HELLO_CMAKE_ROOT/greeter"
grtr_inst_bld="$build_root/greeter_install_build"
grtr_pkg_bld="$build_root/greeter_package_build"
grtr_inst="$build_root/greeter_install"
grtr_unpk="$build_root/greeter_unpack"

greeter_cmake_options="
    -DCMAKE_MODULE_PATH="$HELLO_CMAKE_ROOT/environment/templates/cmake"
    -DCMAKE_BUILD_TYPE=$build_type
    -DCMAKE_INSTALL_PREFIX="$grtr_inst"
    -DWORLD_ROOT="$wrld_inst"
    $general_cmake_options
"

cd $build_root
rm -fr $grtr_inst_bld $grtr_pkg_bld $grtr_inst $grtr_unpk
mkdir $grtr_inst_bld $grtr_pkg_bld $grtr_unpk

# Configure for standard install target, without creating a self-contained
# package.
cd $grtr_inst_bld
cmake -G "$cmake_generator" $greeter_cmake_options $grtr_src
cd ..

# Execute from build directory should just work.
new_test "Execute from install build directory"
cmake --build $grtr_inst_bld --config $build_type
if [ $check_greeter_dependencies == 1 ]; then
    print_message "Dependencies in $grt_inst_bld:"
    check_exe_dependencies $grtr_inst_bld/bin greeter-static \
        "install_build" $ld_library_path $wrld_inst
    check_exe_dependencies $grtr_inst_bld/bin greeter-shared \
        "install_build" $ld_library_path $wrld_inst
fi
run_tests $grtr_inst_bld $ld_library_path $wrld_inst
execute $grtr_inst_bld/bin greeter-static "install_build" $ld_library_path $wrld_inst
execute $grtr_inst_bld/bin greeter-shared "install_build" $ld_library_path $wrld_inst

# Exectute from install directory should work, given the ld_library_path.
new_test "Execute from install directory"
cmake --build $grtr_inst_bld --config $build_type --target install
if [ $check_greeter_dependencies == 1 ]; then
    print_message "Dependencies in $grtr_inst:"
    check_exe_dependencies $grtr_inst/bin greeter-static "install" \
        $ld_library_path $wrld_inst
    check_exe_dependencies $grtr_inst/bin greeter-shared "install" \
        $ld_library_path $wrld_inst
fi
execute $grtr_inst/bin greeter-static "install" $ld_library_path $wrld_inst
execute $grtr_inst/bin greeter-shared "install" $ld_library_path $wrld_inst

### # Configure for package target, creating a self-contained package.
### cd $grtr_pkg_bld
### cmake $greeter_cmake_options -DHC_ENABLE_FIXUP_BUNDLE:BOOL=ON $grtr_src
### cd ..
### 
### # Execute from build directory should just work.
### new_test "Execute from package build directory"
### cmake --build $grtr_pkg_bld --config $build_type
### if [ $check_greeter_dependencies == 1 ]; then
###     print_message "Dependencies in $grtr_pkg_bld:"
###     check_exe_dependencies $grtr_pkg_bld/sources/greeter greeter-static "package_build"
###     check_exe_dependencies $grtr_pkg_bld/sources/greeter greeter-shared "package_build"
### fi
### execute $grtr_pkg_bld/sources/greeter greeter-static "package_build"
### execute $grtr_pkg_bld/sources/greeter greeter-shared "package_build"
### 
### # Exectute from unpack directory should just work. Relative paths to shared
### # libs baked into exes and dlls.
### new_test "Execute from unpack directory"
### cmake --build $grtr_pkg_bld --config $build_type --target package
### unpack_package "GREETER" $grtr_pkg_bld $grtr_unpk prefix
### if [ $check_greeter_dependencies == 1 ]; then
###     print_message "Dependencies in $prefix:"
###     # check_exe_dependencies $prefix/bin turn_world-static
###     # check_exe_dependencies $prefix/bin turn_world-shared
###     check_exe_dependencies $prefix/bin greeter-static "unpack"
###     check_exe_dependencies $prefix/bin greeter-shared "unpack"
###     # check_pyd_dependencies $prefix/python/world world
### fi
### # execute $prefix/bin turn_world-static
### # execute $prefix/bin turn_world-shared
### execute $prefix/bin greeter-static "unpack"
### execute $prefix/bin greeter-shared "unpack"
### # PYTHONPATH=$prefix/python/world python -c "import world; \
### #     print(\"Hello {} from Python!\".format(world.World().name))"




### # Run executable. --------------------------------------------------------------
### # From build location.
### # Targets are allowed to depend on world's install location.
### # TODO Darwin: How to get the install name of world's dll in the exe?
### if [ $os != "Darwin" ]; then
###     execute $grtr_inst_bld/sources/greeter hcgreeter-static
###     check_exe_dependencies $grtr_inst_bld/sources/greeter hcgreeter-shared
###     execute $grtr_inst_bld/sources/greeter hcgreeter-shared
### fi
### 
### # From install location.
### if [ $os == "Darwin" ]; then
###     execute $grtr_inst hcgreeter-static
###     check_exe_dependencies $grtr_inst hcgreeter-shared
###     execute $grtr_inst hcgreeter-shared
### else
###     execute $grtr_inst/bin hcgreeter-static
###     check_exe_dependencies $grtr_inst/bin hcgreeter-shared
###     execute $grtr_inst/bin hcgreeter-shared
### fi
### 
### # Move world's install location to make sure its targets are not used by
### # greeter's targets.
### rm -fr ${wrld_inst}_moved
### mv $wrld_inst ${wrld_inst}_moved
### 
### # From install location.
### # Targets are not allowed to depend on world's install location.
### if [ $os == "Darwin" ]; then
###     execute $grtr_inst hcgreeter-static
###     check_exe_dependencies $grtr_inst hcgreeter-shared
###     execute $grtr_inst hcgreeter-shared
### else
###     execute $grtr_inst/bin hcgreeter-static
###     check_exe_dependencies $grtr_inst/bin hcgreeter-shared
###     execute $grtr_inst/bin hcgreeter-shared
### fi
### 
### # Move greeter's install location to make sure its targets don't depend on the
### # install location.
### rm -fr ${grtr_inst}_moved
### mv $grtr_inst ${grtr_inst}_moved
### 
### if [ $os == "Darwin" ]; then
###     execute ${grtr_inst}_moved hcgreeter-static
###     check_exe_dependencies ${grtr_inst}_moved hcgreeter-shared
###     execute ${grtr_inst}_moved hcgreeter-shared
### else
###     execute ${grtr_inst}_moved/bin hcgreeter-static
###     check_exe_dependencies ${grtr_inst}_moved/bin hcgreeter-shared
###     execute ${grtr_inst}_moved/bin hcgreeter-shared
### fi
### 
### find ${grtr_inst}_moved

#!/usr/bin/env bash
set -e

cmake_generator="$1"
extern_prefix="$2"
ld_library_path="$3"
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
python_script="import world; \
    print(\"Hello {} from Python!\".format(world.World().name))"


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
        if [ $start_location == "build" ]; then
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
        if [ $start_location == "build" ]; then
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
        if [ $start_location == "build" ]; then
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

    if [ $os == "GNU/Linux" ]; then
        PYTHONPATH=$python_path python -c "$python_script"
    elif [ $os == "Darwin" ]; then
        PYTHONPATH=$python_path python -c "$python_script"
    elif [ $os == "Cygwin" ]; then
        if [ $start_location == "build" ]; then
            ld_library_path="`cygpath -u $python_path`/../lib/$build_type:$ld_library_path"
            python_path="$python_path/$build_type"
        else
            ld_library_path="`cygpath -u $python_path`/../../bin:$ld_library_path"
        fi
        PATH="$ld_library_path:$PATH" \
            PYTHONPATH=$python_path python -c "$python_script"
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
        cmake --build $prefix --config $build_type --target test
    elif [ $os == "Darwin" ]; then
        cmake --build $prefix --config $build_type --target test
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
        if [ $start_location == "build" ]; then
            ld_library_path="`dirname \`cygpath -u $executable\``/../../lib/$build_type:$ld_library_path"
        else
            # In case executable is an exe/dll from the bin directory, then
            # this directory needs to be added to the PATH. Otherwise the
            # shared libs it depends on won't be found.
            # In case executable is a Python extension, then the bin directory
            # needs to be added to the PATH. Otherwise the shared libs it
            # depends on won't be found.
            ld_library_path="`dirname \`cygpath -u $executable\``:`dirname \`cygpath -u $executable\``/../../bin:$ld_library_path"
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

install_prefix="$build_root/hello_cmake"
rm -fr "$install_prefix"


# Build, install, package the world project. -----------------------------------
wrld_src="$HELLO_CMAKE_ROOT/world"
wrld_bld="$build_root/world_build"

world_cmake_options="
    -DCMAKE_MODULE_PATH:PATH="$HELLO_CMAKE_ROOT/environment/templates/cmake"
    -DCMAKE_BUILD_TYPE=$build_type
    -DCMAKE_INSTALL_PREFIX:PATH="$install_prefix"
    $general_cmake_options
"

cd $build_root
rm -fr $wrld_bld; mkdir $wrld_bld; cd $wrld_bld
cmake -G "$cmake_generator" $world_cmake_options $wrld_src
cd ..

# Exectute from build directory should just work. It is fine if paths to
# external dlls are hardcoded in the exes and dlls. It is not fine if
# environment settings like LD_LIBRARY_PATH on Linux are needed to be able
# to use the targets.
new_test "Execute from build directory"
cmake --build $wrld_bld --config $build_type
if [ $check_world_dependencies == 1 ]; then
    print_message "Dependencies in $wrld_bld:"
    check_exe_dependencies $wrld_bld/bin turn_world-static \
        "build" $ld_library_path
    check_exe_dependencies $wrld_bld/bin turn_world-shared \
        "build" $ld_library_path
    check_pyd_dependencies $wrld_bld/lib world "build" $ld_library_path
fi
run_tests $wrld_bld $ld_library_path
execute $wrld_bld/bin turn_world-static "build" $ld_library_path
execute $wrld_bld/bin turn_world-shared "build" $ld_library_path
try_python_extension $wrld_bld/lib "build" $ld_library_path

# Exectute from install directory should work, given the ld_library_path.
new_test "Execute from install directory"
cmake --build $wrld_bld --config $build_type --target install
if [ $check_world_dependencies == 1 ]; then
    print_message "Dependencies in $install_prefix:"
    check_exe_dependencies $install_prefix/bin turn_world-static "install" \
        $ld_library_path
    check_exe_dependencies $install_prefix/bin turn_world-shared "install" \
        $ld_library_path
    check_pyd_dependencies $install_prefix/python/world world "install" $ld_library_path
fi
execute $install_prefix/bin turn_world-static "install" $ld_library_path
execute $install_prefix/bin turn_world-shared "install" $ld_library_path
try_python_extension $install_prefix/python/world "install" $ld_library_path

# Build, install, package the greeter project. ---------------------------------
grtr_src="$HELLO_CMAKE_ROOT/greeter"
grtr_bld="$build_root/greeter_build"

greeter_cmake_options="
    -DCMAKE_MODULE_PATH="$HELLO_CMAKE_ROOT/environment/templates/cmake"
    -DCMAKE_BUILD_TYPE=$build_type
    -DCMAKE_INSTALL_PREFIX="$install_prefix"
    -DWORLD_ROOT="$install_prefix"
    $general_cmake_options
"

cd $build_root
rm -fr $grtr_bld
mkdir $grtr_bld

cd $grtr_bld
cmake -G "$cmake_generator" $greeter_cmake_options $grtr_src
cd ..

# Execute from build directory should just work.
new_test "Execute from build directory"
cmake --build $grtr_bld --config $build_type
if [ $check_greeter_dependencies == 1 ]; then
    print_message "Dependencies in $grtr_bld:"
    check_exe_dependencies $grtr_bld/bin greeter-static \
        "build" $ld_library_path $install_prefix
    check_exe_dependencies $grtr_bld/bin greeter-shared \
        "build" $ld_library_path $install_prefix
fi
run_tests $grtr_bld $ld_library_path $install_prefix
execute $grtr_bld/bin greeter-static "build" $ld_library_path $install_prefix
execute $grtr_bld/bin greeter-shared "build" $ld_library_path $install_prefix

# Exectute from install directory should work, given the ld_library_path.
new_test "Execute from install directory"
cmake --build $grtr_bld --config $build_type --target install
if [ $check_greeter_dependencies == 1 ]; then
    print_message "Dependencies in $install_prefix:"
    check_exe_dependencies $install_prefix/bin greeter-static "install" \
        $ld_library_path
    check_exe_dependencies $install_prefix/bin greeter-shared "install" \
        $ld_library_path
fi
execute $install_prefix/bin greeter-static "install" $ld_library_path
execute $install_prefix/bin greeter-shared "install" $ld_library_path

# Final test. Fixup the package and make sure minimal environment tweaks are
# necessary to use the targets.
# The fixup.py script can be found in the PCRaster DevEnv project sources:
# http://sourceforge.net/projects/pcraster
if [ $os == "Cygwin" ]; then
    PATH="$ld_library_path:`cygpath --unix $install_prefix/bin`:$PATH" python `cygpath --mixed $DEVENV`/Scripts/fixup.py $install_prefix "`cygpath --mixed $extern_prefix`"
    PATH="$ld_library_path:`cygpath --unix $install_prefix/bin`:$PATH" greeter-shared
    # TODO This should work. The exe should find it dlls, without looking at
    #      PATH.
    # `cygpath --unix $install_prefix/bin`/greeter-shared
    PATH="`cygpath --unix $install_prefix/bin`:$PATH" PYTHONPATH=$install_prefix/python/world python -c "$python_script"
else
    python $DEVENV/Scripts/fixup.py $install_prefix $extern_prefix
    PATH="$install_prefix/bin:$PATH" greeter-shared
    PYTHONPATH=$install_prefix/python/world python -c "$python_script"
fi

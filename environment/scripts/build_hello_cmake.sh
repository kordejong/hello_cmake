#!/usr/bin/env bash
set -e
set -x

build_type="Release"
build_root="$HOME/tmp"

# Build and install the world project. -----------------------------------------
world_sources="$HELLO_CMAKE/world"
world_binaries="$build_root/world_build"
world_install="$build_root/world_install"

cd $build_root
rm -fr $world_binaries $world_install
mkdir $world_binaries
cd $world_binaries

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=$build_type -DCMAKE_INSTALL_PREFIX=$world_install $world_sources
make
make install

# Build and install the greeter project. ---------------------------------------
greeter_sources="$HELLO_CMAKE/greeter"
greeter_binaries="$build_root/greeter_build"
greeter_install="$build_root/greeter_install"

cd $build_root
rm -fr $greeter_binaries $greeter_install
mkdir $greeter_binaries
cd $greeter_binaries

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=$build_type -DWORLD_PREFIX=$world_install -DCMAKE_INSTALL_PREFIX=$greeter_install $greeter_sources
make VERBOSE=1
make install


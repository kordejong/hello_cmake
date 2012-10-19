#ifndef INCLUDED_HELLO_CMAKE_WORLD_CONFIG
#define INCLUDED_HELLO_CMAKE_WORLD_CONFIG


#include <boost/config.hpp>

#ifdef BOOST_HAS_DECLSPEC
#    if defined(WORLD_SHARED_LINK)
#        ifdef WORLD_SOURCE
#            define WORLD_DECL __declspec(dllexport)
#        else
#            define WORLD_DECL __declspec(dllimport)
#        endif
#    endif
#endif

#ifndef WORLD_DECL
#  define WORLD_DECL
#endif

#endif

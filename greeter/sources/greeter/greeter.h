#ifndef INCLUDED_HELLO_CMAKE_GREETER
#define INCLUDED_HELLO_CMAKE_GREETER


namespace hc {

template<
    class Entity
>
inline void greet(
        Entity const& entity,
        std::ostream& stream)
{
    stream << "Hello " << entity.name() << "!" << std::endl;
}

} // namespace hc

#endif

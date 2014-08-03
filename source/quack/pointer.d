/**
 * Defines DuckPointer, which allows quacking without templates.
 */
module quack.pointer;
import quack.extends, quack.mixins;

/**
 * Pointer to any type that `extends` Pointee.
 *
 * Params:
 *  Pointee =           The type the pointee refers to.
 */
template DuckPointer( Pointee ) if( isExtendable!Pointee )
{
    struct DuckPointer
    {
    public:

    private:

    }
}
///
unittest
{
    interface IFace1
    {
        int getX();
    }

    DuckPointer!IFace1 ptr1;
}

/**
 * Pointer to any type that has a template mixin.
 *
 * Params:
 *  Mixin =             The mixin we're testing.
 */
template DuckPointer( alias Mixin ) if( !isExtendable!Mixin )
{
    mixin( ImplementTemplateMixin!Mixin );
    alias DuckPointer = DuckPointer!MixinImpl;
}
///
unittest
{

}

/**
 * Pointer to any type that has a string mixin.
 *
 * Params:
 *  Mixin =             The mixin we're testing.
 */
template DuckPointer( string Mixin )
{
    mixin( ImplementStringMixin!Mixin );
    alias DuckPointer = DuckPointer!MixinImpl;
}
///
unittest
{
    
}

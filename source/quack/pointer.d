/**
 * Defines DuckPointer, which allows quacking without templates.
 */
module quack.pointer;
import quack.extends, quack.mixins;

import tested;

/**
 * Convience wrapper for creating a DuckPointer.
 */
template duck( Pointee ) if( isExtendable!Pointee )
{
    DuckPointer!Pointee duck( Pointer )( Pointer* p )
    {
        DuckPointer!Pointee ptr;
        ptr.init!Pointer( p );
        return ptr;
    }
}

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
        mixin( ImplementMembers );

        ~this()
        {
            destroyer( impl );
        }

    private:
        void* impl;
        void function( void* ) destroyer;

        void init( Pointer )( Pointer* p )
        {
            impl = cast(void*)p;
            destroyer = ptr => typeid(Pointer).destroy( ptr );

            // Assign pointers
            foreach( member; __traits( allMembers, Pointee ) )
            {
                import std.algorithm: among;
                static if( !member.among( "this", "~this" ) )
                {
                    mixin( "this." ~ member ) = &__traits( getMember, p, member );
                }
            }
        }
    }

    private enum ImplementMembers = {
        string members = "";

        foreach( member; __traits( allMembers, Pointee ) )
        {
            import std.algorithm: among;
            static if( !member.among( "this", "~this" ) )
            {
                members ~= typeof( &__traits( getMember, Pointee, member ) ).stringof.replace( "function", "delegate" );
                members ~= " " ~ member ~ ";";
            }
        }

        return members;
    } ();
}
///
@name( "DuckPointer" )
unittest
{
    struct IFace1
    {
        int getX() { return 12; }
    }
    struct Struct1
    {
        int x;
        int getX() { return x; }
    }

    Struct1 s1;
    s1.x = 42;
    DuckPointer!IFace1 ptr1 = duck!IFace1( &s1 );
    assert( ptr1.getX() == 42 );
}

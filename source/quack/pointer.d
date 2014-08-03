/**
 * Defines DuckPointer, which allows quacking without templates.
 */
module quack.pointer;
import quack.extends, quack.mixins;

/**
 * Convience wrapper for creating a DuckPointer.
 */
template duck( Pointee ) if( isExtendable!Pointee )
{
    DuckPointer!Pointee duck( Pointer )( Pointer* p )
    {
        return DuckPointer!Pointee( p );
    }
}

/**
 * Pointer to any type that `extends` Pointee.
 *
 * To make a DuckPointer for a mixin, it's recommended to define a struct
 * that only implements the mixin.
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

        this( Pointer )( Pointer* p )
        {
            impl = cast(void*)p;
            destroyer = ptr => typeid(Pointer).destroy( ptr );

            // Assign pointers
            foreach( member; __traits( allMembers, Pointee ) )
            {
                import std.algorithm: among;
                import std.traits: isSomeFunction;
                static if( !member.among( "this", "~this" ) )
                {
                    static if( __traits( hasMember, this, "__" ~ member ) )
                    {
                        // We store a pointer, so store that.
                        __traits( getMember, this, "__" ~ member ) = &__traits( getMember, p, member );
                    }
                    else
                    {
                        // No pointer, assign the reference directly.
                        __traits( getMember, this, member ) = &__traits( getMember, p, member );
                    }
                }
            }
        }

        ~this()
        {
            destroyer( impl );
        }

    private:
        void* impl;
        void function( void* ) destroyer;
    }

    // The code to implement the pass throughs.
    private enum ImplementMembers = {
        string members = "";

        foreach( member; __traits( allMembers, Pointee ) )
        {
            import std.algorithm: among;
            import std.string: replace;
            static if( !member.among( "this", "~this" ) )
            {
                // If member is a field, this'll fail citing a need for a `this` pointer.
                static if( __traits( compiles, &__traits( getMember, Pointee, member ) ) )
                {
                    members ~= "public " ~ typeof( &__traits( getMember, Pointee, member ) ).stringof.replace( "function", "delegate" ) ~
                                " " ~ member ~ ";";
                }
                else
                {
                    // If it's a var, store a pointer to it, and return a reference to the dereferenced pointer.
                    members ~= "private " ~ typeof( __traits( getMember, Pointee, member ) ).stringof ~ "* __" ~ member ~ ";";
                    members ~= "public @property ref " ~ typeof( __traits( getMember, Pointee, member ) ).stringof ~ " " ~ member ~ "() {
                        return *__" ~ member ~ "; }";
                }
            }
        }

        return members;
    } ();
}

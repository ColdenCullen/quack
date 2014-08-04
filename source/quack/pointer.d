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

        @disable this();
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
                    // We store a pointer, so store that.
                    __traits( getMember, this, "__" ~ member ) = &__traits( getMember, p, member );
                }
            }
        }

        void destroy()
        {
            destroyer( impl );
        }

    private:
        /// The actual pointer. Unnecessary except for destroyer.
        void* impl;
        /// Calls the proper destory function.
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
                // Whether this member is a function or not.
                // Can't get address of data member without this pointer.
                enum isFunction = __traits( compiles, &__traits( getMember, Pointee, member ) );

                // If member is a field, this'll fail citing a need for a `this` pointer.
                static if( isFunction )
                {
                    // The name of the variable type.
                    enum typeName = typeof( &__traits( getMember, Pointee, member ) ).stringof.replace( "function", "delegate" ) ;

                    // Pointer to member, passthrough function.
                    members ~= q{
                        private $type __$member;
                        public auto $member( Args... )( Args args )
                            if( __traits( compiles, __$member( args ) ) )
                        {
                            return __$member( args );
                        }
                    }.replace( "$member", member ).replace( "$type", typeName );
                }
                else
                {
                    // The name of the variable type.
                    enum typeName = typeof( __traits( getMember, Pointee, member ) ).stringof;

                    // Pointer to member, function returning ref.
                    members ~= q{
                        private $type* __$member;
                        public @property ref $type $member()
                        {
                            return *__$member;
                        }
                    }.replace( "$member", member ).replace( "$type", typeName );
                }
            }
        }

        return members;
    } ();
}

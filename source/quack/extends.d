/**
 *
 */
module quack.extends;
import quack, quack.debughelpers;

/**
 * Checks if Child extends Parent in any of the supported ways.
 *
 * Params:
 *      Child =         The base class to test.
 *      Parent =        The parent class to test.
 *
 * Returns:
 *      Whether Child "extends" Parent.
 */
template extends( Child, Parent, string file = __FILE__, size_t line = __LINE__ )
{
    enum extends =
        is( Child : Parent ) ||
        hasAliasThis!( Child, Parent, file, line ) ||
        hasSameMembers!( Child, Parent, file, line );
}

/**
 * Returns true if Child has an alias this of type Parent, and as such is
 * implicitly convertable.
 *
 * Params:
 *      Child =         The base class to test.
 *      Parent =        The parent class to test.
 *
 * Returns:
 *      Whether Child has an alias this of Parent.
 */
enum hasAliasThis( Child, Parent, string file = __FILE__, size_t line = __LINE__ ) = {
    static if( isExtendable!( Child, Parent ) )
    {
        foreach( alias_; __traits( getAliasThis, Child ) )
        {
            if( is( typeof( __traits( getMember, Child, alias_ ) ) : Parent ) )
                return true;
        }
    }

    return false;
} ();

/**
 * Checks if Child extends Parent by having a matching set of members.
 *
 * Params:
 *      Child =         The base class to test.
 *      Parent =        The parent class to test.
 *
 * Returns:
 *      Whether Child has all the members of Parent.
 */
template hasSameMembers( Child, Parent, string file = __FILE__, size_t line = __LINE__ )
{
    import std.algorithm: among;
    import std.traits;
    debug( quack ) import std.conv: to;

    static if( isExtendable!( Child, Parent ) )
    {
        enum hasSameMembers = {
            // If there are no members to check, return false.
            static if( [__traits( allMembers, Parent )].length == 0 )
            {
                return false;
            }
            else
            {
                foreach( member; __traits( allMembers, Parent ) )
                {
                    // Ignore some members.
                    static if( !member.among( "this", "~this", "Monitor" ) )
                    {
                        // If Child has the member, check the type.
                        static if( __traits( hasMember, Child, member ) )
                        {
                            // If member, make sure they are the same type.
                            static if( !is(
                                typeof( __traits( getMember, Parent, member ) ) ==
                                typeof( __traits( getMember, Child, member ) ) ) )
                            {
                                // If function and type mismatch, check components for validity.
                                static if( isSomeFunction!( __traits( getMember, Parent, member ) ) )
                                {
                                    // Check for return type mismatch.
                                    static if( !is( ReturnType!( __traits( getMember, Child, member ) ) ==
                                                    ReturnType!( __traits( getMember, Parent, member ) ) ) )
                                    {
                                        debug( quack ) pragma( msg, memberMismatchError!( Child, member, "Return type mismatch.", file, line ) );
                                        return false;
                                    }

                                    // Check for parameter type mismatch.
                                    static if( !is( ParameterTypeTuple!( __traits( getMember, Child, member ) ) ==
                                                    ParameterTypeTuple!( __traits( getMember, Parent, member ) ) ) )
                                    {
                                        debug( quack ) pragma( msg, memberMismatchError!( Child, member, "Parameter type mismatch.", file, line ) );
                                        return false;
                                    }

                                    // Check for attribute mismatch.
                                    enum childAttr = functionAttributes!( __traits( getMember, Child, member ) );
                                    enum parentAttr = functionAttributes!( __traits( getMember, Parent, member ) );
                                    static if( childAttr == FunctionAttribute.none && parentAttr != FunctionAttribute.none )
                                    {
                                        debug( quack ) pragma( msg, memberMismatchError!( Child, member,
                                            "Attribute mismatch: " ~ extractFlags!( FunctionAttribute, childAttr ).to!string ~
                                            ":" ~ extractFlags!( FunctionAttribute, parentAttr ).to!string, file, line ) );
                                        return false;
                                    } else {

                                    // Check for safety.
                                    static if( isSafe!( __traits( getMember, Parent, member ) ) && isUnsafe!( __traits( getMember, Child, member ) ) )
                                    {
                                        debug( quack ) pragma( msg, memberMismatchError!( Child, member, "Function safety mismatch.", file, line ) );
                                        return false;
                                    } else {

                                    // Check for @property.
                                    static if( ( parentAttr & FunctionAttribute.property ) && !( childAttr & FunctionAttribute.property ) )
                                    {
                                        debug( quack ) pragma( msg, memberMismatchError!( Child, member, "@property mismatch.", file, line ) );
                                        return false;
                                    }
                                    } }
                                }
                                else
                                {
                                    debug( quack ) pragma( msg, memberMismatchError!( Child, member, "Type mismatch.", file, line ) );
                                    return false;
                                }
                            }
                        }
                        else
                        {
                            debug( quack ) pragma( msg, memberMismatchError!( Child, member, "Member missing.", file, line ) );
                            return false;
                        }
                    }
                }

                return true;
            }
        } ();
    }
    else
    {
        enum hasSameMembers = false;
    }
}

/**
 * Makes sure the types given can be extended.
 *
 * Params:
 *      Classes =       The symbols to test.
 *
 * Returns:
 *      Whether or not all of Classes are structs or classes.
 */
package enum isExtendable( Classes... ) = {
    foreach( klass; Classes )
    {
        if( !is( klass == struct ) && !is( klass == class ) && !is( klass == interface ) )
        {
            return false;
        }
    }

    return true;
} ();

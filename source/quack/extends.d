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
    bool result = false;
    static if( isExtendable!( Child, Parent ) )
    {
        foreach( alias_; __traits( getAliasThis, Child ) )
        {
            if( is( typeof( __traits( getMember, Child, alias_ ) ) : Parent ) ) {
                result = true;
                break;
            }
        }
    }

    return result;
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
    import std.string: replace;
    import std.traits;
    debug( quack ) import std.conv: to;

    static if( isExtendable!( Child, Parent ) )
    {
        enum error( string msg ) = q{
            debug( quack ) pragma( msg, memberMismatchError!( Child, member, "$msg", file, line ) );
            return false;
        }.replace( "$msg", msg );

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
                    static if( member.among( "this", "~this", "Monitor" ) )
                    {
                        continue;
                    }
                    // If Child has the member, check the type.
                    else static if( !__traits( hasMember, Child, member ) )
                    {
                        mixin( error!"Member missing." );
                    }
                    // If member, make sure they are the same type.
                    else static if( is(
                        typeof( __traits( getMember, Parent, member ) ) ==
                        typeof( __traits( getMember, Child, member ) ) ) )
                    {
                        return true;
                    }
                    // If not function, give up.
                    else static if( !isSomeFunction!( __traits( getMember, Parent, member ) ) )
                    {
                        mixin( error!"Type mismatch." );
                    }
                    // Check for return type mismatch.
                    else static if( !is( ReturnType!( __traits( getMember, Child, member ) ) ==
                                    ReturnType!( __traits( getMember, Parent, member ) ) ) )
                    {
                        mixin( error!"Return type mismatch." );
                    }
                    // Check for parameter type mismatch.
                    else static if( !is( ParameterTypeTuple!( __traits( getMember, Child, member ) ) ==
                                    ParameterTypeTuple!( __traits( getMember, Parent, member ) ) ) )
                    {
                        mixin( error!"Parameter type mismatch." );
                    }
                    // Check for safety.
                    else static if( isSafe!( __traits( getMember, Parent, member ) ) && isUnsafe!( __traits( getMember, Child, member ) ) )
                    {
                        mixin( error!"Function safety mismatch." );
                    }
                    // Check for attribute mismatch.
                    else
                    {
                        enum childAttr = functionAttributes!( __traits( getMember, Child, member ) );
                        enum parentAttr = functionAttributes!( __traits( getMember, Parent, member ) );
                        static if( childAttr == FunctionAttribute.none && parentAttr != FunctionAttribute.none )
                        {
                            mixin( error!( "Attribute mismatch: " ~ extractFlags!( FunctionAttribute, childAttr ).to!string ~
                                ":" ~ extractFlags!( FunctionAttribute, parentAttr ).to!string ) );
                        }
                        else static if( ( parentAttr & FunctionAttribute.property ) && !( childAttr & FunctionAttribute.property ) )
                        {
                            mixin( error!"@property mismatch." );
                        }
                        else
                        {
                            return true;
                        }
                    }
                }
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
    bool result = true;
    foreach( klass; Classes )
    {
        if( !is( klass == struct ) && !is( klass == class ) && !is( klass == interface ) )
        {
            result = false;
            break;
        }
    }

    return result;
} ();

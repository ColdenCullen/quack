/**
 *
 */
module quack.extends;
import quack;

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
template extends( Child, Parent )
{
    enum extends =
        is( Child : Parent ) ||
        hasAliasThis!( Child, Parent ) ||
        hasSameMembers!( Child, Parent );
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
enum hasAliasThis( Child, Parent ) = {
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
template hasSameMembers( Child, Parent )
{
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
                    import std.algorithm: among;
                    // Ignore some members.
                    static if( !member.among( "this", "~this" ) )
                    {
                        // If Child has the member, check the type.
                        static if( __traits( hasMember, Child, member ) )
                        {
                            static if( !is(
                                typeof( __traits( getMember, Parent, member ) ) ==
                                typeof( __traits( getMember, Child, member ) )
                                ) )
                            {
                                //pragma( msg, "Member type mismatch " ~ Child.stringof ~ ":" ~ member ~ "::" ~ typeof(__traits( getMember, Parent, member )).stringof );
                                return false;
                            }
                        }
                        else
                        {
                            //pragma( msg, "Member missing " ~ Child.stringof ~ ":" ~ member );
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

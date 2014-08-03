/**
 *
 */
module quack.extends;
import quack;

import tested;

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
///
@name( "extends" )
unittest
{
    struct S1 { }
    struct S2 { }
    struct C1 { }
    struct C2 { }
    assert( !extends!( C1, C2 ) );
    assert( !extends!( S1, S2 ) );
    assert( !extends!( S1, C2 ) );
    assert( !extends!( C1, S2 ) );
    assert( !extends!( float, bool ) );
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
///
@name( "hasAliasThis" )
unittest
{
    struct A { }
    struct B
    {
        A a;
        alias a this;
    }
    struct C { }

    assert( hasAliasThis!( B, A ) );
    assert( !hasAliasThis!( C, A ) );
    assert( !hasAliasThis!( A, C ) );
    assert( !hasAliasThis!( float, bool ) );
}

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
                                return false;
                            }
                        }
                        else
                        {
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
///
@name( "hasSameMembers" )
unittest
{
    struct S1
    {
        @property int x() { return 42; }
    }

    struct S2
    {
        @property int x() { return 42; }
    }

    assert( hasSameMembers!( S1, S2 ) );
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
///
@name( "isExtendable" )
unittest
{
    struct S1 { }
    struct S2 { }
    struct C1 { }
    struct C2 { }
    assert( isExtendable!( S1 ) );
    assert( isExtendable!( C1 ) );

    assert( isExtendable!( S1, S2 ) );
    assert( isExtendable!( C1, C2 ) );
    assert( isExtendable!( S1, C2 ) );
    assert( isExtendable!( C1, C2 ) );
}

/**
 * Contains definition of isAliasThis, which checks if one type has an alias
 * this of the other.
 */
module quack.aliasthis;
import quack.extends;

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
enum isAliasThis( Child, Parent ) = {
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
unittest
{
    struct A { }
    struct B
    {
        A a;
        alias a this;
    }
    struct C { }

    assert( isAliasThis!( B, A ) );
    assert( !isAliasThis!( C, A ) );
    assert( !isAliasThis!( A, C ) );
    assert( !isAliasThis!( float, bool ) );
}

/**
 *
 */
module quack.extends;
import quack;

/**
 * Checks if Child extends Parent in any of the supported ways.
 *
 * Params:
 *      Child =        The base class to test.
 *      Parent =        The parent class to test.
 *
 * Returns:
 *      Whether Child "extends" Parent.
 */
template extends( Child, Parent )
{
    enum extends =
        is( Child : Parent ) ||
        isAliasThis!( Child, Parent );
}
///
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
        if( !is( klass == struct ) && !is( klass == class ) )
        {
            return false;
        }
    }

    return true;
} ();
///
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

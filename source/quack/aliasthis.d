/**
 * Contains definition of isAliasThis, which checks if two types
 */
module quack.aliasthis;

/**
 * Returns true if Base has an alias this of type Parent, and as such is
 * implicitly convertable.
 *
 * Params:
 *      Base =          The base class to test.
 *      Parent =        The parent class to test.
 *
 * Returns:
 *      Whether Base has an alias this of Parent.
 */
template isAliasThis( Base, Parent )
    if( ( is( Base == class ) || is( Base == struct ) ) &&
        ( is( Parent == class ) || is( Parent == struct ) ) )
{
    enum isAliasThis = {
        foreach( alias_; __traits( getAliasThis, Base ) )
        {
            if( is( typeof( __traits( getMember, Base, alias_ ) ) : Parent ) )
                return true;
        }

        return false;
    } ();
}
///
unittest
{
    struct A { }
    struct B
    {
        A a;
        alias a this;
    }

    assert( isAliasThis!( B, A ) );
}

/**
 * Contains definition of hasTemplateMixin, which checks if a class or struct
 * defines all the same members of a template mixin.
 */
module quack.mixins;

/**
 *
 */
template hasTemplateMixin( Base, alias mix )
{
    private struct MixImpl
    {
        /*static if( __traits( compiles, mixin mix ) )
        {*/
            mixin mix!();
        //}
    }

    enum hasTemplateMixin = {
        bool isEqual = false;

        foreach( member; __traits( allMembers, MixImpl ) )
        {
            static if( __traits( hasMember, Base, member ) )
            {
                static if( is(
                    typeof( __traits( getMember, MixImpl, member ) ) ==
                    typeof( __traits( getMember, Base, member ) )
                    ) )
                {
                    isEqual = true;
                }
            }
            else
            {
                return false;
            }
        }

        return isEqual;
    } ();
}
///
unittest
{
    assert( !hasTemplateMixin!( float, TestMix ) );

    struct TestMixStruct1
    {
        mixin TestMix!();
    }
    assert( hasTemplateMixin!( TestMixStruct1, TestMix ) );

    class TestMixClass1
    {
        mixin TestMix!();
    }
    assert( hasTemplateMixin!( TestMixClass1, TestMix ) );

    class TestMixClass2
    {
        mixin TestMix!();
        int getY() { return 43; }
    }
    assert( hasTemplateMixin!( TestMixClass2, TestMix ) );

    class TestMixClass3
    {
        int getZ() { return 44; }
    }
    assert( !hasTemplateMixin!( TestMixClass3, TestMix ) );

    class TestMixClass4
    {
        int getX() { return 45; }
    }
    assert( hasTemplateMixin!( TestMixClass4, TestMix ) );
}
version( unittest )
mixin template TestMix()
{
    int getX() { return 42; }
}

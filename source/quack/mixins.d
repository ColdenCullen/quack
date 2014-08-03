/**
 * Contains definition of hasTemplateMixin, which checks if a class or struct
 * defines all the members of a template mixin, and hasStringMixin, which
 * checks if a class or struct defines all the members of a string mixin.
 */
module quack.mixins;
import quack.extends, quack.members;

/**
 * Checks if Child extends Parent by implementing a template mixin.
 *
 * Params:
 *      Child =         The base class to test.
 *      mix =           The mixin to test for.
 *
 * Returns:
 *      Whether Child has all the members of mix.
 */
template hasTemplateMixin( Base, alias mix )
{
    static if( isExtendable!Base )
    {
        struct MixinImpl( alias Mixin )
        {
            //TODO: Make sure `mixin mix!();` compiles.
            mixin Mixin!();
        }

        enum hasTemplateMixin = hasSameMembers!( Base, MixinImpl!mix );
    }
    else
    {
        enum hasTemplateMixin = false;
    }
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

/**
 * Checks if Child extends Parent by implementing a string mixin.
 *
 * Params:
 *      Child =         The base class to test.
 *      mix =           The mixin to test for.
 *
 * Returns:
 *      Whether Child has all the members of mix.
 */
template hasStringMixin( Base, string mix )
{
    static if( isExtendable!Base )
    {
        struct MixinImpl( string Mixin )
        {
            //TODO: Make sure `mixin( mix );` compiles.
            mixin( Mixin );
        }

        enum hasStringMixin = hasSameMembers!( Base, MixinImpl!mix );
    }
    else
    {
        enum hasStringMixin = false;
    }
}
///
unittest
{
    enum testMix = q{ int getX() { return 42; } };

    assert( !hasStringMixin!( float, testMix ) );

    struct TestMixStruct1
    {
        mixin( testMix );
    }
    assert( hasStringMixin!( TestMixStruct1, testMix ) );

    class TestMixClass1
    {
        mixin( testMix );
    }
    assert( hasStringMixin!( TestMixClass1, testMix ) );

    class TestMixClass2
    {
        mixin( testMix );
        int getY() { return 43; }
    }
    assert( hasStringMixin!( TestMixClass2, testMix ) );

    class TestMixClass3
    {
        int getZ() { return 44; }
    }
    assert( !hasStringMixin!( TestMixClass3, testMix ) );

    class TestMixClass4
    {
        int getX() { return 45; }
    }
    assert( hasStringMixin!( TestMixClass4, testMix ) );
}

/**
 * Contains all unit tests for quack.
 */
module quack.test;
version( unittest ):
import quack;

// Suppport for optional package tested.
version( Have_tested ) import tested;
else struct name { string name; }

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

@name( "hasSameMembers" )
unittest
{
    struct S1
    {
        @property int x();
    }

    struct S2
    {
        @property int x();
    }

    assert( hasSameMembers!( S1, S2 ) );
}

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

mixin template TemplateMixin1()
{
    int getX() { return 42; }
}
@name( "hasTemplateMixin" )
unittest
{
    assert( !hasTemplateMixin!( float, TemplateMixin1 ) );

    struct TestMixStruct1
    {
        mixin TemplateMixin1!();
    }
    assert( hasTemplateMixin!( TestMixStruct1, TemplateMixin1 ) );

    class TestMixClass1
    {
        mixin TemplateMixin1!();
    }
    assert( hasTemplateMixin!( TestMixClass1, TemplateMixin1 ) );

    class TestMixClass2
    {
        mixin TemplateMixin1!();
        int getY() { return 43; }
    }
    assert( hasTemplateMixin!( TestMixClass2, TemplateMixin1 ) );

    class TestMixClass3
    {
        int getZ() { return 44; }
    }
    assert( !hasTemplateMixin!( TestMixClass3, TemplateMixin1 ) );

    class TestMixClass4
    {
        int getX() { return 45; }
    }
    assert( hasTemplateMixin!( TestMixClass4, TemplateMixin1 ) );
}

@name( "hasStringMixin" )
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

@name( "DuckPointer Structs" )
unittest
{
    struct IFace1
    {
        int getX() { return 12; }
        void doWork() pure @safe nothrow { }
    }
    struct Struct1
    {
        int x;
        int getX() { return x; }
        void doWork() pure @safe nothrow { ++x; }
    }

    Struct1 s1;
    s1.x = 42;
    DuckPointer!IFace1 ptr1 = duck!IFace1( &s1 );
    assert( ptr1.getX() == 42 );
    ptr1.doWork();
    assert( ptr1.getX() == 43 );
    ptr1.destroy();
}

mixin template TemplateMixin2()
{
    int x;
    int getX() { return x; }
}
@name( "DuckPointer Template Mixin" )
unittest
{
    struct MyMixinImpl
    {
        mixin TemplateMixin2!();
    }
    alias MixinPtr = DuckPointer!MyMixinImpl;

    struct Struct1
    {
        mixin TemplateMixin2!();
    }

    Struct1 s1;
    s1.x = 42;
    MixinPtr ptr1 = MixinPtr( &s1 );
    assert( ptr1.x == 42 );
    assert( ptr1.getX() == 42 );
    ++ptr1.x;
    assert( ptr1.x == 43 );
    assert( ptr1.getX() == 43 );
    assert( s1.x == 43 );
}

@name( "DuckPointer String Mixin" )
unittest
{
    enum myMixin = q{
        int x;
        int getX() { return x; }
    };
    struct MyMixinImpl
    {
        mixin( myMixin );
    }
    alias MixinPtr = DuckPointer!MyMixinImpl;

    struct Struct1
    {
        mixin( myMixin );
    }

    Struct1 s1;
    s1.x = 42;
    MixinPtr ptr1 = MixinPtr( &s1 );
    assert( ptr1.x == 42 );
    assert( ptr1.getX() == 42 );
    ++ptr1.x;
    assert( ptr1.x == 43 );
    assert( ptr1.getX() == 43 );
    assert( s1.x == 43 );
}

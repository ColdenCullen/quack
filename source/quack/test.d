/**
 * Contains all unit tests for quack.
 */
module quack.test;
version( unittest ):
private:

import quack;

// Suppport for optional package tested.
version( Have_tested ) import tested;
else struct name { string name; }

mixin template TemplateMixin1()
{
    void methodTemplate() { }
}
mixin template TemplateMixin2()
{
    int x;
    int getX() { return x; }
}
enum stringMixin1 = q{ void methodString() { } };

struct EmptyStruct1 { }
struct EmptyStruct2 { }
struct AliasThisHolder
{
    EmptyStruct1 e1;
    alias e1 this;
}
struct StructWithMethod1
{
    void method();
}
struct StructWithMethod2
{
    void method();
}

@name( "isExtendable" )
unittest
{
    assert( isExtendable!( EmptyStruct1 ) );
    assert( isExtendable!( EmptyStruct2, AliasThisHolder ) );
    assert( !isExtendable!( EmptyStruct1, float ) );
    assert( !isExtendable!( bool ) );
}

@name( "hasAliasThis" )
unittest
{
    assert( hasAliasThis!( AliasThisHolder, EmptyStruct1 ) );
    assert( !hasAliasThis!( EmptyStruct1, AliasThisHolder ) );
    assert( !hasAliasThis!( EmptyStruct2, EmptyStruct1 ) );
    assert( !hasAliasThis!( EmptyStruct1, EmptyStruct2 ) );
    assert( !hasAliasThis!( float, bool ) );
}

@name( "hasSameMembers" )
unittest
{
    assert( hasSameMembers!( StructWithMethod1, StructWithMethod2 ) );
    assert( hasSameMembers!( StructWithMethod2, StructWithMethod1 ) );
    assert( !hasSameMembers!( EmptyStruct1, StructWithMethod1 ) );
}

@name( "hasSameMembers Attributes" )
unittest
{
    struct Parent
    {
        void method() { }
    }
    struct Child
    {
        void method() @safe pure nothrow { }
    }
    //assert( hasSameMembers!( Child, Parent ) );
    assert( !hasSameMembers!( Parent, Child ) );
}

@name( "extends" )
unittest
{
    class Class1 { }
    class Class2 : Class1 { }

    assert( extends!( Class2, Class1 ) );
    assert( !extends!( EmptyStruct1, EmptyStruct2 ) );
    assert( !extends!( float, bool ) );
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
        void methodTemplate() { }
    }
    assert( hasTemplateMixin!( TestMixClass4, TemplateMixin1 ) );
}

@name( "hasStringMixin" )
unittest
{
    assert( !hasStringMixin!( float, stringMixin1 ) );

    struct TestMixStruct1
    {
        mixin( stringMixin1 );
    }
    assert( hasStringMixin!( TestMixStruct1, stringMixin1 ) );

    class TestMixClass1
    {
        mixin( stringMixin1 );
    }
    assert( hasStringMixin!( TestMixClass1, stringMixin1 ) );

    class TestMixClass2
    {
        mixin( stringMixin1 );
        int getY() { return 43; }
    }
    assert( hasStringMixin!( TestMixClass2, stringMixin1 ) );

    class TestMixClass3
    {
        int getZ() { return 44; }
    }
    assert( !hasStringMixin!( TestMixClass3, stringMixin1 ) );

    class TestMixClass4
    {
        void methodString() { }
    }
    assert( hasStringMixin!( TestMixClass4, stringMixin1 ) );
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

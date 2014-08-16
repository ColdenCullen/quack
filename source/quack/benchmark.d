/**
 * Contains various benchmarks.
 */
module quack.benchmark;

// The following tests are just benchmarks, and without tested no time results
// are given.
version( unittest ):
version( Have_tested ):
private:

import quack, tested;

uint executionTimes = 100_000_000;
interface IFace
{
    void memberFunction();
}
class Class : IFace
{
    override void memberFunction() { }
}
struct Struct
{
    void memberFunction() { }
}

@name( "Interface Benchmark" )
unittest
{
    void callMember( IFace impl )
    {
        impl.memberFunction();
    }

    IFace c = new Class;
    foreach( i; 0..executionTimes )
    {
        callMember( c );
    }
}

@name( "Class Benchmark" )
unittest
{
    void callMember( Class impl )
    {
        impl.memberFunction();
    }

    Class c = new Class;
    foreach( i; 0..executionTimes )
    {
        callMember( c );
    }
}

@name( "Quack Benchmark" )
unittest
{
    void callMember( Impl )( Impl impl ) if( extends!( Impl, IFace ) )
    {
        impl.memberFunction();
    }

    Struct s;
    foreach( i; 0..executionTimes )
    {
        callMember( s );
    }
}

@name( "DuckPointer Benchmark" )
unittest
{
    void callMember( DuckPointer!IFace impl )
    {
        impl.memberFunction();
    }

    auto ptr = duck!IFace( new Struct );
    foreach( i; 0..executionTimes )
    {
        callMember( ptr );
    }
}

/**
 * Contains various benchmarks.
 */
module quack.benchmark;

// The following tests are just benchmarks, and without tested no time results
// are given.
version( Have_tested ):

import quack, tested;

uint executionTimes = 10_000_000;
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

    foreach( i; 0..executionTimes )
    {
        callMember( new Class );
    }
}

@name( "Class Benchmark" )
unittest
{
    void callMember( Class impl )
    {
        impl.memberFunction();
    }

    foreach( i; 0..executionTimes )
    {
        callMember( new Class );
    }
}

@name( "Quack Benchmark" )
unittest
{
    void callMember( Impl )( Impl impl ) if( extends!( Impl, IFace ) )
    {
        impl.memberFunction();
    }

    foreach( i; 0..executionTimes )
    {
        callMember( Struct() );
    }
}

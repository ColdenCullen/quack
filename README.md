## quack
[![Build Status](http://img.shields.io/travis/ColdenCullen/quack/master.svg?style=flat)](https://travis-ci.org/ColdenCullen/quack)
[![Coverage](http://img.shields.io/coveralls/ColdenCullen/quack/master.svg?style=flat)](https://coveralls.io/r/ColdenCullen/quack)
[![Release](http://img.shields.io/github/release/ColdenCullen/quack.svg?style=flat)](http://code.dlang.org/packages/quack)

A library for enabling compile-time duck typing in D.

#### Duck Typing

Duck typing is a reference to the phrase "if it walks like a duck, and quacks
like a duck, then it's probably a duck." The idea is that if a `struct` or
`class` has all the same members as another, it should be usable as the other.

#### Usage

Duck exists so that you may treat non-related types as polymorphic, at compile
time. There are two primary ways to use quack:

1) Taking objects as arguments: For this, you should use `extends!( A, B )`,
which returns true if A "extends" B. It can do this by implementing all of the
same members B has, or by having a variable of type B that it has set to
`alias this`.

2) Storing pointers to objects: For this, you should use a `DuckPointer!A`,
which can be created with `duck!A( B b )`, assuming B "extends" A (the actual
check is done using `extends`, so see the docs on that). Note that this approach
should only be used when you need to actually store the object, as it is much
slower than the pure template approach.

#### Examples

```d
import quack;
import std.stdio;

struct Base
{
  int x;
}

struct Child1
{
  Base b;
  alias b this;
}

struct Child2
{
    int x;
}

void someFunction( T )( T t ) if( extends!( T, Base ) )
{
    writeln( t.x );
}

struct HolderOfBase
{
    DuckPointer!Base myBase;
}

void main()
{
  someFunction( Child1() );
  someFunction( Child2() );

  auto aHolder1 = new HolderOfA( duck!Base( Child1() ) );
  auto aHolder2 = new HolderOfA( duck!Base( Child2() ) );
}
```

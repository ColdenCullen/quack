## quack
[![Build Status](http://img.shields.io/travis/ColdenCullen/quack/master.svg?style=flat)](https://travis-ci.org/ColdenCullen/quack)

A library for enabling compile-time duck typing in D.

#### Duck Typing

Duck typing is a reference to the phrase "if it walks like a duck, and quacks like a duck, then it's probably a duck." The idea is that if a `struct` or `class` has all the same members as another, it should be usable as the other.

#### Examples

```d
import quack;

struct A
{
  int x;
}

struct B
{
  A a;
  alias a this;
}

void someFunction( T )( T t ) if( extends!( T, A ) )
{

}

void main()
{
  B b;
  someFunction( b );
}
```

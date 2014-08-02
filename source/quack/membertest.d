/**
 *
 */
module quack.membertest;
import quack.extends;

import std.algorithm: among;

/**
 * Checks if Child extends Parent by having a matching set of members.
 *
 * Params:
 *      Child =         The base class to test.
 *      Parent =        The parent class to test.
 *
 * Returns:
 *      Whether Child has all the members of Parent.
 */
template hasSameMembers( Base, Parent )
{
    static if( isExtendable!( Base, Parent ) )
    {
        enum hasSameMembers = {
            // If there are no members to check, return false.
            static if( [__traits( allMembers, Parent )].length == 0 )
            {
                return false;
            }
            else
            {
                foreach( member; __traits( allMembers, Parent ) )
                {
                    // Ignore some members.
                    static if( !member.among( "this" ) )
                    {
                        // If Base has the member, check the type.
                        static if( __traits( hasMember, Base, member ) )
                        {
                            static if( !is(
                                typeof( __traits( getMember, Parent, member ) ) ==
                                typeof( __traits( getMember, Base, member ) )
                                ) )
                            {
                                return false;
                            }
                        }
                        else
                        {
                            return false;
                        }
                    }
                }

                return true;
            }
        } ();
    }
    else
    {
        enum hasSameMembers = false;
    }
}
///
unittest
{
    struct S1
    {
        @property int x() { return 42; }
    }

    struct S2
    {
        @property int x() { return 42; }
    }

    assert( hasSameMembers!( S1, S2 ) );
}

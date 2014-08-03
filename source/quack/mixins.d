/**
 * Contains definition of hasTemplateMixin, which checks if a class or struct
 * defines all the members of a template mixin, and hasStringMixin, which
 * checks if a class or struct defines all the members of a string mixin.
 */
module quack.mixins;
import quack.extends;

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
template hasTemplateMixin( Child, alias mix )
{
    static if( isExtendable!Child )
    {
        struct MixinImpl
        {
            mixin mix!();
        }

        enum hasTemplateMixin = hasSameMembers!( Child, MixinImpl );
    }
    else
    {
        enum hasTemplateMixin = false;
    }
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
        struct MixinImpl
        {
            mixin( mix );
        }

        enum hasStringMixin = hasSameMembers!( Base, MixinImpl );
    }
    else
    {
        enum hasStringMixin = false;
    }
}

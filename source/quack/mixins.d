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
 *      MixinArgs =     The arguments to pass to the template mixin.
 *
 * Returns:
 *      Whether Child has all the members of mix.
 */
template hasTemplateMixin( Child, alias mix, MixinArgs... )
{
    static if( isExtendable!Child )
    {
        struct MixinImpl
        {
            mixin mix!( MixinArgs );
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
template hasStringMixin( Child, string mix )
{
    static if( isExtendable!Child )
    {
        struct MixinImpl
        {
            mixin( mix );
        }

        enum hasStringMixin = hasSameMembers!( Child, MixinImpl );
    }
    else
    {
        enum hasStringMixin = false;
    }
}

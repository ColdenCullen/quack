/**
 * For internal use only. Contains helpers for debugging quack.
 */
module quack.debughelpers;
import std.conv: to;

package:

/// The head to display before each message.
private enum errorHeader( string file, size_t line ) = file ~ "(" ~ line.to!string ~ ") quack error: ";

/// Generates an error message for a member mismatch.
enum memberMismatchError( Type, string member, string error, string file, size_t line ) =
    errorHeader!( file, line ) ~ Type.stringof ~ "." ~ member ~ ": " ~ error;

/// Extracts bit flags out to an array of enums.
EnumType[] extractFlags( EnumType, uint flags )() if( is( EnumType == enum ) )
{
    import std.traits: EnumMembers, OriginalType;
    EnumType[] enumFlags;
    foreach( member; EnumMembers!EnumType )
    {
        enum memberValue = cast(OriginalType!EnumType) member;

        static if( flags & memberValue )
        {
            enumFlags ~= member;
        }
    }

    return enumFlags;
}

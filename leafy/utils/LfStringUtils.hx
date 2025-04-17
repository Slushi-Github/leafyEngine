package leafy.utils;

/**
 * A class for string utility functions, code from Haxe library
 * 
 * @see https://github.com/HaxeFoundation/haxe/blob/4.3.3/std/StringTools.hx
 */
class LfStringUtils {

    /**
     * Replace a character in a string
     * @param str The original string
     * @param oldChar The character to replace
     * @param newChar The new character
     * @return String The new string
     */
    public static function stringReplacer(str:String, oldChar:String, newChar:String):String {
        return str.split(oldChar).join(newChar);
    }

    /**
     * Check if a string starts with another
     * @param str The original string
     * @param start The string to check
     * @return Bool Whether the string starts with the other
     */
    public static function stringStartsWith(str:String, start:String):Bool {
        return (str.length >= start.length && str.lastIndexOf(start, 0) == 0);
    }

    /**
     * Check if a string ends with another 
     * @param str The original string
     * @param ending The string to check
     * @return Bool Whether the string ends with the other
     */
    public static function stringEndsWith(str:String, ending:String):Bool {
        var elen = ending.length;
		var slen = str.length;
		return (slen >= elen && str.indexOf(ending, (slen - elen)) == (slen - elen));
    }
}
// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.utils;

import Std;

import leafy.system.console.SDCard;

typedef LfVector2D = {
    x:Float, 
    y:Float
}

typedef LfVector3D = {
    x:Float, 
    y:Float, 
    z:Float
}

typedef LfRect = {
    x:Float,
    y:Float,
    width:Float,
    height:Float
}

/**
 * Utility functions, simple class
 * 
 * Author: Slushi
 */
class LfUtils {
    /**
     * Remove the SD card path from the given path
     * @param path The path
     * @return String The new path without the SD card path
     */
    public static function removeSDDirFromPath(path:String):String {
        return LfStringUtils.stringReplacer(path, SDCard.getSDCardWiiUPath(), "");
    }

    /**
     * Rotate a point
     * @param x X value
     * @param y Y value
     * @param angleDegrees Angle in degrees
     * @param originX Origin X value
     * @param originY Origin Y value
     * @return LfVector2D
     */
    public static function rotatePoint(x:Float, y:Float, angleDegrees:Float, originX:Float, originY:Float):LfVector2D {
        var radians = angleDegrees * Math.PI / 180;
        var sinVal = Math.sin(radians);
        var cosVal = Math.cos(radians);

        var dx = x - originX;
        var dy = y - originY;

        return {
            x: Std.int(originX + dx * cosVal - dy * sinVal),
            y: Std.int(originX + dx * cosVal + dy * cosVal)
        };
    }

    /**
     * Get the sign of a number
     * @param n The number
     * @return Int The sign
     */
    public static function sign(n:Float):Int {
    return n > 0 ? 1 : (n < 0 ? -1 : 0);
    }

    /**
     * Returns the remainder of the division of `dividend` by `divisor`.
     * 
     * This is similar to the `%` operator, but it always returns a positive
     * result when `divisor` is positive.
     * 
     * @param dividend The dividend.
     * @param divisor The divisor.
     * @return The positive remainder.
     */
    public static function fmod(dividend:Float, divisor:Float):Float {
        return dividend - Math.floor(dividend / divisor) * divisor;
    }

}
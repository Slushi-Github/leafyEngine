// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.utils;

import Std;

import wiiu.SDCardUtil;

typedef LfVector2D = {x: Float, y: Float}
typedef LfVector3D = {x: Float, y: Float, z: Float}

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
        var sdPath = SDCardUtil.getSDCardPathFixed();
        return LfStringUtils.stringReplacer(path, sdPath, "");
    }

    /**
     * Rotate a point
     * @param x X value
     * @param y Y value
     * @param angleDegrees Angle in degrees
     * @param originX ...
     * @param originY ...
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

}
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

    // 3D functions
    // private function renderAs3D():Void {
    // var tex = this.sdlTexturePtr;
    // if (tex == null) return;

    // var cx:Float = this.x + this.width * 0.5;
    // var cy:Float = this.y + this.height * 0.5;
    // var w = this.width;
    // var h = this.height;

    // var quad:Array<LfVector3D> = [
    //     { x: -w / 2, y: -h / 2, z: 0 },
    //     { x:  w / 2, y: -h / 2, z: 0 },
    //     { x:  w / 2, y:  h / 2, z: 0 },
    //     { x: -w / 2, y:  h / 2, z: 0 }
    // ];

    // function rotate(v:LfVector3D, r:LfVector3D):LfVector3D {
    //     final rx = r.x, ry = r.y, rz = r.z;
    //     final sinX = Math.sin(rx), cosX = Math.cos(rx);
    //     final sinY = Math.sin(ry), cosY = Math.cos(ry);
    //     final sinZ = Math.sin(rz), cosZ = Math.cos(rz);

    //     var x = v.x, y = v.y, z = v.z;

    //     var x1 = x * cosZ - y * sinZ;
    //     var y1 = x * sinZ + y * cosZ;
    //     x = x1; y = y1;

    //     var x2 = x * cosY + z * sinY;
    //     var z1 = -x * sinY + z * cosY;
    //     x = x2; z = z1;

    //     var y2 = y * cosX - z * sinX;
    //     var z2 = y * sinX + z * cosX;
    //     y = y2; z = z2;

    //     return { x: x, y: y, z: z };
    // }

    // function project(v:LfVector3D):LfVector2D {
    //     var z = v.z + 1.0;
    //     var fov = 1.0 / Math.tan(Math.PI / 4);
    //     var scale = fov / z;
    //     return {
    //         x: cx + v.x * scale,
    //         y: cy + v.y * scale
    //     };
    // }

    // var verts:Array<SDL_Vertex> = [];
    // var color = this.sdlColor;

    // for (i in 0...4) {
    //     var rot = rotate(quad[i], this.angle3D);
    //     var proj = project(rot);

    //     var vertex = new SDL_Vertex();
    //     vertex.position.x = proj.x;
    //     vertex.position.y = proj.y;
    //     vertex.color = color;

    //     vertex.tex_coord.x = (i == 1 || i == 2) ? 1.0 : 0.0;
    //     vertex.tex_coord.y = (i >= 2) ? 1.0 : 0.0;

    //     verts.push(vertex);
    // }

    // verts.push(verts[2]);
    // verts.push(verts[3]);

    // var vertsPtr = untyped __cpp__("&{0}", verts[0]);

    // SDL_Render.SDL_SetTextureAlphaMod(tex, Std.int(this.alpha * 255));
    // SDL_Render.SDL_RenderGeometry(LfWindow.currentRenderer, tex, vertsPtr, verts.length, 0, 0);
    // }

}
// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.utils;

import Std;
import leafy.objects.LfSprite;

/**
 * Collision utils
 * 
 * Author: Slushi
 */
class LfCollision {

    /**
     * Check if two sprites are colliding
     * @param a First sprite
     * @param b Second sprite
     * @return Bool Whether the sprites are colliding
     */
    public static function checkCollision(a:LfSprite, b:LfSprite):Bool {
        return (a.x < b.x + b.width &&
                a.x + a.width > b.x &&
                a.y < b.y + b.height &&
                a.y + a.height > b.y);
    }

    /**
     * Separate two sprites
     * @param a First sprite
     * @param b Second sprite
     */
    public static function separate(a:LfSprite, b:LfSprite):Void {
    if (!checkCollision(a, b)) return;

    var overlapX = 0.0;
    var overlapY = 0.0;

    var aCenterX = a.x + a.width / 2;
    var bCenterX = b.x + b.width / 2;
    var aCenterY = a.y + a.height / 2;
    var bCenterY = b.y + b.height / 2;

    if (aCenterX < bCenterX)
        overlapX = (a.x + a.width) - b.x;
    else
        overlapX = a.x - (b.x + b.width);

    if (aCenterY < bCenterY)
        overlapY = (a.y + a.height) - b.y;
    else
        overlapY = a.y - (b.y + b.height);

    if (Math.abs(overlapX) < Math.abs(overlapY)) {
        a.x -= Std.int(overlapX);
        a.velocity.x = 0;
    } else {
        a.y -= Std.int(overlapY);
        a.velocity.y = 0;
    }
}

}
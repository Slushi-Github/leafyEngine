// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.objects;

/**
 * A button object, used to perform actions when clicked. Based on `LfSprite`
 * 
 * Author: Slushi
 */
class LfButton extends LfSprite {
    /**
     * The action to perform when the button is clicked
     */
    private var actionOnClick:Void->Void;

    /**
     * Creates a new button
     * @param x The X position of the sprite
     * @param y The Y position of the sprite
     * @param action The action to perform when the button is clicked
     */
    public function new(x:Int, y:Int, action:Void->Void) {
        super(x, y);

        this.x = x;
        this.y = y;

        this.actionOnClick = action;
    }

    /**
     * Updates the button function
     * @param elapsed The elapsed time
     */
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (actionOnClick != null) {
            if (Leafy.wiiuGamepad.touchJustPressed() && Leafy.wiiuGamepad.isTouchingSprite(this)) {
                actionOnClick();
            }
        }
    }
}
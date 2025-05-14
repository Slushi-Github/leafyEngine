// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.objects;

import Std;

import sdl2.SDL_Render.SDL_Texture;
import sdl2.SDL_Pixels.SDL_Color;
import sdl2.SDL_Render;
import sdl2.SDL_Rect;
import sdl2.SDL_Surface.SDL_Surface;

import leafy.backend.sdl.LfWindow;
import leafy.utils.LfUtils.LfVector2D;
import leafy.utils.LfUtils;


/**
 * Type of the object
 */
enum ObjectType {
    SPRITE;
    TEXT_SPRITE;
}

/**
 * Center mode of the object
 */
enum CenterMode {
    CENTER_X;
    CENTER_Y;
}

/**
 * Base class for all objects
 * 
 * Author: Slushi
 */
class LfObject extends LfBase {
    /**
     * Name of the object
     */
    public var name:String;

    /**
     * Type of the object
     */
    public var type:ObjectType;

    /**
     * If the object is ready to be rendered
     */
    public var readyToRender:Bool;

    /**
     * Camera of the object
     */
    // public var camera:LfCamera;

    // SDL Data //////////////////////////////

    /**
     * Pointer to the SDL_Surface.
     */
    public var sdlSurfacePtr:Ptr<SDL_Surface>;

    /**
     * Pointer to the SDL_Texture.
     */
    public var sdlTexturePtr:Ptr<SDL_Texture>;

    /**
     * Color of the object.
     */
    public var color:SDL_Color;

    /**
     * Rect of the object.
     */
    public var rect:SDL_Rect;

    // General Data //////////////////////////

    /**
     * X coordinate of the object.
     */
    public var x:Int;

    /**
     * Y coordinate of the object.
     */
    public var y:Int;

    /**
     * Width of the object.
     */
    public var width:Int;

    /**
     * Height of the object.
     */
    public var height:Int;

    /**
     * Angle of the object.
     */
    public var angle:Int;

    /**
     * Scale of the object.
     */
    public var scale:LfVector2D;

    /**
     * Alpha of the object.
     */
    public var alpha:Float;

    /**
     * If the object is visible.
     */
    public var isVisible:Bool;

    /**
     * Velocity of the sprite
     */
    public var velocity:LfVector2D;

    /**
     * Acceleration of the sprite
     */
    public var acceleration:LfVector2D;

    /**
     * Drag of the sprite
     */
    public var drag:LfVector2D;

    /**
     * Max velocity of the sprite
     */
    public var maxVelocity:LfVector2D;

    /**
     * Gravity of the sprite
     */
    public var gravity:Float;

    /**
     * Can the sprite be moved by the gravity?
     */
    public var immovable:Bool;

    ////////////////////////////////

    override public function update(elapsed:Float):Void {
        if (!this.immovable) {
            this.acceleration.y += gravity;

            this.velocity.x += this.acceleration.x * elapsed;
            this.velocity.y += this.acceleration.y * elapsed;

            this.velocity.x -= this.drag.x * elapsed * LfUtils.sign(this.velocity.x);
            this.velocity.y -= this.drag.y * elapsed * LfUtils.sign(this.velocity.y);

            if (Math.abs(this.velocity.x) > this.maxVelocity.x)
                this.velocity.x = this.maxVelocity.x * LfUtils.sign(this.velocity.x);

            if (Math.abs(this.velocity.y) > this.maxVelocity.y)
                this.velocity.y = this.maxVelocity.y * LfUtils.sign(this.velocity.y);

            this.x += Std.int(this.velocity.x * elapsed);
            this.y += Std.int(this.velocity.y * elapsed);

            this.acceleration.x = 0;
            this.acceleration.y = 0;
        }
    }

    ////////////////////////////////

    override public function render() {
        if (!this.readyToRender || !this.isVisible) {
            return;
        }
    }

    /**
     * Function to resize the object
     * @param scaleX The scale in the X direction
     * @param scaleY The scale in the Y direction
     */
    public function resize(scaleX:Float, scaleY:Float):Void {
        var newW = Std.int(this.width * scaleX);
        var newH = Std.int(this.height * scaleY);
        this.width = (newW > 0) ? newW : 1;
        this.height = (newH > 0) ? newH : 1;
    }

    /**
     * Function to set the position of the object
     * @param x The X coordinate of the object
     * @param y The Y coordinate of the object
     */
    public function setPosition(x:Int, y:Int):Void {
        this.x = x;
        this.y = y;
    }

    /**
     *  Center the object in the screen
     * @param centerMode The mode to center the object
     */
    public function center(?centerMode:CenterMode):Void {
        if (this.width <= 0 || this.height <= 0) {
            LeafyDebug.log("Object dimensions invalid before centering", ERROR);
            return;
        }

        switch (centerMode) {
            case CenterMode.CENTER_X:
                this.x = Std.int((Leafy.screenWidth - this.width) / 2);
            case CenterMode.CENTER_Y:
                this.y = Std.int((Leafy.screenHeight - this.height) / 2);
            default:
                this.x = Std.int((Leafy.screenWidth - this.width) / 2);
                this.y = Std.int((Leafy.screenHeight - this.height) / 2);
        }
    }

    /**
     * Get the screen position of the object
     * @return LfVector2D
     */
    // public function getScreenPosition():LfVector2D {
    //     if (camera == null) {
    //         return { x: this.x, y: this.y };
    //     }

    //     return {
    //         x: Std.int((this.x - camera.x) * camera.zoom),
    //         y: Std.int((this.y - camera.y) * camera.zoom)
    //     };
    // }

    
    /////////////////////////////////////////////

    /**
     * Reflaxe/C++ internal function
     */
    public function destructor() {
        destroy();
    }
}
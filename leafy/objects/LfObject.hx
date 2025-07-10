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
import sdl2.SDL_Image;

import leafy.backend.sdl.LfWindow;
import leafy.utils.LfUtils.LfVector2D;
import leafy.utils.LfUtils;


/**
 * Type of the object
 */
enum ObjectType {
    SPRITE;
    TEXT_SPRITE;
    OTHER;
}

/**
 * Center mode of the object
 */
enum CenterMode {
    CENTER_X;
    CENTER_Y;
    CENTER_XY;
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

    // SDL variables //////////////////////////////

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
    public var sdlColor:SDL_Color;

    /**
     * Rect of the object.
     */
    public var sdlRect:SDL_Rect;

    /**
     * Used to determine if the object can be rendered or not
     * with the default render method.
     */
    public var omitDefaultRenderMethod:Bool = false;

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

    /**
     * If the object is alive or not.
     * This is used to determine if the object should be updated or rendered.
     */
    public var alive:Bool;

    ////////////////////////////////

    override public function update(elapsed:Float):Void {
        updateSDLRect();

        // TODO: FIX THIS (0x02025fa4 --> leafy_objects_LfObject.cpp:31)
        // if (!this.immovable && this.alive) {
        //     this.acceleration.y += gravity;

        //     this.velocity.x += this.acceleration.x * elapsed;
        //     this.velocity.y += this.acceleration.y * elapsed;

        //     this.velocity.x -= this.drag.x * elapsed * LfUtils.sign(this.velocity.x);
        //     this.velocity.y -= this.drag.y * elapsed * LfUtils.sign(this.velocity.y);

        //     if (Math.abs(this.velocity.x) > this.maxVelocity.x)
        //         this.velocity.x = this.maxVelocity.x * LfUtils.sign(this.velocity.x);

        //     if (Math.abs(this.velocity.y) > this.maxVelocity.y)
        //         this.velocity.y = this.maxVelocity.y * LfUtils.sign(this.velocity.y);

        //     this.x += Std.int(this.velocity.x * elapsed);
        //     this.y += Std.int(this.velocity.y * elapsed);

        //     this.acceleration.x = 0;
        //     this.acceleration.y = 0;
        // }
    }

    ////////////////////////////////

    override public function render() {
        if (this.omitDefaultRenderMethod) {
            return;
        }

        if (!this.readyToRender || !this.isVisible || this.alpha == 0 || !this.isOnScreen() || !this.alive) {
            return;
        }

        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to render object: [" + this.name + "] - Texture is null (" + SDL_Image.IMG_GetError().toString() + ")", ERROR);
            return;
        }

        if (this.alpha < 0) {
            this.alpha = 0;
        }
        else if (this.alpha > 1) {
            this.alpha = 1;
        }

        SDL_Render.SDL_SetTextureAlphaMod(this.sdlTexturePtr, Std.int(this.alpha * 255));
        SDL_Render.SDL_RenderCopyEx(LfWindow.currentRenderer, this.sdlTexturePtr, null, this.sdlRect, this.angle, null, SDL_FLIP_NONE);
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
    public function center(?centerMode:CenterMode = CenterMode.CENTER_XY):Void {
        if (this.width <= 0 || this.height <= 0) {
            LeafyDebug.log("Object dimensions invalid before centering", ERROR);
            return;
        }

        switch (centerMode) {
            case CenterMode.CENTER_X:
                this.x = Std.int((Leafy.screenWidth - this.width) / 2);
            case CenterMode.CENTER_Y:
                this.y = Std.int((Leafy.screenHeight - this.height) / 2);
            case CenterMode.CENTER_XY:
                this.x = Std.int((Leafy.screenWidth - this.width) / 2);
                this.y = Std.int((Leafy.screenHeight - this.height) / 2);
            default:
                LeafyDebug.log("Invalid center mode!", ERROR);
                return;
        }
    }

    public function isOnScreen():Bool {
        return this.x < Leafy.screenWidth && this.x + this.width > 0 && this.y < Leafy.screenHeight && this.y + this.height > 0;
    }

    /**
     *  Set the object color
     * @param newColor The new color
     */
    public function setColor(r:UInt8, g:UInt8, b:UInt8):Void {
        if (this.sdlColor == null) {
            LeafyDebug.log("Object color is null, cannot update text color", ERROR);
            return;
        }

        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to set color for object: [" + this.name + "] - Texture is null (" + SDL_Image.IMG_GetError().toString() + ")", ERROR);
            return;
        }

        this.readyToRender = false;

        this.sdlColor.r = r;
        this.sdlColor.g = g;
        this.sdlColor.b = b;
        this.sdlColor.a = 255; // Alpha is always 255 for color mod

        var result:Int = SDL_Render.SDL_SetTextureColorMod(this.sdlTexturePtr, this.sdlColor.r, this.sdlColor.g, this.sdlColor.b);
        if (result != 0) {
            LeafyDebug.log("Failed to set color for object: [" + this.name + "] - " + SDL_Image.IMG_GetError().toString(), ERROR);
            return;
        }

        this.readyToRender = true;
    }

    public function disable():Void {
        this.alive = false;
    }

    public function reset():Void {
        this.alive = true;
    }

    private function updateSDLRect():Void {
        if (this.sdlRect == null) {
            return;
        }
        this.sdlRect.x = this.x;
        this.sdlRect.y = this.y;
        this.sdlRect.w = this.width;
        this.sdlRect.h = this.height;
    }

    override public function destroy():Void {
        this.alive = false;
    }
    
    /////////////////////////////////////////////

    /**
     * Reflaxe/C++ internal function
     */
    public function destructor() {
        destroy();
    }
}
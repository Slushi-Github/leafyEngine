// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.objects;

import Std;

import sdl2.SDL_Render.SDL_Texture;
import sdl2.SDL_Render;
import sdl2.SDL_Render.SDL_RendererFlip;
import sdl2.SDL_Pixels.SDL_Color;
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
 * Scale mode of the object
 */
enum ScaleMode {
    NEAREST;
    LINEAR;
    BEST;
}

/**
 * Flip mode of the object
 */
enum FlipMode {
    NONE;
    HORIZONTAL;
    VERTICAL;
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
    public var name:String = "";

    /**
     * Type of the object
     */
    public var type:ObjectType = ObjectType.OTHER;

    /**
     * If the object is ready to be rendered
     */
    public var readyToRender:Bool = false;

    // SDL variables //////////////////////////////

    /**
     * Pointer to the SDL_Surface.
     */
    public var sdlSurfacePtr:Ptr<SDL_Surface> = null;

    /**
     * Pointer to the SDL_Texture.
     */
    public var sdlTexturePtr:Ptr<SDL_Texture> = null;

    /**
     * Color of the object.
     */
    public var sdlColor:SDL_Color = new SDL_Color();

    /**
     * Rect of the object.
     */
    public var sdlRect:SDL_Rect = new SDL_Rect();

    /**
     * Used to determine if the object can be rendered or not
     * with the default render method.
     */
    public var omitDefaultRenderMethod:Bool = false;

    // public var angle3D:LfVector3D = {
    //     x: 0,
    //     y: 0,
    //     z: 0
    // };

    // public var use3D:Bool = false;

    // General Data //////////////////////////

    /**
     * X coordinate of the object.
     */
    public var x:Int = 0;

    /**
     * Y coordinate of the object.
     */
    public var y:Int = 0;

    /**
     * Width of the object.
     */
    public var width:Int = 0;

    /**
     * Height of the object.
     */
    public var height:Int = 0;

    /**
     * Angle of the object.
     */
    public var angle:Int = 0;

    /**
     * Scale of the object.
     */
    public var scale:LfVector2D = {x: 1, y: 1};

    /**
     * Alpha of the object.
     */
    public var alpha:Float = 1.0;

    /**
     * If the object is visible.
     */
    public var isVisible:Bool = true;

    /**
     * Velocity of the object
     */
    public var velocity:LfVector2D = {x: 0, y: 0};

    /**
     * Acceleration of the object
     */
    public var acceleration:LfVector2D = {x: 0, y: 0};

    /**
     * Drag of the object
     */
    public var drag:LfVector2D = {x: 0, y: 0};

    /**
     * Max velocity of the object
     */
    public var maxVelocity:LfVector2D = {x: 0, y: 0};

    /**
     * Gravity of the object
     */
    public var gravity:Float = 0.0;

    /**
     * Can the object be affected by the gravity?
     */
    public var immovable:Bool = false;

    /**
     * If the object is alive or not.
     * This is used to determine if the object should be updated or rendered.
     */
    public var alive:Bool = true;

    /**
     * SCale mode of the object
     */
    public var scaleMode:ScaleMode = null;

    /**
     * Flip mode of the object
     */
    public var flipMode:FlipMode = FlipMode.NONE;

    ////////////////////////////////

    override public function update(elapsed:Float):Void {
        updateSDLRect();

        if (!this.immovable && this.alive) {
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
        if (this.omitDefaultRenderMethod) {
            return;
        }

        if (!this.readyToRender || !this.isVisible || this.alpha == 0.0 || !this.isOnScreen() || !this.alive) {
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

        // Render as 3D object if needed
        // if ((angle3D.x != 0 || angle3D.y != 0 || angle3D.z != 0) && use3D) {
        //     renderAs3D();
        //     return;
        // }

        SDL_Render.SDL_SetTextureAlphaMod(this.sdlTexturePtr, Std.int(this.alpha * 255));
        SDL_Render.SDL_RenderCopyEx(LfWindow.currentRenderer, this.sdlTexturePtr, null, this.sdlRect, this.angle, null, convertFlipModeToSDL(this.flipMode));
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
     * Set the object color
     * @param newColor The new color
     */
    public function setColor(r:UInt8, g:UInt8, b:UInt8):Void {
        if (this.sdlColor == null) {
            LeafyDebug.log("Object color is null, cannot update object texture color", ERROR);
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
        this.sdlColor.a = Std.int(this.alpha * 255);

        var result:Int = SDL_Render.SDL_SetTextureColorMod(this.sdlTexturePtr, this.sdlColor.r, this.sdlColor.g, this.sdlColor.b);
        if (result != 0) {
            LeafyDebug.log("Failed to set color for object: [" + this.name + "] - " + SDL_Image.IMG_GetError().toString(), ERROR);
            return;
        }

        this.readyToRender = true;
    }

    /*
     * Disable the object
     */
    public function disable():Void {
        this.alive = false;
    }

    /**
     * Reset the object (alive)
     */
    public function reset():Void {
        this.alive = true;
    }

    /**
     * Resize the object to fit the screen
     */
    public function resizeToFitScreen():Void {
        if (this.width <= 0 || this.height <= 0) {
            LeafyDebug.log("Object dimensions invalid before resizing to fit screen", ERROR);
            return;
        }

        var scaleX = Leafy.screenWidth / this.width;
        var scaleY = Leafy.screenHeight / this.height;

        if (scaleX <= 0 || scaleY <= 0) {
            LeafyDebug.log("Invalid scale values for resizing to fit screen", ERROR);
            return;
        }

        this.resize(scaleX, scaleY);
        this.center();
    }

    /*
     * Set the scale mode of the object texture
     * @param scaleMode 
     */
    public function setScaleMode(scaleMode:ScaleMode):Void {
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to set scale mode for object: [" + this.name + "] - Texture is null (" + SDL_Image.IMG_GetError().toString() + ")", ERROR);
            return;
        }
        SDL_Render.SDL_SetTextureScaleMode(this.sdlTexturePtr, convertScaleModeToSDL(scaleMode));
        this.scaleMode = scaleMode;
    }

    /**
     * Set the flip mode of the object texture
     * @param flipMode
     */
    public function setFlipMode(flipMode:FlipMode):Void {
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to set flip mode for object: [" + this.name + "] - Texture is null (" + SDL_Image.IMG_GetError().toString() + ")", ERROR);
            return;
        }
        this.flipMode = flipMode;
    }

    /**
     * Convert a Leafy object scale mode to an SDL scale mode
     * @param scaleMode 
     * @return SDL_ScaleMode
     */
    private function convertScaleModeToSDL(scaleMode:ScaleMode):SDL_ScaleMode {
        switch (scaleMode) {
            case ScaleMode.LINEAR:
                return SDL_ScaleMode.SDL_ScaleModeLinear;
            case ScaleMode.NEAREST:
                return SDL_ScaleMode.SDL_ScaleModeNearest;
            case ScaleMode.BEST:
                return SDL_ScaleMode.SDL_ScaleModeBest;
            default:
                return SDL_ScaleMode.SDL_ScaleModeNearest;
        }
    }

    /**
     * Convert a Leafy object flip mode to an SDL flip mode
     * @param flipMode 
     * @return SDL_Render.SDL_RendererFlip
     */
    private function convertFlipModeToSDL(flipMode:FlipMode):SDL_RendererFlip {
        switch (flipMode) {
            case FlipMode.NONE:
                return SDL_RendererFlip.SDL_FLIP_NONE;
            case FlipMode.HORIZONTAL:
                return SDL_RendererFlip.SDL_FLIP_HORIZONTAL;
            case FlipMode.VERTICAL:
                return SDL_RendererFlip.SDL_FLIP_VERTICAL;
            default:
                return SDL_RendererFlip.SDL_FLIP_NONE;
        }
    }

    /**
     * Update the SDL rect of the object
     */
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
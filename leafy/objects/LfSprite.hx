// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.objects;

import Std;

import wiiu.SDCardUtil;

import sdl2.SDL_Image;
import sdl2.SDL_Render;
import sdl2.SDL_Surface.SDL_Surface;
import sdl2.SDL_Surface.SDL_SurfaceClass;
import sdl2.SDL_Rect;
import sdl2.SDL_Error;
import sdl2.SDL_Pixels;

import leafy.backend.sdl.LfWindow;
import leafy.utils.LfStringUtils;
import leafy.backend.LeafyDebug;
import leafy.objects.LfObject;
import leafy.utils.LfUtils;
import leafy.filesystem.LfSystemPaths;

/**
 * A sprite object, used to display images on the screen
 * 
 * Author: Slushi
 */
class LfSprite extends LfObject {
    /**
     * The path to the loaded image
     */
    public var imagePath:String;

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

    /////////////////////////////////////////////////////////////////////

    /**
     * Create a new sprite object
     * @param x The X position of the object
     * @param y The Y position of the object
     * @param mode The render mode of the object
     */
    public function new(x:Int, y:Int) {
        super();
        this.x = x;
        this.y = y;
        this.type = ObjectType.SPRITE;
        this.width = 0;
        this.height = 0;
        this.angle = 0;
        this.scale = {x: 1, y: 1};
        this.isVisible = true;
        this.alpha = 1.0;
        this.sdlTexturePtr = null;

        //////////////////

        this.imagePath = "";

        this.velocity = {x: 0, y: 0};
        this.acceleration = {x: 0, y: 0};
        this.drag = {x: 0, y: 0};
        this.maxVelocity = {x: 0, y: 0};
        this.gravity = 0;
        this.immovable = false; 
    }

    /**
     * Load an image into the sprite
     * @param imgPath The path to the image
     */
    public function loadImage(imgPath:String):Void {

        var correctPath:String = LfSystemPaths.getConsolePath() + imgPath;

        if (imgPath == null || imgPath == "") {
            LeafyDebug.log("Image path cannot be null or empty", ERROR);
            return;
        }
        else if (!LfStringUtils.stringEndsWith(correctPath, ".png")) {
            LeafyDebug.log("Image must be a PNG file", ERROR);
            return;
        }
        else if (!LfSystemPaths.exists(correctPath) ) {
            LeafyDebug.log("Image path does not exist: " + imgPath, ERROR);
            return;
        }

        if (this.readyToRender) {
            this.readyToRender = false;
        }

        this.imagePath = correctPath;
        this.name = LfUtils.removeSDDirFromPath(imgPath);

        var surface:Ptr<SDL_Surface> = SDL_Image.IMG_Load(ConstCharPtr.fromString(this.imagePath));
        if (surface == null) {
            LeafyDebug.log("Failed to load image: " + SDL_Error.SDL_GetError().toString(), ERROR);
            return;
        }

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, surface);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from surface: " + SDL_Error.SDL_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(surface);
            return;
        }

        SDL_SurfaceClass.SDL_FreeSurface(surface);

        var rect:SDL_Rect = new SDL_Rect();
        SDL_Render.SDL_QueryTexture(this.sdlTexturePtr, untyped __cpp__("NULL"), untyped __cpp__("NULL"), rect.w, rect.h);
        if (rect.w <= 0 || rect.h <= 0) {
            LeafyDebug.log("Failed to get texture size: " + SDL_Error.SDL_GetError().toString(), ERROR);
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            return;
        }

        this.width = rect.w;
        this.height = rect.h;

        this.readyToRender = true;
        LeafyDebug.log("Image loaded: " + imagePath, INFO);
    }

    /**
     * Create a simple colored graphic
     * @param width Width in pixels
     * @param height Height in pixels
     * @param color Array of 4 components: [R, G, B, A] (0-255)
     */
    public function createGraphic(width:Int, height:Int, color:Array<UInt8>):Void {
        if (color == null || color.length != 4) {
            LeafyDebug.log("Invalid color array. Must be [R, G, B, A]", ERROR);
            return;
        }

        if (this.sdlTexturePtr != null) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
        }

        this.imagePath = "";
        this.width = width;
        this.height = height;

        var surface:Ptr<SDL_Surface> = SDL_SurfaceClass.SDL_CreateRGBSurface(
            0,
            width,
            height,
            32,
            0x00FF0000,
            0x0000FF00,
            0x000000FF,
            0xFF000000 
        );

        if (surface == null) {
            LeafyDebug.log("Failed to create surface: " + SDL_Error.SDL_GetError().toString(), ERROR);
            return;
        }

        var colorR:UInt8 = color[0];
        var colorG:UInt8 = color[1];
        var colorB:UInt8 = color[2];
        var colorA:UInt8 = color[3];

        var mappedColor:UInt32 = SDL_PixelsClass.SDL_MapRGBA(
            surface.format,
            colorR,
            colorG,
            colorB,
            colorA
        );

        SDL_SurfaceClass.SDL_FillRect(surface, null, mappedColor);

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, surface);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from surface: " + SDL_Error.SDL_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(surface);
            return;
        }

        SDL_SurfaceClass.SDL_FreeSurface(surface);

        this.name = "Graphic_(" + width + "x" + height + ")";

        this.readyToRender = true;
        LeafyDebug.log("Generated graphic (" + width + "x" + height + ")", INFO);
    }


    /////////////////////////////////////////////////////////////////////

    override public function update(elapsed:Float):Void {
        if (this.immovable) {
            return;
        }

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

    /**
     * Render the sprite
     */
    override public function render():Void {
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to render sprite: [" + this.name + "] - Texture is null (" + SDL_Image.IMG_GetError().toString() + ")", ERROR);
            return;
        }

        // var localX = (this.x - camera.x) * camera.zoom;
        // var localY = (this.y - camera.y) * camera.zoom;
        // var centerX = Std.int(Leafy.screenWidth / 2);
        // var centerY = Std.int(Leafy.screenHeight / 2);

        // var rotatedPos = LfUtils.rotatePoint(localX, localY, camera.angle, centerX, centerY);

        // var rect:SDL_Rect = new SDL_Rect();
        // rect.x = Std.int(rotatedPos.x);
        // rect.y = Std.int(rotatedPos.y);
        // rect.w = Std.int(this.width * camera.zoom);
        // rect.h = Std.int(this.height * camera.zoom);

        // var totalAngle = this.angle + camera.angle;

        var rect:SDL_Rect = new SDL_Rect();
        rect.x = this.x;
        rect.y = this.y;
        rect.w =this.width;
        rect.h = this.height;

        SDL_Render.SDL_RenderCopyEx(LfWindow.currentRenderer, this.sdlTexturePtr, null, rect, this.angle, null, SDL_FLIP_NONE);
    }

    /**
     * Destroy the sprite
     */
    override public function destroy():Void {
        if (this.sdlTexturePtr != null) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
            this.readyToRender = false;
        }
        LeafyDebug.log("Sprite destroyed: " + this.name, INFO);
    }

    /////////////////////////////////////////////////////////////////////
}
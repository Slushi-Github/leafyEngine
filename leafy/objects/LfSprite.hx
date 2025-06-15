// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.objects;

import Std;

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
        this.sdlSurfacePtr = null;
        this.sdlRect = new SDL_Rect();
        this.readyToRender = false;

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
        if (!LfStringUtils.stringEndsWith(correctPath, ".png")) {
            LeafyDebug.log("Image must be a PNG file", ERROR);
            return;
        }
        if (!LfSystemPaths.exists(correctPath) ) {
            LeafyDebug.log("Image path does not exist: " + imgPath, ERROR);
            return;
        }

        this.readyToRender = false;

        this.imagePath = correctPath;
        this.name = LfUtils.removeSDDirFromPath(this.imagePath);

        if (this.sdlTexturePtr != null) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
        }

        if (this.sdlSurfacePtr != null) {
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            this.sdlSurfacePtr = null;
        }

        this.sdlSurfacePtr = SDL_Image.IMG_Load(ConstCharPtr.fromString(this.imagePath));
        if (this.sdlSurfacePtr == null) {
            LeafyDebug.log("Failed to load image: " + SDL_Error.SDL_GetError().toString(), ERROR);
            return;
        }

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, this.sdlSurfacePtr);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from surface: " + SDL_Error.SDL_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            return;
        }

        SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
        this.sdlSurfacePtr = null;

        SDL_Render.SDL_SetTextureBlendMode(this.sdlTexturePtr, SDL_BLENDMODE_BLEND);

        SDL_Render.SDL_QueryTexture(this.sdlTexturePtr, untyped __cpp__("NULL"), untyped __cpp__("NULL"), sdlRect.w, sdlRect.h);
        if (sdlRect.w <= 0 || sdlRect.h <= 0) {
            LeafyDebug.log("Failed to get texture size: " + SDL_Error.SDL_GetError().toString(), ERROR);
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            return;
        }

        sdlRect.x = this.x;
        sdlRect.y = this.y;

        this.width = sdlRect.w;
        this.height = sdlRect.h;

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
        if (color == null || color.length != 3) {
            LeafyDebug.log("Invalid color array. Must be [R, G, B]", ERROR);
            return;
        }

        if (width <= 0 || height <= 0) {
            LeafyDebug.log("Width and height must be greater than 0", ERROR);
            return;
        }

        this.readyToRender = false;

        this.imagePath = "";
        this.width = width;
        this.height = height;

        this.sdlRect.w = this.width;
        this.sdlRect.h = this.height;

        if (this.sdlSurfacePtr != null) {
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            this.sdlSurfacePtr = null;
        }

        this.sdlSurfacePtr = SDL_SurfaceClass.SDL_CreateRGBSurface(
            0,
            width,
            height,
            32,
            0x00FF0000,
            0x0000FF00,
            0x000000FF,
            0xFF000000 
        );

        if (this.sdlSurfacePtr == null) {
            LeafyDebug.log("Failed to create surface: " + SDL_Error.SDL_GetError().toString(), ERROR);
            return;
        }

        // TODO: Make use of setColor function instead of this code
        var mappedColor:UInt32 = SDL_PixelsClass.SDL_MapRGBA(
            this.sdlSurfacePtr.format,
            color[0], // R
            color[1], // G
            color[2], // B
            255 // A (Alpha is always 255 for solid color)
        );

        SDL_SurfaceClass.SDL_FillRect(this.sdlSurfacePtr, null, mappedColor);

        if (this.sdlTexturePtr != null) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
        }

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, this.sdlSurfacePtr);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from surface: " + SDL_Error.SDL_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            return;
        }

        // this.setColor(color[0], color[1], color[2], color[3]);

        SDL_Render.SDL_SetTextureBlendMode(this.sdlTexturePtr, SDL_BLENDMODE_BLEND);

        SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
        this.sdlSurfacePtr = null;

        this.name = "Graphic_(" + width + "x" + height + ")";

        this.readyToRender = true;
        LeafyDebug.log("Generated graphic (" + width + "x" + height + ")", DEBUG);
    }


    /////////////////////////////////////////////////////////////////////
    /**
     * Destroy the sprite
     */
    override public function destroy():Void {
        if (this.sdlSurfacePtr != null) {
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            this.sdlSurfacePtr = null;
        }
        if (this.sdlTexturePtr != null) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
            this.readyToRender = false;
        }
        LeafyDebug.log("Sprite destroyed: " + this.name, INFO);
    }

    /////////////////////////////////////////////////////////////////////
}
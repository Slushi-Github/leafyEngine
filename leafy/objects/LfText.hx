// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.objects;

import Std;

import sdl2.SDL_TTF;
import sdl2.SDL_Pixels.SDL_Color;
import sdl2.SDL_Render;
import sdl2.SDL_Render.SDL_Texture;
import sdl2.SDL_Surface.SDL_Surface;
import sdl2.SDL_Surface.SDL_SurfaceClass;
import sdl2.SDL_Rect;

import leafy.filesystem.LfSystemPaths;
import leafy.backend.sdl.LfWindow;
import leafy.objects.LfObject;
import leafy.utils.LfUtils;

/**
 * A text object, used to display text on the screen, is the same thing as a LfSprite, but with text
 * 
 * Author: Slushi
 */
class LfText extends LfObject {
    public var text:String = "";
    public var size:UInt32 = 20;
    public var length:Int = 0;
    public var fontPath:String = "";

    private var fontPtr:Ptr<TTF_Font>;
    private var failed:Bool = false;

    /////////////////////////////////////////////////////////////////////

    /**
     * Create a new text object
     * @param x The X position of the object
     * @param y The Y position of the object
     * @param text The text to display
     * @param size The size of the font
     * @param fontPath The path to the font
     * @param mode The render mode of the object
     */
    public function new(x:Int, y:Int, text:String, size:UInt32, fontPath:String) {
        super();

        var correctPath:String = LfSystemPaths.getConsolePath() + fontPath;

        if (size <= 0) {
            LeafyDebug.log("Font size is invalid", ERROR);
            return;
        }
        else if (fontPath == null || fontPath == "") {
            LeafyDebug.log("Font path cannot be null or empty", ERROR);
            return;
        }
        else if (text == null || text == "") {
            LeafyDebug.log("Text cannot be null or empty", ERROR);
            return;
        }
        else if (!LfSystemPaths.exists(correctPath)) {
            LeafyDebug.log("Font path does not exist: " + fontPath, ERROR);
            return;
        }

        //////////////////

        this.type = ObjectType.TEXT_SPRITE;
        this.x = x;
        this.y = y;
        this.width = 0;
        this.height = 0;
        this.angle = 0;
        this.scale = {x: 1, y: 1};
        this.isVisible = true;
        this.alpha = 1.0;
        this.sdlTexturePtr = null;
        this.sdlSurfacePtr = null;
        this.sdlColor = new SDL_Color();
        this.sdlRect = new SDL_Rect();
        this.readyToRender = false;
        this.alive = true;
        this.immovable = true;

        this.velocity = {x: 0, y: 0};
        this.acceleration = {x: 0, y: 0};
        this.drag = {x: 0, y: 0};
        this.maxVelocity = {x: 0, y: 0};
        this.gravity = 0;

        //////////////////

        this.text = text;
        this.size = size;
        this.fontPath = fontPath;

        // Set the default color to white 
        this.sdlColor.r = 255;
        this.sdlColor.g = 255;
        this.sdlColor.b = 255;
        this.sdlColor.a = Std.int(this.alpha * 255);

        LeafyDebug.log("Loading font: " + LfUtils.removeSDDirFromPath(fontPath) + " with size: " + size + " for text: [" + text + "]", DEBUG);

        this.fontPtr = SDL_TTF.TTF_OpenFont(ConstCharPtr.fromString(correctPath), size);
        if (untyped __cpp__("fontPtr == nullptr")) {
            LeafyDebug.log("Failed to load font: " + LfUtils.removeSDDirFromPath(fontPath) + " with size: " + size, ERROR);
            failed = true;
            return;
        }

        this.sdlSurfacePtr = SDL_TTF.TTF_RenderText_Blended(this.fontPtr, ConstCharPtr.fromString(text), this.sdlColor);
        if (untyped __cpp__("sdlSurfacePtr == nullptr")) {
            LeafyDebug.log("Failed to create surface for text: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            SDL_TTF.TTF_CloseFont(this.fontPtr);
            return;
        }

        LeafyDebug.log("Creating texture from surface for text: [" + text + "]", DEBUG);

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, this.sdlSurfacePtr);
        if (untyped __cpp__("sdlTexturePtr == nullptr")) {
            LeafyDebug.log("Failed to create texture from surface: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            SDL_TTF.TTF_CloseFont(this.fontPtr);
            return;
        }

        SDL_Render.SDL_SetTextureBlendMode(this.sdlTexturePtr, SDL_BLENDMODE_BLEND);

        this.setColor(255, 255, 255);

        this.width = this.sdlSurfacePtr.w;
        this.height = this.sdlSurfacePtr.h;

        this.sdlRect.x = this.x;
        this.sdlRect.y = this.y;

        if (this.width <= 0 || this.height <= 0) {
            LeafyDebug.log("Invalid dimensions for text: " + text, ERROR);
        }

        this.sdlRect.w = this.width;
        this.sdlRect.h = this.height;

        this.length = this.text.length;

        LeafyDebug.log("Created texture from surface for text: [" + text + "], destroying surface", DEBUG);

        SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
        this.sdlSurfacePtr = null;

        this.readyToRender = true;

        this.name = LfUtils.removeSDDirFromPath(fontPath) + "_" + text;

        LeafyDebug.log("Created text sprite: [" + this.name + "]", DEBUG);
    }

    /////////////////////////////////////////////////////////////////////

    /**
     * Set the text remaking the texture
     * @param newText The new text
     */
    public function setText(newText:String):Void {
        if (this.failed) {
            LeafyDebug.log("Cannot set text, SDL TTF font loading failed", ERROR);
            return;
        }

        if (newText == null || newText == "") {
            LeafyDebug.log("New text cannot be null or empty", ERROR);
            return;
        }

        this.readyToRender = false;

        if (untyped __cpp__("fontPtr == nullptr")) {
            LeafyDebug.log("Font pointer is null, cannot set text", ERROR);
            return;
        }

        this.sdlSurfacePtr = SDL_TTF.TTF_RenderText_Blended(this.fontPtr, ConstCharPtr.fromString(newText), this.sdlColor);
        if (this.sdlSurfacePtr == null) {
            LeafyDebug.log("Failed to create surface for new text: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            return;
        }

        if (this.sdlTexturePtr != null) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
        }

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, this.sdlSurfacePtr);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from new surface: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            return;
        }

        SDL_Render.SDL_SetTextureBlendMode(this.sdlTexturePtr, SDL_BLENDMODE_BLEND);

        this.setColor(this.sdlColor.r, this.sdlColor.g, this.sdlColor.b);

        this.width = this.sdlSurfacePtr.w;
        this.height = this.sdlSurfacePtr.h;

        this.sdlRect.x = this.x;
        this.sdlRect.y = this.y;
        this.sdlRect.w = this.width;
        this.sdlRect.h = this.height;

        SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
        this.sdlSurfacePtr = null;

        this.text = newText;
        this.length = this.text.length;
        this.name = LfUtils.removeSDDirFromPath(fontPath) + "_" + newText;

        this.readyToRender = true;
    }

    public function setFontPath(fontPath:String, size:Int):Void {
        var correctPath:String = LfSystemPaths.getConsolePath() + fontPath;

        if (size <= 0) {
            LeafyDebug.log("Font size is invalid", ERROR);
            return;
        }
        else if (fontPath == null || fontPath == "") {
            LeafyDebug.log("Font path cannot be null or empty", ERROR);
            return;
        }
        else if (!LfSystemPaths.exists(correctPath)) {
            LeafyDebug.log("Font path does not exist: " + fontPath, ERROR);
            return;
        }
        
        this.fontPath = fontPath;
        this.size = size;
        this.fontPtr = SDL_TTF.TTF_OpenFont(ConstCharPtr.fromString(correctPath), size);
        if (untyped __cpp__("fontPtr == nullptr")) {
            LeafyDebug.log("Failed to load font: " + LfUtils.removeSDDirFromPath(fontPath) + " with size: " + size, ERROR);
            return;
        }
    }

    ////////////////////////////////////////////////

    /**
     * Destroy the text
     */
    override public function destroy():Void {
        if (untyped __cpp__("sdlTexturePtr != nullptr")) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
        }

        if (untyped __cpp__("sdlSurfacePtr != nullptr")) {
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            this.sdlSurfacePtr = null;
        }

        if (untyped __cpp__("fontPtr != nullptr")) {
            SDL_TTF.TTF_CloseFont(this.fontPtr);
        }

        LeafyDebug.log("Text destroyed: " + this.name, DEBUG);
    }
}
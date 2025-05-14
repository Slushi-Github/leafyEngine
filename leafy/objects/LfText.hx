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

    private var fontPtr:Ptr<TTF_Font>;
    public var fontPath:String = "";

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
        else if (correctPath == null || correctPath == "") {
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
        this.color = new SDL_Color();
        this.rect = new SDL_Rect();
        this.readyToRender = false;

        //////////////////

        this.text = text;
        this.size = size;
        this.fontPath = fontPath;

        this.color.r = 255;
        this.color.g = 255;
        this.color.b = 255;
        this.color.a = 255;

        this.fontPtr = SDL_TTF.TTF_OpenFont(ConstCharPtr.fromString(correctPath), size);
        if (untyped __cpp__("fontPtr == nullptr")) {
            LeafyDebug.log("Failed to load font: " + LfUtils.removeSDDirFromPath(fontPath) + " with size: " + size, ERROR);
            return;
        }

        this.sdlSurfacePtr = SDL_TTF.TTF_RenderText_Blended(this.fontPtr, ConstCharPtr.fromString(text), this.color);
        if (this.sdlSurfacePtr == null) {
            LeafyDebug.log("Failed to create surface for text: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            SDL_TTF.TTF_CloseFont(this.fontPtr);
            return;
        }

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, this.sdlSurfacePtr);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from surface: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            SDL_TTF.TTF_CloseFont(this.fontPtr);
            return;
        }

        SDL_Render.SDL_SetTextureBlendMode(this.sdlTexturePtr, SDL_BLENDMODE_BLEND);

        this.width = this.sdlSurfacePtr.w;
        this.height = this.sdlSurfacePtr.h;
        this.length = this.text.length;

        this.type = ObjectType.TEXT_SPRITE;
        this.name = LfUtils.removeSDDirFromPath(fontPath) + "_" + text;

        // SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);

        LeafyDebug.log("Created text sprite: [" + this.name + "]", INFO);
    }

    /////////////////////////////////////////////////////////////////////

    /**
     * Set the text remaking the texture
     * @param newText The new text
     */
    public function setText(newText:String):Void {
        if (newText == null || newText == "") {
            LeafyDebug.log("New text cannot be null or empty", ERROR);
            return;
        }

        this.readyToRender = false;

        this.sdlSurfacePtr = SDL_TTF.TTF_RenderText_Blended(this.fontPtr, ConstCharPtr.fromString(newText), this.color);
        if (this.sdlSurfacePtr == null) {
            LeafyDebug.log("Failed to create surface for new text: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            return;
        }

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, this.sdlSurfacePtr);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from new surface: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            return;
        }

        SDL_Render.SDL_SetTextureBlendMode(this.sdlTexturePtr, SDL_BLENDMODE_BLEND);

        this.width = this.sdlSurfacePtr.w;
        this.height = this.sdlSurfacePtr.h;
        this.text = newText;

        this.length = this.text.length;

        this.readyToRender = true;

        // SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
    }

    /**
     *  Set the text color, remaking the texture
     * @param newColor The new color
     */

    public function setTextColor(newColor:Array<UInt8>) {
        if (this.color == null) {
            LeafyDebug.log("Text color is null, cannot update text color", ERROR);
            return;
        }

        this.readyToRender = false;

        this.color.r = newColor[0];
        this.color.g = newColor[1];
        this.color.b = newColor[2];
        this.color.a = newColor[3];

        this.sdlSurfacePtr = SDL_TTF.TTF_RenderText_Blended(this.fontPtr, ConstCharPtr.fromString(this.text), this.color);
        if (this.sdlSurfacePtr == null) {
            LeafyDebug.log("Failed to create surface for new text: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            return;
        }

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, this.sdlSurfacePtr);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from new surface: " + SDL_TTF.TTF_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            return;
        }

        SDL_Render.SDL_SetTextureBlendMode(this.sdlTexturePtr, SDL_BLENDMODE_BLEND);

        this.readyToRender = true;

        // SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
    }

    ////////////////////////////////////////////////

    /**
     * Render the text
     */
    override public function render():Void {
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Text texture is null, cannot render text", ERROR);
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

        if (this.alpha < 0) {
            this.alpha = 0;
        }
        else if (this.alpha > 1) {
            this.alpha = 1;
        }

        SDL_Render.SDL_SetTextureAlphaMod(this.sdlTexturePtr, Std.int(this.alpha * 255));
        SDL_Render.SDL_RenderCopyEx(LfWindow.currentRenderer, this.sdlTexturePtr, null, rect, this.angle, null, SDL_FLIP_NONE);
    }

    /**
     * Destroy the text
     */
    override public function destroy():Void {
        if (this.sdlTexturePtr != null) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
        }
        LeafyDebug.log("text destroyed: " + this.name, INFO);
    }
}
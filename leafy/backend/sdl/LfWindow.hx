// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend.sdl;

import wut.coreinit.Debug;
import Std;

import sdl2.SDL_Error;
import sdl2.SDL;
import sdl2.SDL_Video;
import sdl2.SDL_Video.SDL_WindowFlags;
import sdl2.SDL_Render;

/**
 * Enum that defines the window types
 */
enum LfWindowType {
    DRC;
    TV;
    UNIQUE;
}

/**
 * Class that handles the SDL window
 * 
 * @: Slushi
 */
class LfWindow {

    private static var _drcResolution = {
        x: 1280,
        y: 720
    }

    private static var _tvResolution = {
        x: 1920,
        y: 1080
    }

    private static var _drcWindow:Ptr<SDL_Window> = untyped __cpp__("nullptr");
    private static var _tvWindow:Ptr<SDL_Window> = untyped __cpp__("nullptr");
    private static var _mainWindow:Ptr<SDL_Window> = untyped __cpp__("nullptr");

    public static var _drcRenderer:Ptr<SDL_Renderer> = untyped __cpp__("nullptr");
    public static var _tvRenderer:Ptr<SDL_Renderer> = untyped __cpp__("nullptr");
    public static var _mainRenderer:Ptr<SDL_Renderer> = untyped __cpp__("nullptr");

    private static var _currentWindow:Ptr<SDL_Window> = untyped __cpp__("nullptr");
    public static var currentRenderer:Ptr<SDL_Renderer> = untyped __cpp__("nullptr");

    public static function initEngineWindows(type:LfWindowType):Void {
        if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO) < 0) {
            LeafyDebug.criticalError("SDL_Init failed: " + SDL_Error.SDL_GetError().toString());
            return;
        }

        /*
         * Slushi note:
         * Without "SDL_RENDERER_PRESENTVSYNC" the engine runs at 300 FPS, when it should be 60 FPS.
         * The engine is not made to run above 60 FPS, and even these are not visible in any
         * case due to hardware limitations of the Wii U console.
         * 
         * If this was made for a Nintendo Switch, the dock should be able to deliver more than 60 Hz 
         * so with a compatible TV or monitor so.. maybe they should be visible (or... have a Switch 2?).
         * But... This is a Wii U project, hehe.
         */
        switch(type) {
            case LfWindowType.DRC:
                _drcWindow = SDL_Video.SDL_CreateWindow(ConstCharPtr.fromString("Wii_U_Gamepad_Window"), SDL_Video.SDL_WINDOWPOS_UNDEFINED, SDL_Video.SDL_WINDOWPOS_UNDEFINED, _drcResolution.x, _drcResolution.y, untyped __cpp__("SDL_WINDOW_SHOWN | SDL_WINDOW_WIIU_GAMEPAD_ONLY | SDL_WINDOW_ALLOW_HIGHDPI"));
                _drcRenderer = SDL_Render.SDL_CreateRenderer(_drcWindow, -1, untyped __cpp__("SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC"));
                SDL_Render.SDL_SetRenderDrawBlendMode(_drcRenderer, SDL_BLENDMODE_BLEND);
                SDL_Render.SDL_SetRenderDrawColor(_drcRenderer, 0, 0, 0, 255);
                _currentWindow = _drcWindow;
                currentRenderer = _drcRenderer;
            case LfWindowType.TV:
                _tvWindow = SDL_Video.SDL_CreateWindow(ConstCharPtr.fromString("Wii_U_TV_Window"), SDL_Video.SDL_WINDOWPOS_UNDEFINED, SDL_Video.SDL_WINDOWPOS_UNDEFINED, _tvResolution.x, _tvResolution.y, untyped __cpp__("SDL_WINDOW_SHOWN | SDL_WINDOW_WIIU_TV_ONLY"));
                _tvRenderer = SDL_Render.SDL_CreateRenderer(_tvWindow, -1, untyped __cpp__("SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC"));
                SDL_Render.SDL_SetRenderDrawBlendMode(_tvRenderer, SDL_BLENDMODE_BLEND);
                SDL_Render.SDL_SetRenderDrawColor(_tvRenderer, 0, 0, 0, 255);
                _currentWindow = _tvWindow;
                currentRenderer = _tvRenderer;
            case LfWindowType.UNIQUE:
                _mainWindow = SDL_Video.SDL_CreateWindow(ConstCharPtr.fromString("Wii_U_Main_Window"), SDL_Video.SDL_WINDOWPOS_UNDEFINED, SDL_Video.SDL_WINDOWPOS_UNDEFINED, _drcResolution.x, _drcResolution.y, untyped __cpp__("SDL_WINDOW_SHOWN | SDL_WINDOW_ALLOW_HIGHDPI"));
                _mainRenderer = SDL_Render.SDL_CreateRenderer(_mainWindow, -1, untyped __cpp__("SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC"));
                SDL_Render.SDL_SetRenderDrawBlendMode(_mainRenderer, SDL_BLENDMODE_BLEND);
                SDL_Render.SDL_SetRenderDrawColor(_mainRenderer, 0, 0, 0, 255);
                _currentWindow = _mainWindow;
                currentRenderer = _mainRenderer;
        }

        Leafy.screenWidth = getScreenWidth();
        Leafy.screenHeight = getScreenHeight();

        LeafyDebug.log("Windows and renderers initialized in " + Std.string(type) + " mode (" + Std.string(getScreenWidth()) + "x" + Std.string(getScreenHeight()) + ")", INFO);
    }

    /**
     * Closes the SDL windows and renderers
     */
    public static function closeEngineWindows():Void {
        SDL_Video.SDL_DestroyWindow(_currentWindow);
        SDL_Video.SDL_VideoQuit();
        SDL_Render.SDL_DestroyRenderer(currentRenderer);

        LeafyDebug.log("Windows and renderers destroyed", DEBUG);
    }

    /**
     * Returns the screen width
     * @return Int
     */
    public static function getScreenWidth():Int {
        var width:Int = 0;
        var height:Int = 0;
        SDL_Render.SDL_GetRendererOutputSize(currentRenderer, Syntax.toPointer(width), Syntax.toPointer(height));
        
        if (width == 0) {
            LeafyDebug.log("Failed to get screen width: " + SDL_Error.SDL_GetError().toString(), ERROR);
        }

        return width;
    }

    /**
     * Returns the screen height
     * @return Int
     */
    public static function getScreenHeight():Int {
        var width:Int = 0;
        var height:Int = 0;
        SDL_Render.SDL_GetRendererOutputSize(currentRenderer, Syntax.toPointer(width), Syntax.toPointer(height));

        if (height == 0) {
            LeafyDebug.log("Failed to get screen height: " + SDL_Error.SDL_GetError().toString(), ERROR);
        }

        return height;
    }
}
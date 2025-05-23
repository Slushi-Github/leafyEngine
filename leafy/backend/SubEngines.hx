// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import sdl2.SDL_TTF;
import sdl2.SDL_Image;
import sdl2.SDL_Error;
import sdl2.SDL;

import leafy.backend.sdl.LfWindow;
import leafy.backend.internal.LfAudioManager;

/**
 * A class for initializing the SDL libraries
 * 
 * Author: Slushi
 */
class SubEngines {
    /**
     * Initialize the SDL libraries
     */
    public static function startSDL():Void {
        LeafyDebug.log("Initializing SDL", INFO);
        LfWindow.initEngineWindows(LfEngine.windowMode);
        startSDLImage();
        startSDLTTF();
        startSDLAudio();
        LeafyDebug.log("SDL initialized", INFO);
    }

    private static function startSDLTTF():Void {
        if (SDL_TTF.TTF_Init() < 0) {
            LeafyDebug.criticalError("Failed to initialize SDL_TTF: " + SDL_TTF.TTF_GetError().toString());
        }
        LeafyDebug.log("SDL_TTF initialized", INFO);
    }

    private static function startSDLImage():Void {
        if (SDL_Image.IMG_Init(IMG_INIT_PNG) < 0) {
            LeafyDebug.criticalError("Failed to initialize SDL_image: " + SDL_Error.SDL_GetError().toString());
        }
        LeafyDebug.log("SDL_Image initialized", INFO);
    }

    private static function startSDLAudio():Void {
        if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
            LeafyDebug.log("Failed to initialize SDL_Audio: " + SDL_Error.SDL_GetError().toString(), ERROR);
            return;
        }

        // Init SDL Audio Engine
        new LfAudioManager();
        LfAudioManager.init();

        LeafyDebug.log("SDL_Audio initialized", INFO);
    }

    //////////////////////////////////

    /**
     * Shutdown the SDL libraries
     */
    public static function shutdownSDL():Void {
        LfWindow.closeEngineWindows();
        LfAudioManager.shutdown();

        SDL_TTF.TTF_Quit();
        SDL_Image.IMG_Quit();
        SDL.SDL_Quit();

        LeafyDebug.log("SDL shutdown", INFO);
    }
}
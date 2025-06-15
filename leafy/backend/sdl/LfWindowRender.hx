// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend.sdl;

import Std;

import sdl2.SDL_Render;

import leafy.backend.LfStateHandler;
import leafy.states.LfState;
import leafy.backend.sdl.LfWindow;
import leafy.objects.LfObject;


/**
 * A class for rendering the objects on the screen
 * Author: Slushi
 */
class LfWindowRender {
    /**
     * Update the renderers
     */
    public static function updateRenderers():Void {
        switch (LfEngine.windowMode) {
            case LfWindowType.TV:
                SDL_Render.SDL_RenderClear(LfWindow._tvRenderer);
            case LfWindowType.DRC:
                SDL_Render.SDL_RenderClear(LfWindow._drcRenderer);
            case LfWindowType.UNIQUE:
                SDL_Render.SDL_RenderClear(LfWindow._mainRenderer);
        }

        var currentState:LfState = LfStateHandler.getCurrentState();
        if (currentState != null) {
            currentState.render();
        }

        switch (LfEngine.windowMode) {
            case LfWindowType.TV:
                SDL_Render.SDL_RenderPresent(LfWindow._tvRenderer);
            case LfWindowType.DRC:
                SDL_Render.SDL_RenderPresent(LfWindow._drcRenderer);
            case LfWindowType.UNIQUE:
                SDL_Render.SDL_RenderPresent(LfWindow._mainRenderer);
        }
    }
}
// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy;

import sdl2.SDL_Render;

import leafy.audio.LfAudioEngine;
import leafy.backend.sdl.LfWindow;
import leafy.backend.LfTimer;
import leafy.backend.internal.LfGamepadInternal;
import leafy.backend.LfStateHandler;
import leafy.gamepad.LfGamepad;
import leafy.objects.LfSprite;
import leafy.tweens.LfTween;
import leafy.states.LfState;
import leafy.LfBase;

/**
 * Leafy main class
 * 
 * Author: Slushi
 */

class Leafy {
    /**
     * The gamepad used by the state
     */
    public static var wiiuGamepad:LfGamepad = new LfGamepad();

    /**
     * The time since the last update
     */
    public static var deltaTime:Float = 0;

    /**
     * The current state
     */
    public static var currentState:LfState = LfStateHandler.getCurrentState();

    /////////////////////////////

    /**
     * The width of the default screen
     */
    public static var screenWidth:Int = 0;

    /**
     * The height of the default screen
     */
    public static var screenHeight:Int = 0;

    /**
     * The audio engine
     */
    public static var audio:LfAudioEngine;

    /**
     * Is the engine paused
     */
    public static var paused:Bool = false;

    //////////////////////////////////

    /**
     * Switches to a new state
     * @param newState 
     */
    public static function switchState(newState:LfState):Void {
        LfStateHandler.changeState(newState);
    }

    //////////////////////////////////

    public static function update():Void {
        LfTimer.updateDeltaTime();
        deltaTime = LfTimer._deltaTime;

        LfTween.updateTweens(deltaTime);
        LfGamepadInternal.updateDRC();
        LfStateHandler.updateState(deltaTime);
    }
}
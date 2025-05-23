// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import Std;
import haxe.Timer;

import sdl2.SDL_Timer;

/**
 * A class for updating the delta time and handling scheduled timers.
 * 
 * Author: Slushi
 */
class LfTimer {

    private static var _lastTime:UInt32 = SDL_Timer.SDL_GetTicks();

    public static var _deltaTime:Float = 0;
    
    /**
     * Schedule a function to run after a delay (in seconds).
     * 
     * @param delay The delay in seconds.
     * @param callback The function to run.
     */
    public static function after(delay:Float, callback:Void -> Void):Void {
        Timer.delay(callback, Std.int(delay * 1000));
    }

    /**
     * Update the delta time and timers.
     */
    public static function updateDeltaTime():Void {
        var currentTime:UInt32 = SDL_Timer.SDL_GetTicks();
        _deltaTime = (currentTime - _lastTime) / 1000.0;
        _lastTime = currentTime;
    }
}

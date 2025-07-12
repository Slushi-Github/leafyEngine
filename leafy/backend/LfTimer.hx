// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import Std;
import haxe.Timer;

import sdl2.SDL_Timer;

typedef LfTimerObject = {
    var time:Float;
    var callback:Void -> Void;
}

/**
 * A class for updating the delta time and handling scheduled timers.
 * 
 * Author: Slushi
 */
class LfTimer {
    private static var _lastTime:UInt32 = SDL_Timer.SDL_GetTicks();

    public static var _deltaTime:Float = 0;

    private static var _timers:Array<LfTimerObject> = [];
    
    /**
     * Schedule a function to run after a delay (in seconds).
     * 
     * @param delay The delay in seconds.
     * @param callback The function to run.
     */
    public static function after(time:Float, callback:Void -> Void):Void {
        var timer:LfTimerObject = {
            time: time,
            callback: callback
        };
        _timers.push(timer);
    }

    /**
     * Update the delta time.
     */
    public static function updateDeltaTime():Void {
        var currentTime:UInt32 = SDL_Timer.SDL_GetTicks();
        _deltaTime = (currentTime - _lastTime) / 1000.0;
        _lastTime = currentTime;

        // Update all timers
        for (i in 0..._timers.length) {
            var timer = _timers[i];
            timer.time -= _deltaTime;
            if (timer.time <= 0) {
                timer.callback();
                _timers.splice(i, 1); // Remove the timer after it has been executed
            }
        }
    }
}

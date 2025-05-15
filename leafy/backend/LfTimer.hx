// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import sdl2.SDL_Timer;

/**
 * A timer task.
 */
typedef TimerTask = {
    delay:Float, 
    elapsed:Float,
    callback:Void -> Void
};

/**
 * A class for updating the delta time and handling scheduled timers.
 * 
 * Author: Slushi
 */
class LfTimer {
    private static var _lastTime:UInt32 = SDL_Timer.SDL_GetTicks();

    public static var _deltaTime:Float = 0;

    private static var _timers:Array<TimerTask> = [];

    /**
     * Schedule a function to run after a delay (in seconds).
     * 
     * @param delay The delay in seconds.
     * @param callback The function to run.
     */
    public static function after(delay:Float, callback:Void -> Void):TimerTask {

        var timer:TimerTask = {
            delay:delay,
            elapsed:0,
            callback:callback
        };

        _timers.push(timer);

        return timer;
    }

    /**
     * Update the delta time and timers.
     */
    public static function updateDeltaTime():Void {
        var currentTime:UInt32 = SDL_Timer.SDL_GetTicks();
        _deltaTime = (currentTime - _lastTime) / 1000.0;
        _lastTime = currentTime;

        for (timer in _timers) {
            if (timer == null) {
                continue;
            }

            timer.elapsed += _deltaTime;
            if (timer.elapsed >= timer.delay) {
                timer.callback();
            }
        }
    }

    public static function remove(timer:TimerTask):Void {
        untyped __cpp__("
for (size_t i = 0; i < _timers->size(); i++) {
    auto obj = _timers->at(i);
    if (obj == timer) {
        _timers->erase(_timers->begin() + i);
        return;
    }
}
        ");
    }
}

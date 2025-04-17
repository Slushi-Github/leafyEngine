package leafy.backend;

import sdl2.SDL_Timer;

/**
 * A timer task.
 */
typedef TimerTask = {
    delay:Float, 
    elapsed:Float,
    callback:() -> Void
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
     * Update the delta time and timers.
     */
    public static function updateDeltaTime():Void {
        var currentTime:UInt32 = SDL_Timer.SDL_GetTicks();
        _deltaTime = (currentTime - _lastTime) / 1000.0;
        _lastTime = currentTime;

        for (i in _timers.length - 1...-1) {
            var timer = _timers[i];
            timer.elapsed += _deltaTime;
            if (timer.elapsed >= timer.delay) {
                timer.callback();
                _timers.splice(i, 1);
            }
        }
    }

    /**
     * Schedule a function to run after a delay (in seconds).
     * 
     * @param delay The delay in seconds.
     * @param callback The function to run.
     */
    public static function after(delay:Float, callback:() -> Void):Void {
        _timers.push({
            delay: delay,
            elapsed: 0,
            callback: callback
        });
    }
}

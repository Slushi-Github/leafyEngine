package leafy;

import leafy.audio.LfAudioManager;
import leafy.backend.sdl.LfWindow;
import leafy.backend.LfTimer;
import leafy.backend.LfGamepadInternal;
import leafy.backend.LfStateHandler;
import leafy.gamepad.LfGamepad;
import leafy.objects.LfSprite;
import leafy.tweens.LfTween;
import leafy.states.LfState;

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

    /**
     * The main camera
     */
    // public static var camera:LfCamera = new LfCamera();

    /**
     * The list of cameras
     */
    // public static var cameras:Array<LfCamera> = new Array<LfCamera>();

    /////////////////////////////

    /**
     * The width of the screen
     */
    public static var screenWidth:Int = 0;

    /**
     * The height of the screen
     */
    public static var screenHeight:Int = 0;

    /**
     * LFE Audio Manager
     */
    public static var audioManager:LfAudioManager;

    //////////////////////////////////
    //////////////////////////////////

    public static function update():Void {
        LfTimer.updateDeltaTime();
        deltaTime = LfTimer._deltaTime;

        screenWidth = LfWindow.getScreenWidth();
        screenHeight = LfWindow.getScreenHeight();

        LfAudioManager.update();

        LfTween.updateTweens(deltaTime);
        LfGamepadInternal.updateDRC();
        LfStateHandler.updateState(deltaTime);
    }
}
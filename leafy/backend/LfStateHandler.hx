package leafy.backend;

import leafy.backend.LfGamepadInternal;

import leafy.states.LfState;
import leafy.tweens.LfTween;

/**
 * Leafy state handler, used to switch between states and manage the current state
 * 
 * Author: Slushi
 */
class LfStateHandler {
    private static var currentState:LfState;

    /**
     * Returns the current state
     * @return LfState The current state
     */
    public static function getCurrentState():LfState {
        return currentState;
    }

    /**
     * Initializes the first state in the engine initialization
     * @param newState The initial state
     */
    public static function initFirstState(newState:LfState):Void {
        currentState = newState;
        currentState.create();
    }

    /**
     * Destroys the current state
     */
    public static function destroyCurrentState():Void {
        if (currentState != null) {
            LfTween.clearTweens();
            currentState.destroy();
            currentState = null;
        }
    }

    /**
     * Changes the current state to the new state
     * @param newState The new state
     */
    public static function changeState(newState:LfState):Void {
        LfTween.clearTweens();
        if (currentState != null) {
            currentState.destroy();
        }
        currentState = newState;
        currentState.create();
    }

    /**
     * Updates the current state
     * @param elapsed ...
     */
    public static function updateState(elapsed:Float):Void {
        if (currentState != null) {
            currentState.update(elapsed);
        }
    }
}
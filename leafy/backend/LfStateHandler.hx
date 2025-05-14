// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import Std;
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
        LfTween.clearTweens();
        if (currentState != null) {
            currentState.destroy();
            currentState = null;
            Leafy.currentState = null;
        }
    }

    /**
     * Changes the current state to the new state
     * @param newState The new state
     */
    public static function changeState(newState:LfState):Void {
        LeafyDebug.log("Changing state...", INFO);
        destroyCurrentState();
        currentState = newState;
        Leafy.currentState = currentState;
        currentState.create();
        LeafyDebug.log("State changed!", INFO);
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
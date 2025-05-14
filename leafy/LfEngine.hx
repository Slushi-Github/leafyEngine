// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy;

import Std;

import wut.whb.Proc;
import wut.whb.Log_udp;
import wut.whb.Crash;

import leafy.states.LfState;
import leafy.backend.SubEngines;
import leafy.backend.sdl.LfWindowRender;
import leafy.backend.sdl.LfWindow;
import leafy.filesystem.LfSystemPaths;
import leafy.backend.LeafyDebug;
import leafy.backend.LfStateHandler;
import leafy.backend.LfGamepadInternal;
import leafy.audio.LfAudioManager;

/**
 * Leafy Engine Main class:
 * Initialize the engine, and start the main loop, then shutdown the engine when the main loop ends
 * 
 * Author: Slushi
 */
class LfEngine {

    /**
     * The current version of the engine
     */
    public static var version:String = "1.2.0";

    /**
     * Function to be called when the engine exits
     */
    public static var onEngineExit:Void->Void;

    /**
     * The window mode of the engine
     */
    public static var windowMode:LfWindowType;

    /**
     * Is the engine running
     */
    private static var _isRunning:Bool = false;

    /**
     * The initial state
     */
    public static var initState:LfState;

    /**
     * Initialize the engine, and start the state
     * @param state The initial state
     */
    public static function initEngine(gamePath:String, renderMode:LfWindowType = LfWindowType.DRC, state:LfState):Void {
        Log_udp.WHBLogUdpInit();
        Proc.WHBProcInit();
        Crash.WHBInitCrashHandler();

        if (renderMode == null) {
            Sys.println("[Leafy Engine initial state - no logger started -> WARNING] Render mode cannot be null, defaulting to DRC mode");
            renderMode = LfWindowType.DRC;
        }

        if (gamePath == null) {
            Sys.println("[Leafy Engine initial state - no logger started -> WARNING] Game path cannot be null, defaulting to LEAFY_GAME");
            gamePath = "LEAFY_GAME";
        }

        windowMode = renderMode;

        // initialize the engine systems
        LfSystemPaths.initFSSystem();
        LeafyDebug.initLogger();
        LeafyDebug.initCrashHandlers();
        SubEngines.startSDL();
        Leafy.audioManager = new LfAudioManager();
        LfAudioManager.init();

        // Set the engine main path
        LfSystemPaths.setEngineMainPath(gamePath);

        // Set and initialize the initial state
        LfStateHandler.initFirstState(state);
        Leafy.currentState = state;

        // Initialize the Wii U Gamepad
        LfGamepadInternal.initDRC();

        LeafyDebug.log("Leafy Engine " + Std.string(version) + " initialized", INFO);

        _isRunning = Proc.WHBProcIsRunning();
        // Start the main loop, the engine will shutdown when the main loop ends
        while(_isRunning) {
            _isRunning = Proc.WHBProcIsRunning();

            LfWindowRender.updateRenderers();
            LeafyDebug.updateLogTime();
            Leafy.update();
        };

        // Shutdown the engine
        if (onEngineExit != null) {
            onEngineExit();
        }

        LfStateHandler.destroyCurrentState();
        SubEngines.shutdownSDL();
        LfSystemPaths.deinitFSSystem();
        Log_udp.WHBLogUdpDeinit();
        Proc.WHBProcShutdown();
    }
}
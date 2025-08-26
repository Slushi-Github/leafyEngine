// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy;

import Std;

import cxx.std.Exception;
import haxe.Exception as HaxeException;

import wut.whb.Proc;
import wut.whb.Log_udp;
import wut.whb.Crash;
import wut.coreinit.Debug;

import leafy.states.LfState;
import leafy.backend.SubEngines;
import leafy.backend.sdl.LfWindowRender;
import leafy.backend.sdl.LfWindow;
import leafy.filesystem.LfSystemPaths;
import leafy.backend.LeafyDebug;
import leafy.backend.LfStateHandler;
import leafy.backend.internal.LfGamepadInternal;

/**
 * configuration apart for Leafy Engine
 * 
 * INCOMPLETE!!! This is just an idea...
 */
typedef EngineOtherConfig = {
    useSDLMixerAsDefault:Bool
}

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
    public static final VERSION:String = "1.5.6";

    /**
     * Function to be called when the engine exits
     */
    public static var onEngineExit:Void->Void;

    /**
     * Function to be called when the engine is initialized
     */
    public static var onEngineInitFinished:Void->Void;

    /**
     * The window mode of the engine
     */
    public static var windowMode:LfRenderType = LfRenderType.DRC;

    /**
     * The initial state
     */
    public static var initState:LfState;

    /**
     * Is the engine running
     */
    private static var _isRunning:Bool = false;

    /**
     * The function to be called when the engine crashes, can be overridden
     */
    private static var onEngineCrash:String->Void = LeafyDebug.hxCrashHandler;

    /**
     * Initialize the engine, and start the state
     * 
     * @param gamePath The path to the game folder ("LEAFY_GAME" by default)
     * @param renderMode The render mode of the engine
     * @param state The initial state
     * 
     * Example:
     * ```
     * LfEngine.initEngine("LEAFY_GAME", LfRenderType.DRC, new MyGameState());
     * ```
     */
    public static function initEngine(gamePath:String, renderMode:LfRenderType = LfRenderType.DRC, state:LfState):Void {
        #if !disableHxCrashHandler
        try{
            try {
        #end
                Proc.WHBProcInit();
                Log_udp.WHBLogUdpInit();

                #if useWUTCrashHandler // Not recommended for now, it really doesn't work hehe
                    /**
                     * Initialize the custom Wii U crash handler
                     */
                    LeafyDebug.initWUTCrashHandler();
                #else
                    Crash.WHBInitCrashHandler(); // This really works?
                #end

                Sys.println("[Leafy Engine initial state - no logger started] Starting Leafy Engine [" + VERSION + "]");

                if (renderMode == null) {
                    Sys.println("[Leafy Engine initial state - no logger started -> WARNING] Render mode cannot be null, defaulting to DRC mode");
                    renderMode = LfRenderType.DRC;
                }

                if (gamePath == null || gamePath == "") {
                    Sys.println("[Leafy Engine initial state - no logger started -> WARNING] Game path cannot be null, defaulting to \"LEAFY_GAME\"");
                    gamePath = "LEAFY_GAME";
                }

                windowMode = renderMode;

                // initialize the engine systems
                LfSystemPaths.initFSSystem();
                LeafyDebug.initLogger();
                SubEngines.startSDL();

                // Set the engine main path
                LfSystemPaths.setEngineMainPath(gamePath);

                // Initialize the Wii U Gamepad
                LfGamepadInternal.initDRC();

                #if disableHxCrashHandler
                LeafyDebug.log("Haxe crash handler is disabled in this build, crashes will not be logged!", WARNING);
                #end

                #if useWUTCrashHandler
                LeafyDebug.log("CafeOS crash handler is enabled in this build, crashes will be managed by the CafeOS exception handler!", WARNING);
                #end

                #if debug
                LeafyDebug.log("Haxe debug mode is enabled in this build, lag may occur when printing many more logs!", WARNING);
                #end

                LeafyDebug.log("Leafy Engine [" + VERSION + "] initialized", INFO);

                // Call the onEngineInitFinished function
                if (untyped __cpp__("onEngineInitFinished != NULL")) {
                    onEngineInitFinished();
                }

                LeafyDebug.printToLogFileOnly("-- Starting first state... -------------------------\n");
                
                // Set and initialize the initial state
                if (state == null) {
                    LeafyDebug.criticalError("initial state cannot be null.");
                }
                LfStateHandler.initFirstState(state);
                initState = state;
                Leafy.currentState = state;

                ///////////////////////////////////////////

                _isRunning = Proc.WHBProcIsRunning();
                // Start the main loop, the engine will shutdown when the main loop ends
                while(_isRunning) {
                    _isRunning = Proc.WHBProcIsRunning();
                    LfWindowRender.updateRenderers();
                    LeafyDebug.updateLogTime();
                    Leafy.update();

                    if (!_isRunning) {
                        Leafy.paused = true;
                    }
                };

                // Shutdown the engine //////////
                // Call the onEngineExit function
                if (untyped __cpp__("onEngineExit != NULL")) {
                    onEngineExit();
                }

                LeafyDebug.printToLogFileOnly("-- Shutting down Leafy Engine... -------------------------\n");

                LfStateHandler.destroyCurrentState();
                SubEngines.shutdownSDL();
                LfSystemPaths.deinitFSSystem();
                Log_udp.WHBLogUdpDeinit();

                Debug.OSReportInfo(ConstCharPtr.fromString("[Leafy Engine final state - no logger started] Leafy Engine [" + VERSION + "] shut down successfully! Back to the Wii U menu..."));
                Proc.WHBProcShutdown();
        #if !disableHxCrashHandler
            }
            catch (e:HaxeException) {
                onEngineCrash(e.message);
            }
        }
        catch (e:Exception) {
            onEngineCrash(e.what().toString());
        }
        #end
    }

    /**
     * Sets a custom crash handler for the engine.
     * @param newHandler The function to be called when the engine crashes
     */
    public static function setCustomCrashHandler(newHandler:String->Void):Void {
        if (newHandler != null) {
            onEngineCrash = newHandler;
        }
    }

}
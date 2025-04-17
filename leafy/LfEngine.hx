package leafy;

import leafy.audio.LfAudioManager;
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

/**
 * Leafy Engine Main class:
 * Initialize the engine, and start the main loop, then shutdown the engine when the main loop ends
 * 
 * Author: Slushi
 */
class LfEngine {
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
    public static function initEngine(renderMode:LfWindowType = LfWindowType.DRC, state:LfState):Void {
        Log_udp.WHBLogUdpInit();
        Proc.WHBProcInit();
        Crash.WHBInitCrashHandler();

        if (renderMode == null) {
            Sys.println("[Leafy Engine initial state - no logger started -> WARNING] Render mode cannot be null, defaulting to DRC mode");
            renderMode = LfWindowType.DRC;
        }

        windowMode = renderMode;

        // initialize the engine systems
        LfSystemPaths.initFSSystem();
        LeafyDebug.initLogger();
        SubEngines.startSDL();
        Leafy.audioManager = new LfAudioManager();
        LfAudioManager.init();

        // Set and initialize the initial state
        LfStateHandler.initFirstState(state);
        Leafy.currentState = state;

        // Initialize the Wii U Gamepad
        LfGamepadInternal.initDRC();

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
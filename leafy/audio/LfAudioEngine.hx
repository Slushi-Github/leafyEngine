// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.audio;

import leafy.backend.internal.LfAudioManager;

/**
 * Audio engine, handles audio playback
 * 
 * Author: Slushi
 */
class LfAudioEngine {

    public var currentAudio:LfAudio;

    /**
     * Plays an audio file
     * @param path The path to the audio file
     * @param loop Whether the audio should loop
     */
    public function play(path:String, loop:Bool = false):LfAudio {
        currentAudio = LfAudioManager.instance.play(path, loop);
        return currentAudio;
    }

    /**
     * Pauses the currently playing audio
     */
    public function pause():Void {
        LfAudioManager.instance.pause();
    }

    /**
     * Resumes the currently paused audio
     */
    public function resume():Void {
        LfAudioManager.instance.resume();
    }

    /**
     * Stops the currently playing audio
     */
    public function stop():Void {
        LfAudioManager.instance.stop();
    }

    /**
     * Toggles the loop state of the currently playing audio
     */
    public function toggleLoop():Void {
        LfAudioManager.toggleLoop();
    }

    /**
     * Gets the current audio time
     * @return Float
     */
    public function getCurrentTime():Float {
        return LfAudioManager.getCurrentTime();
    }

    /**
     * Gets the current audio duration
     * @return Float
     */
    public function getDuration():Float {
        return LfAudioManager.getDuration();
    }
}
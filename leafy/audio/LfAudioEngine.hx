// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.audio;

import leafy.backend.internal.LfAudioManagerInternal;

/**
 * Audio engine, handles audio playback
 * 
 * Author: Slushi
 */
class LfAudioEngine {

    /**
     * Is the audio currently playing
     */
    public var playing:Bool = false;

    /**
     * Is the audio currently paused
     */
    public var paused:Bool = true;

    /**
     * Plays an audio file
     * @param path The path to the audio file
     * @param loop Whether the audio should loop
     */
    public function play(path:String, loop:Bool = false):Void {
        LfAudioManagerInternal.instance.play(path, loop);
    }

    /**
     * Pauses the currently playing audio
     */
    public function pause():Void {
        LfAudioManagerInternal.instance.pause();
    }

    /**
     * Resumes the currently paused audio
     */
    public function resume():Void {
        LfAudioManagerInternal.instance.resume();
    }

    /**
     * Stops the currently playing audio
     */
    public function stop():Void {
        LfAudioManagerInternal.instance.stop();
    }

    /**
     * Toggles the loop state of the currently playing audio
     */
    public function toggleLoop():Void {
        LfAudioManagerInternal.toggleLoop();
    }

    /**
     * Gets the current audio time
     * @return Float
     */
    public function getCurrentTime():Float {
        return LfAudioManagerInternal.getCurrentTime();
    }

    /**
     * Gets the current audio duration
     * @return Float
     */
    public function getDuration():Float {
        return LfAudioManagerInternal.getDuration();
    }

    /**
     * Sets the current audio time
     * @param time The time to set
     */
    public function setCurrentTime(time:Float):Void {
        LfAudioManagerInternal.setCurrentTime(time);
    }
}
// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend.internal;

import wut.coreinit.Debug;
import Std;

import sdl2.SDL_Audio;
import sdl2.SDL_Audio.SDL_AudioSpec;
import sdl2.SDL_Audio.SDL_AudioDeviceID;
import sdl2.SDL_Stdinc;
import sdl2.SDL;
import sdl2.SDL_Error;

import vorbis.VorbisFile;
import vorbis.VorbisFile.OggVorbis_File;
import vorbis.Codec.Vorbis_info;

import leafy.audio.LfAudio;

/**
 * Audio manager, manages music playback
 * 
 * (it took me more than 7 hours to make this work...)
 * And, I just can't not make it possible to play more than one audio 
 * at a time, so only one audio can be used.
 * 
 * Is recomended to use the `LfAudioEngine` class instead of this one.
 * 
 * Author: Slushi
 */
class LfAudioManagerInternal {
    /**
     * Class instance
     */
    public static var instance:LfAudioManagerInternal;

    /**
     * Audio specs
     */
    private static var audioSpec:SDL_AudioSpec;

    /**
     * Audio device
     */
    private static var audioDevice:SDL_AudioDeviceID = 0;

    /**
     * Desired audio specs
     */
    private static var currentDesiredSpec:SDL_AudioSpec;

    /**
     * Current audio
     */
    private static var currentFile:Ptr<OggVorbis_File> = untyped __cpp__("nullptr");

    /**
     * OGG info
     */
    private static var vorbisInfo:Ptr<Vorbis_info>;

    /**
     * Current audio object
     */
    public static var currentAudio:LfAudio;

    /**
     * Current audio time
     */
    private static var currentTime:Float = 0.0;

    /**
     * Current audio duration
     */
    private static var duration:Float = 0.0;

    /**
     * Is audio currently playing
     */
    private static var playing:Bool = false;

    /**
     * Is audio currently paused
     */
    private static var paused:Bool = false;

    /**
     * Constructor
     */
    public function new() {
        if (instance == null) {
            instance = this;
        }
    }

    /**
     * Updates the audio manager state
     */
    public static function update():Void {
        if (untyped __cpp__("{0} != NULL", currentAudio)) {
            currentAudio.currentTime = currentTime;
            playing = currentAudio.playing;
            paused = currentAudio.paused;

            Leafy.audio.playing = playing;
            Leafy.audio.paused = paused;
        }
    }

    /**
     * Callback function for SDL_Audio
     * @param userdata ...
     * @param stream ...
     * @param len ...
     */
    private static function audioCallback(userdata:VoidPtr, stream:Ptr<UInt8>, len:Int):Void {
        if (paused || untyped __cpp__("{0} == nullptr", stream) || len <= 0 || untyped __cpp__("{0} == nullptr", currentFile)) {
            SDL_Stdinc.SDL_memset(stream, 0, len);
            return;
        }
    
        var bitstream:Int = 0;
        var bytesRead:Int = 0;
        var totalBytesToRead = len;
    
        while (bytesRead < totalBytesToRead) {
            var remainingLen = totalBytesToRead - bytesRead;
            var ret = VorbisFile.ov_read(
                currentFile,
                untyped __cpp__("((char*){0}) + {1}", stream, bytesRead),
                remainingLen,
                1,
                2,
                1,
                Syntax.toPointer(bitstream)
            );
    
            if (ret == 0) {
                if (currentAudio != null && currentAudio.loop) {
                    VorbisFile.ov_time_seek(currentFile, 0.0);
                    continue;
                } else {
                    playing = false;
                    if (bytesRead < totalBytesToRead) {
                        SDL_Stdinc.SDL_memset(
                            untyped __cpp__("((char*){0}) + {1}", stream, bytesRead),
                            0,
                            totalBytesToRead - bytesRead
                        );
                    }
                    break;
                }
            } else if (ret < 0) {
                LeafyDebug.log("Vorbis read error: " + ret, ERROR);
                playing = false;
                SDL_Stdinc.SDL_memset(stream, 0, totalBytesToRead);
                break;
            }
    
            bytesRead += ret;
        }
    
        if (playing) {
            currentTime = VorbisFile.ov_time_tell(currentFile);
        }
    }
    

    /**
     * Initialize the audio device with the desired specs
     * @param desiredFreq The desired sample rate (By default 44100)
     * @param desiredChannels The desired number of channels (By default 2)
     * @return Bool True if the audio device was successfully initialized
     */
    public static function init(desiredFreq:Int = 44100, desiredChannels:Int = 2):Bool {
        if (audioDevice > 0) {
            if (audioSpec.freq == desiredFreq && audioSpec.channels == desiredChannels) {
                LeafyDebug.log("Audio device already initialized with matching specs.", INFO);
                return true;
            } else {
                LeafyDebug.log("Audio device specs mismatch. Re-opening device...", INFO);
                shutdown();
            }
        }

        LeafyDebug.log("Initializing audio device (Freq: " + desiredFreq + ", Ch: " + desiredChannels +")...", INFO);

        var desiredSpec:SDL_AudioSpec = new SDL_AudioSpec();
        SDL_Stdinc.SDL_zero(untyped __cpp__("{0}", desiredSpec));

        desiredSpec.freq = desiredFreq;
        desiredSpec.format = SDL_Audio.AUDIO_S16MSB;
        desiredSpec.channels = desiredChannels;
        desiredSpec.samples = 4096;
        desiredSpec.callback = audioCallback;
        desiredSpec.userdata = null;

        currentDesiredSpec = desiredSpec;

        var obtainedSpec:SDL_AudioSpec = new SDL_AudioSpec();

        audioDevice = SDL_Audio.SDL_OpenAudioDevice(
            untyped __cpp__("nullptr"), 0,
            Syntax.toPointer(desiredSpec), Syntax.toPointer(obtainedSpec),
            0
        );

        if (audioDevice <= 0) {
            LeafyDebug.log("Failed to open audio device: " + SDL_Error.SDL_GetError().toString(), INFO);
            audioDevice = 0;
            return false;
        }

        audioSpec = obtainedSpec;

        if (audioSpec.freq != desiredSpec.freq || audioSpec.channels != desiredSpec.channels) {
            LeafyDebug.log("Warning: SDL provided different specs than requested! Freq: " + Std.string(audioSpec.freq) + " (req: " + Std.string(desiredSpec.freq) + "), Channels: " + Std.string(audioSpec.channels) + " (req: " + Std.string(desiredSpec.channels) + ")", WARNING);
        }

        SDL_Audio.SDL_PauseAudioDevice(audioDevice, 0);
        LeafyDebug.log("Audio device initialized and unpaused!", INFO);
        return true;
    }

    /**
     * Load an OGG file into the audio device, re-opening the device if necessary
     * @param audio The audio to load
     * @return Bool True if the audio was successfully loaded
     */
    public static function loadOgg(audio:LfAudio):Bool {
        if (untyped __cpp__("{0} == nullptr", audio) || untyped __cpp__("{0} == nullptr", audio.file)) {
            LeafyDebug.log("Failed to load audio, LfAudio or its file is null", ERROR);
            return false;
        }

        var fileInfo:Ptr<Vorbis_info> = VorbisFile.ov_info(audio.file, -1);
        if (untyped __cpp__("{0} == nullptr", fileInfo)) {
            LeafyDebug.log("Failed to get Ogg Vorbis info for the file.", ERROR);
            return false;
        }

        if (fileInfo == null) {
            LeafyDebug.log("Failed to get Ogg Vorbis info for the file.", ERROR);
            return false;
        }

        LeafyDebug.log("Ogg File Info: Rate=" + fileInfo.rate + ", Channels=" + fileInfo.channels, DEBUG);

        var needsReopen:Bool = false;
        if (audioDevice <= 0) {
            needsReopen = true;
        } else {
            if (fileInfo.rate != audioSpec.freq || fileInfo.channels != audioSpec.channels) {
                LeafyDebug.log("Ogg spec differs from current audio device spec. Re-opening device.", INFO);
                needsReopen = true;
            }
        }

        if (needsReopen) {
            stopStatic();
            shutdown();

            if (!init(fileInfo.rate, fileInfo.channels)) {
                LeafyDebug.log("Failed to re-open audio device with new specs. Cannot play audio.", ERROR);
                return false;
            }
        }

        if (playing || paused) {
            stopStatic();
            playing = false;
            paused = true;
            if (untyped __cpp__("{0} == nullptr", currentFile)) {
                return false;
            }
            currentAudio = null;
            currentTime = 0.0;
        }

        currentFile = audio.file;
        currentAudio = audio;
        vorbisInfo = fileInfo;
        duration = VorbisFile.ov_time_total(currentFile, -1);
        currentAudio.duration = duration;
        currentTime = 0;
        playing = true;
        paused = false;
        // Leafy.audio.playing = playing;
        // Leafy.audio.paused = paused;

        SDL_Audio.SDL_PauseAudioDevice(audioDevice, 0);

        LeafyDebug.log("Loaded Ogg: Duration=" + duration + "s. Starting playback.", INFO);
        return true;
    }

    /**
     * Stop audio playback
     */
    private static function stopStatic():Void {
        if (audioDevice <= 0) return;

        SDL_Audio.SDL_PauseAudioDevice(audioDevice, 1);

        playing = false;
        paused = true;

        if (untyped __cpp__("{0} != nullptr", currentFile)) {
            VorbisFile.ov_clear(currentFile);
            currentFile = untyped __cpp__("nullptr");
        }

        currentAudio = null;
        vorbisInfo = null;
        currentTime = 0.0;
        duration = 0.0;
        LeafyDebug.log("Audio stopped and cleared.", INFO);
    }

    /**
     * Start audio playback
     * @param audio The audio to play
     * @param loop Whether the audio should loop
     */
    public function play(path:String, loop:Bool):Void {

        if (instance == null) {
            LeafyDebug.log("Audio manager instance is null.", ERROR);
            return;
        }

        var tempAudio:LfAudio = new LfAudio(path, loop);
        if (untyped __cpp__("{0} == nullptr", tempAudio)) {
            LeafyDebug.log("Failed to create LfAudio object.", ERROR);
            return;
        }

        if (audioDevice <= 0) {
            init();
            if (audioDevice <= 0) {
                LeafyDebug.log("Cannot play audio, device initialization failed.", ERROR);
                return;
            }
        }
        var result:Bool = loadOgg(tempAudio);
        if (!result) {
            LeafyDebug.log("Failed to load Ogg file: " + path, ERROR);
            return;
        }
    }

    /**
     * Pause or resume audio playback
     */
    public static function pauseResume():Void {
        if (audioDevice <= 0 || currentAudio == null || !playing) return;

        paused = !paused;
        SDL_Audio.SDL_PauseAudioDevice(audioDevice, paused ? 1 : 0);
        currentAudio.paused = paused;
        // Leafy.audio.paused = paused;
        LeafyDebug.log("Audio " + (paused ? "Paused" : "Resumed"), DEBUG);
    }



    /**
     * Set if the audio should loop
     */
    public static function setLoop(value:Bool):Void {
        if (currentAudio != null) {
            currentAudio.loop = value;
        }
    }

    /**
     * Switch the loop state of the audio
     */
    public static function toggleLoop():Void {
        if (currentAudio != null) {
            currentAudio.loop = !currentAudio.loop;
        }
    }    

    /**
     * Get the current audio time
     * @return Float
     */
    public static function getCurrentTime():Float {
        return currentTime;
    }

    /**
     * Get the current audio duration
     * @return Float
     */
    public static function getDuration():Float {
        if (currentAudio != null) {
            return currentAudio.duration;
        }
        return 0.0;
    }

    /**
     * set the current audio time
     * @param time The time to set
     */
    public static function setCurrentTime(time:Float):Void {
        if (currentAudio != null && currentFile != null) {
            VorbisFile.ov_time_seek(currentFile, time);
            currentTime = time;
        } else {
            LeafyDebug.log("Cannot set current time, no audio is loaded.", DEBUG);
        }
    }
    
    /**
     * Pause audio playback
     */
    public function pause():Void {
        if (audioDevice <= 0 || currentAudio == null || !playing || paused) return;
        paused = true;
        SDL_Audio.SDL_PauseAudioDevice(audioDevice, 1);
        // playing = false;
        // currentAudio.playing = playing;
        currentAudio.paused = paused;
        // Leafy.audio.paused = paused;
        // Leafy.audio.playing = playing;
        LeafyDebug.log("Audio Paused", DEBUG);
    }

    /**
     * Resume audio playback
     */
    public function resume():Void {
        if (audioDevice <= 0 || currentAudio == null || !playing || !paused) return;
        paused = false;
        SDL_Audio.SDL_PauseAudioDevice(audioDevice, 0);
        currentAudio.paused = paused;
        // Leafy.audio.paused = paused;
        LeafyDebug.log("Audio Resumed", DEBUG);
    }

    /**
     * Stop audio playback
     */
    public function stop():Void {
        stopStatic();
    }

    /**
     * Check if audio is currently playing
     * @return Bool
     */
    public static function isPlaying():Bool {
        return playing && !paused;
    }

    /**
     * Check if audio is currently paused
     * @return Bool
     */
    public static function isPaused():Bool {
        return playing && paused;
    }

    /**
     * Shutdown the audio device
     */
    public static function shutdown():Void {
        if (audioDevice > 0) {
            stopStatic();
            SDL_Audio.SDL_CloseAudioDevice(audioDevice);
            audioDevice = 0;
            LeafyDebug.log("Audio device closed.", DEBUG);
        }
    }
}
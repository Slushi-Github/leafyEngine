// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.audio;

import sdl2.SDL_Error;

import vorbis.VorbisFile;
import vorbis.VorbisFile.OggVorbis_File;
import vorbis.Codec.Vorbis_info;

import leafy.filesystem.LfSystemPaths;

/**
 * The LfAudio class, used to play OGG files
 * 
 * Author: Slushi
 */
class LfAudio {
    /**
     * The pointer to the OGG file
     */
    public var file:Ptr<OggVorbis_File>;

    /**
     * The pointer to the OGG info
     */
    public var info:Ptr<Vorbis_info>;

    /**
     * The path to the OGG
     */
    public var path:String;

    /**
     * The current time of the OGG
     */
    public var currentTime:Float = 0;

    /**
     * The duration of the OGG
     */
    public var duration:Float = 0;

    /**
     * Whether the OGG is currently playing
     */
    public var playing:Bool = false;

    /**
     * Whether the OGG is currently paused
     */
    public var paused:Bool = false;

    /**
     * The volume of the OGG
     */
    public var loop:Bool = false;

    // /**
    //  * The fade tween
    //  */
    // private var fadeTween:LfTween;

    /**
     * Creates a new OGG and loads it
     * @param path The path to the OGG
     */
    public function new(path:String, loop:Bool = false) {
        var correctPath:String = LfSystemPaths.getConsolePath() + path;

        if (!LfSystemPaths.exists(correctPath)) {
            LeafyDebug.log("Failed to load OGG [" + path + "]: File not found", ERROR);
            return;
        }

        this.path = path;

        file = new OggVorbis_File();
        // SDL_Stdinc.SDL_zero(currentFile.ref);
        if (VorbisFile.ov_fopen(ConstCharPtr.fromString(correctPath), file) != 0) {
            LeafyDebug.log("Failed to load OGG [" + path + "]: " + SDL_Error.SDL_GetError().toString(), ERROR);
            return;
        }

        info = untyped __cpp__("ov_info(leafy::audio::LfAudio::file, -1)");
        if (info == null) {
            LeafyDebug.log("Failed to get OGG info for [" + path + "]: " + SDL_Error.SDL_GetError().toString(), ERROR);
            return;
        }

        duration = VorbisFile.ov_time_total(file, -1);
        currentTime = 0.0;
        playing = true;
        paused = false;
        this.loop = loop;

        LeafyDebug.log("Loaded OGG: [" + path + "] with duration: " + duration + " seconds" , DEBUG);
        return;
    }

    /**
     * Pauses the OGG
     */
    public function pause():Void {
        paused = true;
    }

    /**
     * Resumes the OGG
     */
    public function resume():Void {
        paused = false;
    }

    /**
     * Stops the OGG
     */
    public function stop():Void {
        paused = false;
        currentTime = 0;
    }

    /**
     * Checks if the OGG is currently playing
     * @return Bool
     */
    public function isPlaying():Bool {
        return playing;
    }

    /**
     * Destroys the OGG and frees memory
     */
    public function destroy():Void {
        if (file != null) VorbisFile.ov_clear(file);
    }
}
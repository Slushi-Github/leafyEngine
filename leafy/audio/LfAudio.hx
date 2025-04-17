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
     * Creates a new OGG and loads it
     * @param path The path to the OGG
     */
    public function new(path:String) {
        var correctPath:String = LfSystemPaths.getConsolePath() + path;

        if (!LfSystemPaths.exists(correctPath)) {
            LeafyDebug.log("Failed to load OGG [" + path + "]: File not found", INFO);
            return;
        }

        this.path = correctPath;

        file = new OggVorbis_File();
        // SDL_Stdinc.SDL_zero(currentFile.ref);
        if (VorbisFile.ov_fopen(ConstCharPtr.fromString(correctPath), file) != 0) {
            LeafyDebug.log("Failed to load OGG [" + path + "]: " + SDL_Error.SDL_GetError().toString(), INFO);
            return;
        }

        info = untyped __cpp__("ov_info(leafy::audio::LfAudio::file, -1)");
        if (info == null) {
            LeafyDebug.log("Failed to get OGG info for [" + path + "]: " + SDL_Error.SDL_GetError().toString(), INFO);
            return;
        }

        duration = VorbisFile.ov_time_total(file, -1);
        currentTime = 0.0;
        playing = true;

        LeafyDebug.log("Loaded OGG: [" + path + "] with duration: " + duration + " seconds" , INFO);
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
     * Destroys the OGG and frees memory
     */
    public function destroy():Void {
        if (file != null) VorbisFile.ov_clear(file);
    }
}

# The audio engine

Leafy Engine uses a audio engine that uses the [Vorbis](https://github.com/Haxe-WiiU/HxU_Vorbis) library and SDL_Audio to play audio OGG files in the engine.

Unfortunately, there is a major limitation in this audio engine, I can't get more than one audio to play at a time without slowing down the sound reproduction or even getting a console crash, so I will only use one audio at a time.

**As a recommendation**, SDL_Audio by default is started to expect audio that is on frequency *``44100``* and has __2__ audio channels. While the audio engine is able to detect if the audio being loaded has any difference in those 2 values, what it will do is reopen the entire audio device, causing there to be a significant lag when that happens. For that reason I recommend to verify if your audio (sound, music) is in the frequency *``44100``* and that it has __2__ audio channels, otherwise you can convert it using some web page or a tool that allows you to do that.

--------

To use it is easy, here is an example:
```haxe
// import the Leafy class
import leafy.Leafy;

// Just reproduce a sound or music
Leafy.audio.play("GAME_PATH/music.ogg", true); // true for looping

// pause a sound or music
Leafy.audio.pause();

// resume a sound or music
Leafy.audio.resume();

// stop a sound or music
Leafy.audio.stop();

// Toggle the loop of a sound or music
Leafy.audio.toggleLoop();

// Check if the audio is playing
var isPlaying:Bool = Leafy.audio.playing;

// Check if the audio is paused
var isPaused:Bool = Leafy.audio.paused;

// get the current time of the audio
var currentTime:Float = Leafy.audio.getCurrentTime();

// get the duration of the audio
var duration:Float = Leafy.audio.getDuration();
```

--------

See [``LfAudioEngine``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/audio/LfAudioEngine.hx)

See [``LfAudio``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/audio/LfAudio.hx)

See [``LfAudioManagerInternal``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/backend/internal/LfAudioManagerInternal.hx)
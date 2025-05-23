# The audio engine

Leafy Engine uses a audio engine that uses the [Vorbis](https://github.com/Haxe-WiiU/HxU_Vorbis) library and SDL_Audio to play audio OGG files in the engine.

Unfortunately, there is a major limitation in this audio engine, I can't get more than one audio to play at a time without slowing down the sound reproduction or even getting a crash, so I will only use one audio at a time.

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

// Get the LfAudio object if is already created
var audioObj:LfAudio = Leafy.audio.currentAudio;

// Or get it as soon as you play the audio
var audioObj:LfAudio = Leafy.audio.play("GAME_PATH/music.ogg", true);

// get the current time of the audio
var currentTime:Float = Leafy.audio.getCurrentTime();

// get the duration of the audio
var duration:Float = Leafy.audio.getDuration();
```

----

See [``LfAudioEngine``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/audio/LfAudioEngine.hx)

See [``LfAudio``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/audio/LfAudio.hx)

See [``LfAudioManagerInternal``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/backend/internal/LfAudioManagerInternal.hx)
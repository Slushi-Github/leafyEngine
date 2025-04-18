<h1 align="center">Leafy Engine</h1>
<h2 align="center">The first 2D game engine for the Wii U made with Haxe!</h2>

![Leafy Engine Logo](https://github.com/Slushi-Github/leafyEngine/blob/main/readme/leafyEngineLogo.png)

Leafy Engine is an engine inspired by [HaxeFlixel](https://haxeflixel.com/) for making 2D games for the Wii U using Haxe, yes, Haxe!

[Leafy Engine Docs](https://slushi-github.github.io/LeafyEngineDocs/)

A normal Leafy Engine code looks like this:

```haxe
package src;

import Std;
import leafy.LfState;
import leafy.objects.LfSprite;
import leafy.Leafy;

class PlayState extends LfState {

    var sprite:LfSprite;

    override public function create():Void {

        // Create a sprite
        sprite = new LfSprite(100, 100);
        sprite.createGraphic(200, 200, [255, 0, 0, 255]);
        sprite.center();
        addObject(sprite);
    }

	// Update the sprite position
    override public function update(delta:Float):Void {
        var moveSpeed:Float = 5;

		if (Leafy.wiiuGamepad.pressed(BUTTON_LEFT)) {
			sprite.x -= Std.int(moveSpeed * delta * 60);
		}
		if (Leafy.wiiuGamepad.pressed(BUTTON_RIGHT)) {
			sprite.x += Std.int(moveSpeed * delta * 60);
		}
		if (Leafy.wiiuGamepad.pressed(BUTTON_UP)) {
			sprite.y -= Std.int(moveSpeed * delta * 60);
		}
		if (Leafy.wiiuGamepad.pressed(BUTTON_DOWN)) {
			sprite.y += Std.int(moveSpeed * delta * 60);
		}
    }
}
```

A code probably similar to one from [HaxeFlixel](https://haxeflixel.com/) right?

## Current status of the engine:
- [x] Wii U Gamepad support (Touchscreen support partially)
- [x] Sprites
- [x] Texts
- [x] buttons (Partially broken)
- [x] Audio support (Only one music at the same time)
- [x] States 
- [x] Collisions
- [x] Sprites basic physics 
- [x] Tweens and easing functions
- [x] JSONs file support (Only decoding)
- [x] Timers
- [x] HTTP requests (Via Curl)
- [x] Multiple renders mode (``DRC``, ``TV`` and ``UNIQUE``)
- [x] FileSystem manipulation
- [ ] Cameras
- [ ] Wii U Gamepad Camera support
- [ ] Wii U Gamepad Microphone support

## How?
This engine uses [SDL2 (For the Wii U)](https://github.com/devkitPro/SDL/tree/wiiu-sdl2-2.28) as a base, along with other WUT functions. All the libraries are ported to Haxe to work through the ``@:native`` feature, to finally use [reflaxe.CPP](https://github.com/SomeRanDev/reflaxe.CPP) to generate the code in C++ and compile it through the [DevKitPPC](https://wiibrew.org/wiki/DevkitPPC) tools, although due to this mode, there are things that change and have more care in how the engine is used when you want to make a project with it. 

## Why?
Haxe has always fascinated me since I met him modifying [Friday Night Funkin'](https://github.com/FunkinCrew/Funkin) from 2022 (The result of that was the [Slushi Engine](https://github.com/Slushi-Github/Slushi-Engine)). And there was a time when I was really interested in getting a Nintendo Wii U, I knew it was a console that was not very popular and that kind of thing... But my interest was highly elevated by wanting to make my own homebrew for the console, and I wanted to try Haxe, unfortunately, although there was [an attempt to bring Haxe to the Wii U](https://www.fortressofdoors.com/openfl-for-home-game-consoles/), it was forgotten, besides needing to be registered in the Nintendo Developer, a lot of problems right?.

After months and months, after having managed to make the [HxCompileU project](https://github.com/Slushi-Github/hxCompileU) stable and viable, I now present, this, Leafy Engine, an engine that will try to be like HaxeFlixel, and create your games on this underrated console. 

## Using the engine
To use the engine, you first need the [DevKitPro](https://devkitpro.org/wiki/Getting_Started) tools, and many of their libraries:

- [DevKitPPC](https://wiibrew.org/wiki/DevkitPPC)
- [WUT](https://github.com/devkitPro/wut)
- Curl -> ``pacman -Syu wiiu-curl``
- SDL2 -> ``pacman -Syu wiiu-sdl2 wiiu-sdl2-image wiiu-sdl2-mixer wiiu-sdl2-ttf wiiu-sdl2_gfx``
- Jansson -> ``pacman -Syu ppc-jansson``

(It is possible that more libraries than those mentioned here may be required)

In Haxe, you need:

- [Haxe](https://haxe.org/)
- [reflaxe.CPP (Fork)](https://github.com/Slushi-Github/reflaxe.CPP)
- [reflaxe](https://github.com/someRanDev/reflaxe)
- [hxSDL2](https://github.com/Slushi-Github/hxSDL2)
- [hxWUT](https://github.com/Slushi-Github/hxWUT)
- [hxJansson](https://github.com/Slushi-Github/hxJansson)
- [hxVorbis](https://github.com/Slushi-Github/hxVorbis)
- [SlushiUtilsU](https://github.com/Slushi-Github/slushiUtilsU)

And the compiler for this project, [HxCompileU](https://github.com/Slushi-Github/hxCompileU) in version 1.3.5 or higher

HxCompileU uses a ``hxCompileUConfig.json`` as its file to start the compilation, well, this project uses one that already has a specific configuration, I would recommend to use that same JSON, [you can find it here](https://github.com/Slushi-Github/leafyEngine/blob/main/setup/hxCompileUConfig.json)

## Contributing
If you want to contribute to this project, you can do it by creating a pull request on this repository, test that your changes work both in [Cemu](https://github.com/cemu-project/Cemu) and on the real hardware, I would recommend attaching images if it is a change that can be shown.

## Credits
- [DevkitPro](https://devkitpro.org/): The base of the homebrew development on Wii U

- [Wii U SDL2 team](https://github.com/devkitPro/SDL/tree/wiiu-sdl2-2.28): The SDL2 port for Wii U

- [SomeRanDev](https://github.com/SomeRanDev): The creator of [reflaxe](https://github.com/SomeRanDev/reflaxe) and [reflaxe.CPP](https://github.com/SomeRanDev/reflaxe.CPP), literally the one who made it possible for me to create a game engine for this peculiar console using Haxe

- [Owk](https://youtube.com/@owkby06?si=JBgJEc5DOnzUtDRU): She helped me to make the project logo

- [shima_RAmar (Twitter/X)](https://x.com/shima_RAmar): The artist I used [one of his illustrations](https://x.com/shima_RAmar/status/1892218974961651882) for the Leafeon that appears in the logo

## License
This project is released under the [MIT license](https://github.com/Slushi-Github/leafyEngine/blob/main/LICENSE.md)
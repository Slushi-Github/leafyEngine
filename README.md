<h1 align="center">Leafy Engine</h1>
<h2 align="center">The first 2D game engine for the Wii U made with Haxe!</h2>

![Leafy Engine Logo](https://github.com/Slushi-Github/leafyEngine/blob/main/readme/leafyEngineLogo.png)

Leafy Engine is an engine inspired by [HaxeFlixel](https://haxeflixel.com/) for making 2D games for the Wii U using Haxe, yes, Haxe!

> [!IMPORTANT]
> The engine is still in development, so there may be some bugs, instability and many changes constantly!

[Leafy Engine Docs](https://github.com/Slushi-Github/leafyEngine/blob/main/docs/wiki/README.md)

A normal Leafy Engine code looks like this:

```haxe
package;

import Std;
import leafy.objects.LfSprite;
import leafy.LfState;
import leafy.Leafy;

class PlayState extends LfState {
    var sprite:LfSprite;

    override public function create():Void {

        // Create a sprite
        sprite = new LfSprite(100, 100);
        sprite.createGraphic(200, 200, [255, 0, 0]);
        sprite.center();
        addObject(sprite);

		var textSprite:LfText = new LfText(0, 0, "Hello World!", 32, "LeafyGame/font.ttf");
		textSprite.center();
		textSprite.y -= 120;
		textSprite.setColor(0, 0, 255);
		addObject(textSprite);
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

A code probably similar to one from [HaxeFlixel](https://haxeflixel.com) right?

## Current status of the engine:
- [x] Wii U Gamepad support
	- [x] Wii U Gamepad Buttons and sticks
	- [x] Wii U Gamepad Rumble
	- [x] Wii U Gamepad Accelerometer
	- [x] Wii U Gamepad Gyroscope
	- [x] Wii U Gamepad Touchscreen
		- [x] Wii U Gamepad Touchscreen touch position and click
		- [ ] Wii U Gamepad Touchscreen LCD brightness control (Not necessary for now)
	- [ ] Wii U Gamepad Camera (not necessary for now)
	- [ ] Wii U Gamepad Microphone (Not necessary for now)
	- [x] Wii U Gamepad home button control
- Objects
	- [x] Sprites
	- [x] Texts
	- [x] buttons (Partially broken)
- [x] Audio support with precise control (Only one music or sound at the same time)
- [x] States 
- [ ] Substates
- [x] Collisions
- [x] Sprites basic physics
- [x] Tweens and easing functions
- [x] JSONs file support (Only decoding)
- [x] Timers
- [x] HTTP requests (Via CURL)
- Engine rendering modes
	- [x] Only on the Wii U Gamepad (-> ``DRC``)
	- [x] Only on the TV (-> ``TV``)
	- [x] Both (-> ``UNIQUE``)
	- [ ] Separate rendering (Wii U Gamepad and TV independent at the same time -> ``DUAL``)
- [x] FileSystem manipulation
- [ ] Engine cameras

## How?
This engine uses [SDL2 (For the Wii U)](https://github.com/devkitPro/SDL/tree/wiiu-sdl2-2.28) as a base, along with other [WUT](https://github.com/devkitPro/wut) functions. All the libraries are ported to Haxe to work through the ``@:native`` feature, to finally use [Reflaxe/C++](https://github.com/SomeRanDev/reflaxe.CPP) to generate the code in C++ and compile it through the [DevKitPPC](https://wiibrew.org/wiki/DevkitPPC) tools, although due to this mode, there are things that change and have more care in how the engine is used when you want to make a project with it. 

## Why?
Haxe has always fascinated me since I met him modifying [Friday Night Funkin'](https://github.com/FunkinCrew/Funkin) from 2022 (The result of that was the [Slushi Engine](https://github.com/Slushi-Github/Slushi-Engine)). And there was a time when I was really interested in getting a Nintendo Wii U, I knew it was a console that was not very popular and that kind of thing... But my interest was highly elevated by wanting to make my own homebrew for the console, and I wanted to try Haxe, unfortunately, although there was [an attempt to bring Haxe to the Wii U](https://www.fortressofdoors.com/openfl-for-home-game-consoles), it was forgotten (Or I think it is only maintained for Nintendo Switch at the moment), besides needing to be registered in the Nintendo Developer Portal, a lot of problems right?.

After months and months, after having managed to make the [HxCompileU project](https://github.com/Slushi-Github/hxCompileU) stable and viable, I now present, this, Leafy Engine, an engine that will try to be like [HaxeFlixel](https://haxeflixel.com), and create your games on this underrated console. 

## Using the engine

Read the [Getting Started](https://github.com/Slushi-Github/leafyEngine/blob/main/docs/wiki/Getting-Started.md) page

## Contributing
If you want to contribute to this project, you can do it by creating a pull request on this repository, test that your changes work both in [Cemu](https://github.com/cemu-project/Cemu) __**and on the real hardware**__, I would recommend attaching images if it is a change that can be shown.

## Credits
- [DevkitPro](https://devkitpro.org): The base of the homebrew development on Wii U

- [Wii U SDL2 team](https://github.com/devkitPro/SDL/tree/wiiu-sdl2-2.28): The SDL2 port for Wii U

- [SomeRanDev](https://github.com/SomeRanDev): The creator of [reflaxe](https://github.com/SomeRanDev/reflaxe) and [Reflaxe/C++](https://github.com/SomeRanDev/reflaxe.CPP), literally the one who made it possible for me to create a game engine for this peculiar console using Haxe

- [Owk](https://youtube.com/@owkby06): She helped me to make the project logo

- [shima_RAmar (Twitter/X)](https://x.com/shima_RAmar): The artist I used [one of his illustrations](https://x.com/shima_RAmar/status/1892218974961651882) for the Leafeon that appears in the logo

## License
This project is released under the [MIT license](https://github.com/Slushi-Github/leafyEngine/blob/main/LICENSE.md)
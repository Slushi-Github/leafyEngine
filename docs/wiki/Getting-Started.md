# Installation
Assuming you already have Haxe, create a new folder where you want your project to be, then open a terminal in that folder and do the first command:

```bash
haxelib newrepo
```
This creates a local repository of Haxe libraries, it is better to do it this way instead of global libraries.

Now let's start installing the Haxe libraries:

```bash
haxelib git leafyEngine https://github.com/Slushi-Github/leafyEngine.git

haxelib git reflaxe https://github.com/SomeRanDev/reflaxe.git

haxelib git reflaxe.cpp https://github.com/Slushi-Github/reflaxe.CPP.git

haxelib git slushiUtilsu https://github.com/Slushi-Github/slushiUtilsU.git

haxelib git hxu_wut https://github.com/Haxe-WiiU/HxU_WUT.git

haxelib git hxu_sdl2 https://github.com/Haxe-WiiU/HxU_SDL2.git

haxelib git hxu_vorbis https://github.com/Haxe-WiiU/HxU_Vorbis.git

haxelib git hxu_jansson https://github.com/Haxe-WiiU/HxU_Jansson.git
```

Now get or compile the compiler, [HxCompileU](https://github.com/Slushi-Github/hxCompileU) in version 1.4.0 or higher, and add the executable to your project folder.

Now you need the DevKitPro dependencies:

Get [MSys2 from DevKitPro](https://github.com/devkitPro/installer/releases/latest) if you're on Windows

If you're on Linux or MacOS, you can follow [this guide](https://devkitpro.org/wiki/devkitPro_pacman)

When you have everything, install the following:

(include the ``dkp-`` if you're on Linux or MacOS)
```bash
(dkp-)pacman -Syu --needed wiiu-dev wiiu-curl wiiu-sdl2 wiiu-sdl2-image wiiu-sdl2-mixer wiiu-sdl2-ttf wiiu-sdl2_gfx ppc-jansson ppc-zlib ppc-libvorbis ppc-libopus ppc-libogg ppc-libjpeg-turbo ppc-freetype ppc-bzip2 ppc-libpng
```

Now you're ready to start coding!

# Using the engine

First, copy the required ``hxCompileUConfig.json`` file to your project folder, [you can find it here](https://github.com/Slushi-Github/leafyEngine/blob/main/setup/hxCompileUConfig.json)

Then, run ``hxCompileU --compile`` and you're ready to go!

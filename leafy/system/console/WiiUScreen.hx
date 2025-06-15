// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.system.console;

import wut.coreinit.Screen;
import wut.coreinit.Cache;

enum ScreenMode {
    TV;
    GAMEPAD;
    ALL;
}

/**
 * A simple class for handling the Wii U screens, allowing text to be typed or 
 * pixels to be placed on console displays.
 * 
 * normally this cannot be used since SDL2 is running while 
 * using the engine, but, it may be useful for some occasions.
 * 
 * Author: Slushi
 */
class WiiUScreen {
    private static var started:Bool = false;

	private static var tvBufferSize:SizeT;
	private static var drcBufferSize:SizeT;
    private static var tvBuffer:VoidPtr;
	private static var drcBuffer:VoidPtr;

	/**
	 * Colors on the console are in RGBX format.
	 * I.e. 0xRRGGBBXX, where XX is the alpha value.
     * Ex: 
     *  0x0000FF00 = Green
     *  0xFF000000 = Red
     *  0x00FF0000 = Blue
     *  0x00000000 = Black
     * 
	 * Thanks Trock for helping me understand that.
	 */
	public static var bgColor:UInt32 = 0x00000000;

     //////////////////////////////////////////

    public static function initScreens():Void {
		Screen.OSScreenInit();

        tvBufferSize = Screen.OSScreenGetBufferSizeEx(SCREEN_TV);
        drcBufferSize = Screen.OSScreenGetBufferSizeEx(SCREEN_DRC);

        tvBuffer = Stdlib.memalign(tvBufferSize, tvBufferSize);
        drcBuffer = Stdlib.memalign(drcBufferSize, drcBufferSize);

        if (tvBuffer == null || drcBuffer == null) {
            LeafyDebug.log("Failed to allocate console screen buffers!", ERROR);
            return;
        }

        Screen.OSScreenSetBufferEx(SCREEN_TV, tvBuffer);
        Screen.OSScreenSetBufferEx(SCREEN_DRC, drcBuffer);
        Screen.OSScreenEnableEx(SCREEN_TV, true);
        Screen.OSScreenEnableEx(SCREEN_DRC, true);

        LeafyDebug.log("Console Screen initialized...?", DEBUG);

        started = true;
    }

    public static function setConsoleBgColor(newColor:UInt32):Void {
        bgColor = newColor;
    }

    public static function startDrawing():Bool {
        if (!started) {
            return false;
        }

		Screen.OSScreenClearBufferEx(SCREEN_TV, bgColor);
		Screen.OSScreenClearBufferEx(SCREEN_DRC, bgColor);

        return true;
    }

    public static function stopDrawingAndRefresh():Void {
        if (started) {
			Cache.DCFlushRange(tvBuffer, tvBufferSize);
            Cache.DCFlushRange(drcBuffer, drcBufferSize);	
            Screen.OSScreenFlipBuffersEx(SCREEN_TV);
            Screen.OSScreenFlipBuffersEx(SCREEN_DRC);
            started = false;
        }
    }

    public static function clearConsoleScreen():Void {
        if (started) {
            Screen.OSScreenClearBufferEx(SCREEN_TV, bgColor);
            Screen.OSScreenClearBufferEx(SCREEN_DRC, bgColor);
        }
    }

    public static function shutdown():Void {
		stopDrawingAndRefresh();

        if (tvBuffer != null) {
            Stdlib.free(tvBuffer);
        }
        if (drcBuffer != null) {
            Stdlib.free(drcBuffer);
        }

		Screen.OSScreenShutdown();
    }

    /////////////////////////////////////////

	public static function setText(mode:ScreenMode, x:UInt32, y:UInt32, text:String):Void {
		if (!started) {
			return;
		}

		switch (mode) {
			case ScreenMode.TV:
				Screen.OSScreenPutFontEx(SCREEN_TV, x, y, ConstCharPtr.fromString(text));
			case ScreenMode.GAMEPAD:
				Screen.OSScreenPutFontEx(SCREEN_DRC, x, y, ConstCharPtr.fromString(text));
			case ScreenMode.ALL:
				Screen.OSScreenPutFontEx(SCREEN_TV, x, y, ConstCharPtr.fromString(text));
				Screen.OSScreenPutFontEx(SCREEN_DRC, x, y, ConstCharPtr.fromString(text));
		}
	}

    public static function setPixel(mode:ScreenMode, x:UInt32, y:UInt32, color:UInt32):Void {
        if (!started) {
            return;
        }

        switch (mode) {
            case ScreenMode.TV:
                Screen.OSScreenPutPixelEx(SCREEN_TV, x, y, color);
            case ScreenMode.GAMEPAD:
                Screen.OSScreenPutPixelEx(SCREEN_DRC, x, y, color);
            case ScreenMode.ALL:
                Screen.OSScreenPutPixelEx(SCREEN_TV, x, y, color);
                Screen.OSScreenPutPixelEx(SCREEN_DRC, x, y, color);
        }
    }
}
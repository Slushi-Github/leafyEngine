// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.system.console;

import Std;
import wut.whb.Sdcard;

/**
 * Class to handle SD Card operations on the console.
 * 
 * Author: Slushi
 */
class SDCard {

    /**
     * Mount the SD Card.
     */
    public static function mountSDCard():Bool {
        return Sdcard.WHBMountSdCard();
    }

    /**
     * Unmount the SD Card.
     */
    public static function unmountSDCard():Bool {
        return Sdcard.WHBUnmountSdCard();
    }

    /**
     * Get the fixed SD Card path ("/fs/vol/external01/wiiu/").
     * @return String
     */
    public static function getSDCardWiiUPath():String {
        return Std.string(Sdcard.WHBGetSdCardMountPath() + "/wiiu/");
    }

    /**
     * Get the SD Card path ("/fs/vol/external01/").
     * @return String
     */
    public static function getSDCardPath():String {
        return Std.string(Sdcard.WHBGetSdCardMountPath());
    }
}
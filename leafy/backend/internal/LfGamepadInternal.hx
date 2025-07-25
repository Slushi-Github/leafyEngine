// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend.internal;

import Std;

import wut.vpad.Input;
import wut.vpad.Input.VPAD;
import wut.vpad.Input.VPADButtons;
import wut.vpad.Input.VPADReadError;
import wut.vpadbase.Base.VPADChan;
import wut.nn.ccr.Sys;
import wut.coreinit.Systeminfo;

@:cppFileCode("
#include <vpad/input.h>
#include <atomic>
#include <thread>
#include <chrono>
#include <vector>
#include <algorithm>
#include <iostream>

std::atomic<bool> shouldStopVibration{false};
std::thread vibrationThread;

std::vector<uint8_t> createVibrationPattern(float intensity, size_t len = 64) {
    std::vector<uint8_t> pattern(len, 0);
    if (intensity >= 1.0f) {
        std::fill(pattern.begin(), pattern.end(), 0xFF);
    } else if (intensity > 0.0f) {
        size_t onCount = static_cast<size_t>(intensity * len);
        std::fill_n(pattern.begin(), onCount, 0xFF);
        std::rotate(pattern.begin(), pattern.begin() + onCount / 2, pattern.end());
    }
    return pattern;
}

void CPP_vibrateGamepad(float intensity, int ms_duration) {
    shouldStopVibration = true;
    if (vibrationThread.joinable())
        vibrationThread.join();
    shouldStopVibration = false;

    if (intensity <= 0.0f) {
        VPADStopMotor(VPAD_CHAN_0);
        return;
    }

    vibrationThread = std::thread([=]() {
        auto pattern = createVibrationPattern(intensity);
        const VPADChan chan = VPAD_CHAN_0;

        if (ms_duration < 0) {
            while (!shouldStopVibration) {
                VPADControlMotor(chan, pattern.data(), static_cast<uint8_t>(pattern.size()));
                std::this_thread::sleep_for(std::chrono::milliseconds(100));
            }
            VPADStopMotor(chan);
        } else {
            int ciclos = ms_duration / 100;
            for (int i = 0; i < ciclos && !shouldStopVibration; ++i) {
                VPADControlMotor(chan, pattern.data(), static_cast<uint8_t>(pattern.size()));
                std::this_thread::sleep_for(std::chrono::milliseconds(100));
            }
            VPADStopMotor(chan);
        }
    });
}

void CPP_stopVibration() {
    shouldStopVibration = true;
    if (vibrationThread.joinable())
        vibrationThread.join();
    VPADStopMotor(VPAD_CHAN_0);
}
")

/**
 * Internal class for handling the DRC (Wii U Gamepad) input
 * This class is used to read the state of the DRC and handle different events
 * It is not meant to be used directly, but rather through the `LfGamepad` class.
 */
class LfGamepadInternal {
    /**
     * The current state of the DRC
     */
    private static var drcStatus:VPADStatus;
    /**
     * The last error of the DRC
     */
    private static var drcLastError:VPADReadError;

    /**
     * Whether the last read was valid and new
     */
    private static var lastReadWasValidAndNew:Bool = false;

    /**
     * Whether the DRC was last touching
     */
    private static var lastTouching:Bool = false;

    /**
     * Whether the DRC is currently touching
     */
    private static var currentTouching:Bool = false;

    /**
     * Whether the DRC is rumbling
     */
    public static var isRumbling:Bool = false;

    /**
     * Initializes the DRC
     */
    public static function initDRC() {
        drcStatus = new VPADStatus();
        drcLastError = VPAD_READ_SUCCESS;
        lastReadWasValidAndNew = false;
    }

    /**
     * Updates the DRC state
     * @return Bool Whether the state was updated
     */
    public static function updateDRC():Bool {
        VPAD.VPADRead(VPAD_CHAN_0, Syntax.toPointer(drcStatus), 1, Syntax.toPointer(drcLastError));

        untyped __cpp__("
            switch (leafy::backend::internal::LfGamepadInternal::drcLastError) {
                case VPAD_READ_SUCCESS:
                    leafy::backend::internal::LfGamepadInternal::lastReadWasValidAndNew = true;
                    return true;
                case VPAD_READ_NO_SAMPLES:
                    return false;
                default:
                    leafy::backend::internal::LfGamepadInternal::lastReadWasValidAndNew = false;
                    return false;
            }
        ");

        lastTouching = currentTouching;
        currentTouching = isTouching();

        return false;
    }

    /**
     * Checks if a button is pressed
     * @param button The button
     * @return Bool Whether the button is pressed
     */
    public static function isPressed(button:VPADButtons):Bool {
        return lastReadWasValidAndNew && (drcStatus.hold & Stdlib.ccast(button)) != 0;
    }

    /**
     * Checks if a button was just pressed
     * @param button The button
     * @return Bool Whether the button was just pressed
     */
    public static function isJustPressed(button:VPADButtons):Bool {
        return lastReadWasValidAndNew && (drcStatus.trigger & Stdlib.ccast(button)) != 0;
    }

    /**
     * Checks if a button is released
     * @param button The button 
     * @return Bool Whether the button is released
     */
    public static function isReleased(button:VPADButtons):Bool {
        return lastReadWasValidAndNew && (drcStatus.hold & Stdlib.ccast(button)) == 0;
    }

    /**
     * Checks if a button was just released
     * @param button The button
     * @return Bool Whether the button was just released
     */
    public static function isJustReleased(button:VPADButtons):Bool {
        return lastReadWasValidAndNew && (drcStatus.release & Stdlib.ccast(button)) != 0;
    }

    /**
     * Checks if the user is pressing the touchscreen of the DRC
     * @return Bool
     */
    public static function isTouchPressed():Bool {
    return currentTouching;
    }

    /**
     * Checks if the user just pressed the touchscreen of the DRC
     * @return Bool
     */
    public static function isTouchJustPressed():Bool {
        return currentTouching && !lastTouching;
    }

    /**
     * Checks if the user is releasing the touchscreen of the DRC
     * @return Bool
     */
    public static function isTouchReleased():Bool {
        return !currentTouching;
    }

    /**
     * Checks if the user just released the touchscreen of the DRC
     * @return Bool
     */
    public static function isTouchJustReleased():Bool {
        return !currentTouching && lastTouching;
    }

    /**
     * Gets the X position of the left stick
     * @return Float The X position
     */
    public static function getLeftStickX():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.leftStick.x;
    }

    /**
     * Gets the Y position of the left stick
     * @return Float The Y position
     */
    public static function getLeftStickY():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.leftStick.y;
    }

    /**
     * Gets the X position of the right stick
     * @return Float The X position
     */
    public static function getRightStickX():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.rightStick.x;
    }

    /**
     * Gets the Y position of the right stick
     * @return Float The Y position
     */
    public static function getRightStickY():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.rightStick.y;
    }

    /**
     * Checks if the touchscreen of the DRC is touching
     * @return Bool Whether the touchscreen is touching
     */
    public static function isTouching():Bool {
        return lastReadWasValidAndNew && drcStatus.tpNormal.touched != 0;
    }

    /**
     * Gets the native X position of the touchscreen
     * @return Int The absolute X position of the touchscreen from the DRC
     */
    public static function getRawTouchX():Int {
    return drcStatus.tpNormal.x;
    }

    /**
     * Gets the native Y position of the touchscreen
     * @return Int The absolute Y position of the touchscreen from the DRC
     */
    public static function getRawTouchY():Int {
        return drcStatus.tpNormal.y;
    }

    /**
     * Gets the X position of the touchscreen of the DRC
     * @return Int The X position of the touchscreen
     */
    public static function getTouchX():Int {
        if (!isTouching()) return -1;
        return Std.int((getRawTouchX() / 4095.0) * Leafy.screenWidth);
    }

    /**
     * Gets the Y position of the touchscreen of the DRC
     * @return Int The Y position of the touchscreen
     */
    public static function getTouchY():Int {
        if (!isTouching()) return -1;
        // The touchscreen Y position is inverted?
        return Std.int(((4095.0 - drcStatus.tpNormal.y) / 4095.0) * Leafy.screenHeight);
    }

    /**
     * Gets the X axis of the gyroscope of the DRC
     * @return Float The X axis
     */
    public static function getGyroX():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.gyro.x;
    }

    /**
     * Gets the Y axis of the gyroscope of the DRC
     * @return Float The Y axis
     */
    public static function getGyroY():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.gyro.y;
    }

    /**
     * Gets the Z axis of the gyroscope of the DRC
     * @return Float The Z axis
     */
    public static function getGyroZ():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.gyro.z;
    }

    public static function getAngleX():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.angle.x;
    }

    public static function getAngleY():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.angle.y;
    }

    public static function getAngleZ():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.angle.z;
    }

    /**
     * Gets the X axis of the accelerometer
     * @return Float The X axis
     */
    public static function getAccelX():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.accelorometer.acc.x;
    }

    /**
     * Gets the Y axis of the accelerometer
     * @return Float The Y axis
     */
    public static function getAccelY():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.accelorometer.acc.y;
    }

    /**
     * Gets the Z axis of the accelerometer
     * @return Float The Z axis
     */
    public static function getAccelZ():Float {
        if (!lastReadWasValidAndNew) return 0.0;
        return drcStatus.accelorometer.acc.z;
    }

    /////////////////////

    /**
     * Changes the brightness of the DRC LCD
     * @param brightness 
     */
    public static function setDRCLCDBrightness(brightness:CCRSysLCDMode):Void {
        Sys.CCRSysSetCurrentLCDMode(brightness);
    }

    /*
     * Gets the current brightness of the DRC LCD
     * @return CCRSysLCDMode
     */
    public static function getDRCLCDBrightness():CCRSysLCDMode {
        untyped __cpp__("
CCRSysLCDMode mode;
CCRSysGetCurrentLCDMode(&mode);
return mode");
        return untyped __cpp__("mode");
    }

    /////////////////////

    /**
     * Starts rumble on the DRC
     * @param intensity The intensity of the rumble (0.0 to 1.0)
     * @param durationSeconds The duration of the rumble
     */
    public static function startRumble(intensity:Float = 1.0, durationSeconds:Float = -1.0):Void {
        untyped __cpp__("CPP_vibrateGamepad({0}, {1})", intensity, durationSeconds);
        isRumbling = true;
    }

    /**
     * Stops rumble on the DRC
     */
    public static function stopRumble():Void {
        untyped __cpp__("CPP_stopVibration()");
        isRumbling = false;
    }

    /////////////////////

    public static function enableHomeMenuButton(mode:Bool):Void {
        Systeminfo.OSEnableHomeButtonMenu(mode);
    }

    public static function isHomeMenuButtonEnabled():Bool {
        return Systeminfo.OSIsHomeButtonMenuEnabled();
    }
}
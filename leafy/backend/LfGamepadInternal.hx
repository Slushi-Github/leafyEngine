// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import Std;

import wut.vpad.Input;
import wut.vpad.Input.VPADButtons;
import wut.vpad.Input.VPADReadError;
import wut.vpadbase.Base.VPADChan;

/**
 * Internal class for the gamepad input
 * To use the gamepad it is recommended to use the `LfGamepad` class
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
            switch (leafy::backend::LfGamepadInternal::drcLastError) {
                case VPAD_READ_SUCCESS:
                    leafy::backend::LfGamepadInternal::lastReadWasValidAndNew = true;
                    return true;
                case VPAD_READ_NO_SAMPLES:
                    return false;
                default:
                    leafy::backend::LfGamepadInternal::lastReadWasValidAndNew = false;
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
}
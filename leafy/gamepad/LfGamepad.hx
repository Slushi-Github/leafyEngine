// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.gamepad;

import Std;
import wut.vpad.Input.VPADButtons;

import leafy.backend.LfGamepadInternal;
import leafy.objects.LfSprite;
import leafy.utils.LfUtils.LfVector2D;
import leafy.utils.LfUtils.LfVector3D;

/**
 * The list of gamepad buttons
 */
enum LfGamepadButton {
    BUTTON_A;
    BUTTON_B;
    BUTTON_X;
    BUTTON_Y;
    BUTTON_UP;
    BUTTON_DOWN;
    BUTTON_LEFT;
    BUTTON_RIGHT;
    BUTTON_L;
    BUTTON_R;
    BUTTON_ZR;
    BUTTON_ZL;
    BUTTON_PLUS;
    BUTTON_MINUS;
    BUTTON_HOME;
    BUTTON_JOYSTICK_R;
    BUTTON_JOYSTICK_L;
    BUTTON_TV;
}

/**
 *  The Wii U Gamepad class, this class is used to get the gamepad input
 * 
 * Author: Slushi
 */
class LfGamepad {

    public function new() {}

    /**
     * Checks if a button is pressed
     * @param button The button
     * @return Bool Whether the button is pressed
     */
    public function pressed(button:LfGamepadButton):Bool {
        return LfGamepadInternal.isPressed(getVpadButtonValue(button));
    }

    /**
     * Checks if a button is released
     * @param button The button
     * @return Bool Whether the button is released
     */
    public function released(button:LfGamepadButton):Bool {
        return LfGamepadInternal.isReleased(getVpadButtonValue(button));
    }

    /**
     * Checks if a button was just pressed
     * @param button The button
     * @return Bool Whether the button was just pressed
     */
    public function justPressed(button:LfGamepadButton):Bool {
        return LfGamepadInternal.isJustPressed(getVpadButtonValue(button));
    }

    /**
     * Checks if a button was just released
     * @param button The button
     * @return Bool Whether the button was just released
     */
    public function justReleased(button:LfGamepadButton):Bool {
        return LfGamepadInternal.isJustReleased(getVpadButtonValue(button));
    }

    /**
     * Checks if the touchscreen of the gamepad is touching
     * @return Bool
     */
    public function touchPressed():Bool {
        return LfGamepadInternal.isTouchPressed();
    }

    /**
     * Checks if the touchscreen of the gamepad was just pressed
     * @return Bool
     */
    public function touchJustPressed():Bool {
        return LfGamepadInternal.isTouchJustPressed();
    }

    /**
     * Checks if the touchscreen of the gamepad was released
     * @return Bool
     */
    public function touchReleased():Bool {
        return LfGamepadInternal.isTouchReleased();
    }

    /**
     * Checks if the touchscreen of the gamepad was just released
     * @return Bool
     */
    public function touchJustReleased():Bool {
        return LfGamepadInternal.isTouchJustReleased();
    }

    /**
     * Gets the left stick position
     * @return LfVector2D The left stick X and Y position
     */
    public function getLeftStick():LfVector2D {
        return {
            x: LfGamepadInternal.getLeftStickX(),
            y: LfGamepadInternal.getLeftStickY()
        }
    }

    /**
     * Gets the right stick position
     * @return LfVector2D The right stick X and Y position
     */
    public function getRightStick():LfVector2D {
        return {
            x: LfGamepadInternal.getRightStickX(),
            y: LfGamepadInternal.getRightStickY()
        }
    }

    /**
     * Gets the touchscreen position
     * @return LfVector2D The touchscreen X and Y position
     */
    public function getTouch():LfVector2D {
        return {
            x: LfGamepadInternal.getTouchX(),
            y: LfGamepadInternal.getTouchY()
        }
    }

    /**
     * Checks if the touchscreen of the gamepad is touching
     * @return Bool Whether the touchscreen is touching
     */
    public function isTouching():Bool {
        return LfGamepadInternal.isTouching();
    }

    /**
     * Gets the gyro position of the gamepad
     * @return LfVector3D The gyro X, Y and Z position
     */
    public function getGyro():LfVector3D {
        return {
            x: LfGamepadInternal.getGyroX(),
            y: LfGamepadInternal.getGyroY(),
            z: LfGamepadInternal.getGyroZ()
        }
    }

    /**
     * Gets the angle of the gamepad
     * @return LfVector3D The angle X, Y and Z position
     */
    public function getAngle():LfVector3D {
        return {
            x: LfGamepadInternal.getAngleX(),
            y: LfGamepadInternal.getAngleY(),
            z: LfGamepadInternal.getAngleZ()
        }
    }

    /**
     * Gets the acceleration of the gamepad
     * @return LfVector3D The acceleration X, Y and Z position
     */
    public function getAccel():LfVector3D {
        return {
            x: LfGamepadInternal.getAccelX(),
            y: LfGamepadInternal.getAccelY(),
            z: LfGamepadInternal.getAccelZ()
        }
    }

    /**
     * Checks if the touchscreen of the gamepad is touching a sprite
     * @param sprite The sprite
     * @return Bool
     */
    public function isTouchingSprite(sprite:LfSprite):Bool {
        if (!this.isTouching()) return false;

        var touchX = this.getTouch().x;
        var touchY = this.getTouch().y;

        return (touchX >= sprite.x &&
                touchX <= sprite.x + sprite.width &&
                touchY >= sprite.y &&
                touchY <= sprite.y + sprite.height);
    }

    // public function startRumble(intensity:Float = 1.0, durationSeconds:Float = -1.0):Void {
    //     LfGamepadInternal.startRumble(intensity, durationSeconds);
    // }

    // public function stopRumble():Void {
    //     LfGamepadInternal.stopRumble();
    // }


    /**
     * Converts a LfGamepadButton to a VPADButtons
     * @param button The button
     * @return VPADButtons The VPADButtons
     */
    private function getVpadButtonValue(button:LfGamepadButton):VPADButtons {
        switch(button) {
            case LfGamepadButton.BUTTON_A:
                return VPADButtons.VPAD_BUTTON_A;
            case LfGamepadButton.BUTTON_B:
                return VPADButtons.VPAD_BUTTON_B;
            case LfGamepadButton.BUTTON_X:
                return VPADButtons.VPAD_BUTTON_X;
            case LfGamepadButton.BUTTON_Y:
                return VPADButtons.VPAD_BUTTON_Y;
            case LfGamepadButton.BUTTON_UP:
                return VPADButtons.VPAD_BUTTON_UP;
            case LfGamepadButton.BUTTON_DOWN:
                return VPADButtons.VPAD_BUTTON_DOWN;
            case LfGamepadButton.BUTTON_LEFT:
                return VPADButtons.VPAD_BUTTON_LEFT;
            case LfGamepadButton.BUTTON_RIGHT:
                return VPADButtons.VPAD_BUTTON_RIGHT;
            case LfGamepadButton.BUTTON_L:
                return VPADButtons.VPAD_BUTTON_L;
            case LfGamepadButton.BUTTON_R:
                return VPADButtons.VPAD_BUTTON_R;
            case LfGamepadButton.BUTTON_ZR:
                return VPADButtons.VPAD_BUTTON_ZR;
            case LfGamepadButton.BUTTON_ZL:
                return VPADButtons.VPAD_BUTTON_ZL;
            case LfGamepadButton.BUTTON_PLUS:
                return VPADButtons.VPAD_BUTTON_PLUS;
            case LfGamepadButton.BUTTON_MINUS:
                return VPADButtons.VPAD_BUTTON_MINUS;
            case LfGamepadButton.BUTTON_HOME:
                return VPADButtons.VPAD_BUTTON_HOME;
            case LfGamepadButton.BUTTON_JOYSTICK_R:
                return VPADButtons.VPAD_BUTTON_STICK_R;
            case LfGamepadButton.BUTTON_JOYSTICK_L:
                return VPADButtons.VPAD_BUTTON_STICK_L;
            case LfGamepadButton.BUTTON_TV:
                return VPADButtons.VPAD_BUTTON_TV;
            default:
                LeafyDebug.log("Unknown button: " + Std.string(button), WARNING);
                return VPADButtons.VPAD_BUTTON_A;
        }
        return VPADButtons.VPAD_BUTTON_A;
    }
}
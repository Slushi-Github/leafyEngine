# The Wii U Gamepad

The Wii U Gamepad is base of a Wii U right?

Well, there is a way of use the gamepad buttons in the engine:

```haxe
// import the Leafy class
import leafy.Leafy;

// get if a button is pressed
var isPressed:Bool = Leafy.wiiuGamepad.pressed(BUTTON_A);

// Get if a button is released
var isReleased:Bool = Leafy.wiiuGamepad.released(BUTTON_A);

// Get if a button is just pressed
var isHeld:Bool = Leafy.wiiuGamepad.justPressed(BUTTON_A);

// Get if a button is just released
var isJustReleased:Bool = Leafy.wiiuGamepad.justReleased(BUTTON_A);
```

The buttons can be found on the enum [``leafy.gamepad.LfGamepad.LfGamepadButton``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/gamepad/LfGamepad.hx)

--------

For the sticks, use:

```haxe
// import the Leafy class
import leafy.Leafy;

// get the left stick position
var stickLeftPosition:LfVector2D = Leafy.wiiuGamepad.getLeftStick();

// get the right stick position
var stickRightPosition:LfVector2D = Leafy.wiiuGamepad.getRightStick();
```

--------

For use the touchscreen, it would be done in this way:
```haxe
// import the Leafy class
import leafy.Leafy;

// Get if the touchscreen is pressed
var isTouched:Bool = Leafy.wiiuGamepad.touchPressed();

// Get if the touchscreen is just pressed
var isTouchReleased:Bool = Leafy.wiiuGamepad.isTouchJustPressed();

// Get if the touchscreen is released
var isTouchReleased:Bool = Leafy.wiiuGamepad.isTouchReleased();

// Get if the touchscreen is just released
var isTouchReleased:Bool = Leafy.wiiuGamepad.isTouchJustReleased();

// Get if the touchscreen is touching
var isTouching:Bool = Leafy.wiiuGamepad.isTouching();

// Get the position of the touchscreen
var touchPos:LfVector2D = Leafy.wiiuGamepad.getTouch();

// Get if touchscreen is object
var isTouchObject:Bool = Leafy.wiiuGamepad.isTouchingAObject(object:LfObject);
```

--------

You can use the gyroscope and accelerometer:
```haxe
// import the Leafy class
import leafy.Leafy;

// Get the gyroscope
var gyroscope:LfVector3D = Leafy.wiiuGamepad.getGyro();

// Get the accelerometer
var accelerometer:LfVector3D = Leafy.wiiuGamepad.getAccel();
```

--------

For use the rumble, it would be done in this way:
```haxe
// import the Leafy class
import leafy.Leafy;

// start the vibration of the Wii U Gamepad
/*
    The first parameter is the intensity of the vibration, from 0 to 1
    The second parameter is the duration of the vibration, in seconds, -1 for infinite
*/
Leafy.wiiuGamepad.vibrate(1, -1);

// stop the vibration
Leafy.wiiuGamepad.stopVibration();
```

<!-- --------

For the screen brightness, it would be done in this way:
```haxe
// import the Leafy class
import leafy.Leafy;

// set the brightness of the screen
Leafy.wiiuGamepad.setScreenBrightness(brightness:LfGamepadScreenBrightness);
Leafy.wiiuGamepad.setScreenBrightness(BRIGHTNESS_3);

// get the brightness of the screen
var brightness:LfGamepadScreenBrightness = Leafy.wiiuGamepad.getScreenBrightness();
```
The brightness modes can be found on the enum [``leafy.gamepad.LfGamepad.LfGamepadScreenBrightness``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/gamepad/LfGamepad.hx) -->

--------

See [``LfGamepad``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/gamepad/LfGamepad.hx)

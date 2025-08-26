// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.tweens;

import haxe.Exception;
import Std;
import leafy.objects.LfObject;

/**
 * Enum for LfObject properties
 */
enum LfTweenProperty {
    X;
    Y;
    // SCALE; // BROKEN
    WIDTH;
    HEIGHT;
    ALPHA;
    ANGLE;
}

/**
 * Enum for easing functions
 */
enum LfTweenEase {
    LINEAR;
    EASE_IN;
    EASE_OUT;
    EASE_IN_OUT;
    QUAD_IN;
    QUAD_OUT;
    QUAD_IN_OUT;
    CUBE_IN;
    CUBE_OUT;
    CUBE_IN_OUT;
    QUART_IN;
    QUART_OUT;
    QUART_IN_OUT;
    SINE_IN;
    SINE_OUT;
    SINE_IN_OUT;
    EXPO_IN;
    EXPO_OUT;
    EXPO_IN_OUT;
    BACK_IN;
    BACK_OUT;
    BACK_IN_OUT;
    BOUNCE_IN;
    BOUNCE_OUT;
    ELASTIC_IN;
    ELASTIC_OUT;
    ELASTIC_IN_OUT;
}

/**
 * A class for creating and updating tweens for LfObject properties
 * 
 * Author: Slushi
 */
class LfTween {
    private static var _tweens:Array<LfTween> = new Array<LfTween>();

    /**
     * The object to tween
     */
    public var target:LfObject;

    /**
     * The property to tween
     */
    public var valueType:LfTweenProperty;

    /**
     * The start value
     */
    public var startValue:Float;

    /**
     * The end value
     */
    public var endValue:Float;

    /**
     * The duration of the tween
     */
    public var duration:Float;

    /**
     * The elapsed time
     */
    public var elapsed:Float;

    /**
     * The function to call when the tween is complete
     */
    public var onComplete:Void->Void;

    // /**
    //  * The function to call when the tween is updated
    //  */
    // public var onUpdate:Void->Void;

    /**
     * The easing function
     */
    public var ease:LfTweenEase;

    /**
     * Whether the tween is complete
     */
    public var isComplete:Bool = false;

    /*
     * Whether the tween is a number tween
     */
    private var _isNumber:Bool = false;
    /**
     * Whether the tween should be automatically destroyed when complete
     */
    private var _autoDestroy:Bool;

    /**
     * Create a new tween, add it to the list of active tweens
     * @param target The LfObject to tween
     * @param valueType The LfObject property to tween
     * @param startValue The start value
     * @param endValue The end value
     * @param duration The duration of the tween
     * @param ease The easing function
     * @param onComplete The function to call when the tween is complete
     */
    public function new(target:LfObject = null, valueType:LfTweenProperty = LfTweenProperty.X, startValue:Float = 0.0, endValue:Float = 0.0, duration:Float = 0.0, ease:LfTweenEase = LfTweenEase.LINEAR, ?onComplete:Void->Void = null, autoDestroy:Bool = true, ?isNumber:Bool = false) {
        this.target = target;
        this.valueType = valueType;
        this.startValue = startValue;
        this.endValue = endValue;
        this.duration = duration;
        this.elapsed = 0;
        this.ease = ease;
        this.onComplete = onComplete;
        isComplete = false;
        _isNumber = isNumber;
        _autoDestroy = autoDestroy;
        // this.onUpdate = onUpdate;

        _tweens.push(this);
    }

    /**
     * Create a number tween
     * @param startValue The start value
     * @param endValue The end value
     * @param duration The duration
     * @param ease The ease
     * @param onComplete The onComplete
     * @return LfTween
     */
    public static function tweenNumber(startValue:Float, endValue:Float, duration:Float, ease:LfTweenEase = LfTweenEase.LINEAR, ?onComplete:Void->Void = null):LfTween {
        return new LfTween(null, LfTweenProperty.ALPHA, startValue, endValue, duration, ease, onComplete, true, true);
    }

    /**
     * Update the tween
     * @param dt The delta time
     */
    public function update(dt:Float):Void {
        if (isComplete) return;
        try {
            if (elapsed < duration) {
                elapsed += dt;
                var progress = Math.min(elapsed / duration, 1);
                var easedProgress = getEasedValue(progress);

                var value = startValue + (endValue - startValue) * easedProgress;

                // if (untyped __cpp__("onUpdate != nullptr")) {
                //     onUpdate();
                // }

                if (_isNumber) {
                    value = Std.int(value);
                }
                else {
                    switch (valueType) {
                        case LfTweenProperty.X: target.x = Std.int(value);
                        case LfTweenProperty.Y: target.y = Std.int(value);
                        // case LfTweenProperty.SCALE:
                        //     target.scale.x = value;
                        //     target.scale.y = value;
                        case LfTweenProperty.WIDTH: target.width = Std.int(value);
                        case LfTweenProperty.HEIGHT: target.height = Std.int(value);
                        case LfTweenProperty.ALPHA: target.alpha = value;
                        case LfTweenProperty.ANGLE: target.angle = Std.int(value);
                    }
                }
            } else {
                isComplete = true;
                if (untyped __cpp__("onComplete != NULL")) {
                    onComplete();
                }

                if (_autoDestroy) {
                    removeTween(this);
                }
            }
        } catch (e:Exception) {
            LeafyDebug.log("Error in LfTween update (Tween -> " + Std.string(this) + "): " + e.toString(), ERROR);
            isComplete = true;
        }
    }

    /**
     * Get the eased value
     * @param progress The progress of the tween
     * @return Float The eased value
     */
    private function getEasedValue(progress:Float):Float {
        switch (ease) {
            case LINEAR: return easeLinear(progress);
            case EASE_IN: return easeIn(progress);
            case EASE_OUT: return easeOut(progress);
            case EASE_IN_OUT: return easeInOut(progress);
            case QUAD_IN: return easeQuadIn(progress);
            case QUAD_OUT: return easeQuadOut(progress);
            case QUAD_IN_OUT: return easeQuadInOut(progress);
            case CUBE_IN: return easeCubeIn(progress);
            case CUBE_OUT: return easeCubeOut(progress);
            case CUBE_IN_OUT: return easeCubeInOut(progress);
            case QUART_IN: return easeQuartIn(progress);
            case QUART_OUT: return easeQuartOut(progress);
            case QUART_IN_OUT: return easeQuartInOut(progress);
            case SINE_IN: return easeSineIn(progress);
            case SINE_OUT: return easeSineOut(progress);
            case SINE_IN_OUT: return easeSineInOut(progress);
            case EXPO_IN: return easeExpoIn(progress);
            case EXPO_OUT: return easeExpoOut(progress);
            case EXPO_IN_OUT: return easeExpoInOut(progress);
            case BACK_IN: return easeBackIn(progress);
            case BACK_OUT: return easeBackOut(progress);
            case BACK_IN_OUT: return easeBackInOut(progress);
            case BOUNCE_IN: return easeBounceIn(progress);
            case BOUNCE_OUT: return bounceOut(progress);
            case ELASTIC_IN: return easeElasticIn(progress);
            case ELASTIC_OUT: return easeElasticOut(progress);
            case ELASTIC_IN_OUT: return easeElasticInOut(progress);
        }
        return progress;
    }

    //////////////////////////////////

    /** Update the list of active tweens
     * @param elapsed The elapsed time
     */
    public static function updateTweens(elapsed:Float):Void {
        for (tween in _tweens) {
            if (tween != null) {
                if (tween.isComplete)
                    continue;
                tween.update(elapsed);
            }
            else {
                LeafyDebug.log("Null tween found! ->" + Std.string(tween), WARNING);
            }
        }
    }

    /**
     * Clear the list of active tweens
     */
    public static function clearTweens():Void {
        if (_tweens == null) return;
        _tweens = [];
    }

    /**
     * Remove a tween
     * @param tween The tween to remove
     */
    public static function removeTween(tween:LfTween):Void {
        untyped __cpp__("
for (size_t i = 0; i < _tweens->size(); i++) {
    auto obj = _tweens->at(i);
    if (obj == tween) {
        obj->isComplete = true;
        _tweens->erase(_tweens->begin() + i);
        return;
    }
}");

        // This causes errors in C++ compilation
        // _tweens.remove(tween);
    }

    /**
     * Cancel a active tween
     * @param tween The tween to cancel
     */
    public static function cancelTween(tween:LfTween):Void {
        for (i in 0..._tweens.length) {
            if (_tweens[i] == tween) {
                _tweens[i].isComplete = true;
                return;
            }
        }
    }

    ////////////////////////////////////////////////////////////////////
    /**
     * Easing functions
     * These functions are used to calculate the easing of the tween.
     * Cannot be in another file otherwise Reflaxe/C++ explodes with many errors.
     * 
     * @see https://github.com/HaxeFlixel/flixel/blob/master/flixel/tweens/FlxEase.hx
     */
    //////////////////////////////////

    private function easeLinear(t:Float):Float {
        return t;
    }

    private function easeIn(t:Float):Float {
        return t * t;
    }

    private function easeOut(t:Float):Float {
        return -t * (t - 2);
    }

    private function easeInOut(t:Float):Float {
        if (t < 0.5) return 2 * t * t;
        return -2 * t * t + 4 * t - 1;
    }

    private function easeQuadIn(t:Float):Float {
        return t * t;
    }

    private function easeQuadOut(t:Float):Float {
        return -t * (t - 2);
    }

    private function easeQuadInOut(t:Float):Float {
        return t <= .5 ? t * t * 2 : 1 - (--t) * t * 2;
    }

    private function easeCubeIn(t:Float):Float {
        return t * t * t;
    }

    private function easeCubeOut(t:Float):Float {
        return 1 + (--t) * t * t;
    }

    private function easeCubeInOut(t:Float):Float {
        return t <= .5 ? t * t * t * 4 : 1 + (--t) * t * t * 4;
    }

    private function easeQuartIn(t:Float):Float {
        return t * t * t * t;
    }

    private function easeQuartOut(t:Float):Float {
        return 1 - (t -= 1) * t * t * t;
    }

    private function easeQuartInOut(t:Float):Float {
        return t <= .5 ? t * t * t * t * 8 : (1 - (t = t * 2 - 2) * t * t * t) / 2 + .5;
    }

    private function easeSineIn(t:Float):Float {
        return -Math.cos(Math.PI / 2 * t) + 1;
    }

    private function easeSineOut(t:Float):Float {
        return Math.sin(Math.PI / 2 * t);
    }

    private function easeSineInOut(t:Float):Float {
        return -Math.cos(Math.PI * t) / 2 + .5;
    }

    private function easeExpoIn(t:Float):Float {
        return Math.pow(2, 10 * (t - 1));
    }

    private function easeExpoOut(t:Float):Float {
        return -Math.pow(2, -10 * t) + 1;
    }

    private function easeExpoInOut(t:Float):Float {
        return t < .5 ? Math.pow(2, 10 * (t * 2 - 1)) / 2 : (-Math.pow(2, -10 * (t * 2 - 1)) + 2) / 2;
    }

    private function easeBackIn(t:Float):Float {
        return t * t * (2.70158 * t - 1.70158);
    }

    private function easeBackOut(t:Float):Float {
        return 1 - (--t) * (t) * (-2.70158 * t - 1.70158);
    }

    private function easeBackInOut(t:Float):Float {
        t *= 2;
        if (t < 1)
            return t * t * (2.70158 * t - 1.70158) / 2;
        t--;
        return (1 - (--t) * (t) * (-2.70158 * t - 1.70158)) / 2 + .5;
    }

    private function easeBounceIn(t:Float):Float {
        return 1 - bounceOut(1 - t);
    }

    private function bounceOut(t:Float):Float {
        if (t < 1 / 2.75) return 7.5625 * t * t;
        if (t < 2 / 2.75) return 7.5625 * (t - 1.5 / 2.75) * (t - 1.5 / 2.75) + 0.75;
        if (t < 2.5 / 2.75) return 7.5625 * (t - 2.25 / 2.75) * (t - 2.25 / 2.75) + 0.9375;
        return 7.5625 * (t - 2.625 / 2.75) * (t - 2.625 / 2.75) + 0.984375;
    }

    private function easeElasticIn(t:Float):Float {
        return -(1 * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - (0.4 / (2 * Math.PI) * Math.asin(1))) * (2 * Math.PI) / 0.4));
    }

    private function easeElasticOut(t:Float):Float {
        return (1 * Math.pow(2, -10 * t) * Math.sin((t - (0.4 / (2 * Math.PI) * Math.asin(1))) * (2 * Math.PI) / 0.4) + 1);
    }

    private function easeElasticInOut(t:Float):Float {
        if (t < 0.5) {
            return -(0.5 * (Math.pow(2, 10 * (t -= 0.5)) * Math.sin((t - (0.4 / 4)) * (2 * Math.PI) / 0.4)));
        }
        return Math.pow(2, -10 * (t -= 0.5)) * Math.sin((t - (0.4 / 4)) * (2 * Math.PI) / 0.4) * 0.5 + 1;
    }
}

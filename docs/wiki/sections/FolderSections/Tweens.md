# Tweens

Tweens are used to move objects with a ease in the game.

```haxe
// import the LfTween class
import leafy.tweens.LfTween;

// create and start a tween 
var tween:LfTween = new LfTween(sprite, LfTweenProperty.X, sprite.x, 200, 3, LfTweenEase.LINEAR, function ():Void {
    // do something when the tween is complete
});

// Cancel the tween
LfTween.cancelTween(tween);
```

--------

See [``LfTween``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/tweens/LfTween.hx)

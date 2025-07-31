# Objects

Objects are used to create graphics, texts, or buttons.

## LfSprite

The ``LfSprite`` class is used to create a sprite, with a image or graphic.

```haxe
// import the LfSprite class
import leafy.objects.LfSprite;

// create a sprite in your state
var sprite:LfSprite = new LfSprite(100, 100);

/*
    Create a graphic
    The ``createGraphic`` function takes 3 parameters, the width, height and the color of the graphic.
*/
sprite.createGraphic(200, 200, [255, 0, 0]);

// Load an image
sprite.loadImage("GAME_PATH/image.png");

// add the sprite to the state
addObject(sprite);
```

--------

## LfText

The ``LfText`` class is used to create a sprite, with a text.

```haxe
// import the LfText class
import leafy.objects.LfText;

// create a text in your state
var text:LfText = new LfText(100, 100, "Hello World!", 32, "GAME_PATH/FONT.ttf");

// add the text to the state
addObject(text);
```

--------

## LfButton

The ``LfButton`` class is used to create a button, with a image or graphic.

```haxe
// import the LfButton class
import leafy.objects.LfButton;

// create a button in your state.
var button:LfButton = new LfButton(100, 100, function():Void {
    // do something
});

/*
    Create a graphic
    The ``createGraphic`` function takes 3 parameters, the width, height and the color of the graphic.
*/
sprite.createGraphic(200, 200, [255, 0, 0]);

// Load an image
sprite.loadImage("GAME_PATH/image.png");

// add the button to the state
addObject(button);
```

--------

See [``LfSprite``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/objects/LfSprite.hx)

See [``LfText``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/objects/LfText.hx)

See [``LfButton``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/objects/LfButton.hx)
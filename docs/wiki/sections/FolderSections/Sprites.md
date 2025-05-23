# Sprites

A sprite is an image or text that can be rendered in the game.

## LfSprite

The ``LfSprite`` class is used to create a sprite, with a image or graphic.

```haxe
// import the LfSprite class
import leafy.objects.LfSprite;

// create a sprite in your state
var sprite:LfSprite = new LfSprite(100, 100);

// create a graphic
// The ``createGraphic`` function takes 3 parameters, the width, height and the color of the graphic.
sprite.createGraphic(200, 200, [255, 0, 0, 255]);

// Load an image
sprite.loadImage("GAME_PATH/image.png");

// add the sprite to the state
addObject(sprite);
```

-----

## LfText

The ``LfText`` class is used to create a text sprite, with a text.

```haxe
// import the LfText class
import leafy.objects.LfText;

// create a text in your state
var text:LfText = new LfText(100, 100, "Hello World!", 32, "GAME_PATH/FONT.ttf");

// add the text to the state
addObject(text);
```

-----
See [``LfSprite``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/objects/LfSprite.hx)

See [``LfText``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/objects/LfText.hx)
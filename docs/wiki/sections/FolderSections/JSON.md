# JSONs

The ``LfJson`` class is used to parse a JSON file or string.

--------

JSON file content Example:

```json
{
    "name": "Slushi",
    "age": 20,
    "hobbies": ["drawing", "comics", "anime"],
}
```

### To parse a JSON file:

```haxe
// import Std for ``Std.int``
import Std;
// import the LfJSON class
import leafy.backend.LfJson;

// access the JSON data
var name:String = new LfJSon("GAME_PATH/file.json").getString("name");
var age:Int = Std.int(new LfJSon("GAME_PATH/file.json").getNumber("age")); // LfJSon.getNumber returns a float
var hobbies:Array<String> = new LfJSon("GAME_PATH/file.json").getArrayString("hobbies");

// Free the JSON object after using it
LfJson.freeJson(json);

// Or free all JSON object after getting the data
var name:String = new LfJSon("GAME_PATH/file.json").getString("name", true);
```

--------

See [``LfJson``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/backend/LfJson.hx)
# JSONs

The ``LfJson`` class is used to parse a JSON file or string.

JSON file content Example:

```json
{
    "name": "John Doe",
    "age": 30,
    "hobbies": ["reading", "coding", "playing video games"],
}
```

To parse a JSON file:

```haxe
import Std;
// import the LfJSON class
import leafy.backend.LfJson;

// parse the JSON file
var json:LeafyJson = LfJson.parseJsonFile("GAME_PATH/file.json");

// access the JSON data
var name:String = LfJson.getStringFromJson(json, "name");
var age:Int = Std.int(LfJson.getNumberFromJson(json, "age"));
var hobbies:Array<String> = LfJson.getArrayStringFromJson(json, "hobbies");

// Free the JSON object after using it
LfJson.freeJson(json);
```

--------

See [``LfJson``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/backend/LfJson.hx)
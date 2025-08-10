// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import Std;
import jansson.Jansson;
import leafy.filesystem.LfSystemPaths;
import leafy.utils.LfStringUtils;

/**
 * JSON parser, loader, and utility functions
 * 
 * Author: Slushi
 */
class LfJson {
    /**
     * Pointer to the JSON object
     */
    private var jsonPtr:Ptr<Json_t>;

    /**
     * JSON error object
     */
    private var jsonError:Json_error_t;

    /**
     * Constructor for LfJson
     * @param json The JSON string or file path
     * @param directJSONObj Optional direct JSON object pointer
     */
    public function new(json:String, ?directJSONObj:Ptr<Json_t> = null) {
        if (directJSONObj != null) {
            this.jsonPtr = directJSONObj;
            this.jsonError = new Json_error_t();
            return;
        }

        this.jsonPtr = null;
        this.jsonError = new Json_error_t();

        if (json == "" || json == null) {
            LeafyDebug.log("JSON cannot be null or empty", ERROR);
            return;
        }

        if (!LfStringUtils.stringEndsWith(json, ".json")) {
            this.jsonPtr = Jansson.json_loads(ConstCharPtr.fromString(json), 0, Syntax.toPointer(this.jsonError));
            if (this.jsonPtr == null) {
                LeafyDebug.log("Error parsing JSON string: " + this.jsonError.text + " (line " + this.jsonError.line + ")", ERROR);
                return;
            }
        }
        else if (LfStringUtils.stringEndsWith(json, ".json")) {
            if (!LfSystemPaths.exists(json)) {
                LeafyDebug.log("JSON file does not exist: " + json, ERROR);
                return;
            }

            this.jsonPtr = Jansson.json_load_file(ConstCharPtr.fromString(json), 0, Syntax.toPointer(this.jsonError));
            if (this.jsonPtr == null) {
                LeafyDebug.log("Error parsing JSON file: " + this.jsonError.text + " (line " + this.jsonError.line + ")", ERROR);
                return;
            }
        }
    }

    /**
     * Free a JSON from the memory
     */
    public function freeJson():Void {
        if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return;
        }

        Jansson.json_decref(this.jsonPtr);
    }

    /////////////////////////////

    /**
     * Get a string from a JSON
     * @param key The key of the object
     * @return String
     */
    public function getString(key:String):String {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return "";
        }
        else if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return "";
        }

        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(this.jsonPtr, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return "";
        }

        if (Jansson.json_is_string(jsonValue) == 0) {
            LeafyDebug.log("Key is not a string: " + key, WARNING);
            return "";
        }

        return Jansson.json_string_value(jsonValue).toString();
    }

    /**
     * Get a number from a JSON
     * @param key The key of the object
     * @return Float (If you need or expect a integer, use Std.int())
     */
    public function getNumber(key:String):Float {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return 0.0;
        }
        else if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return 0.0;
        }

        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(this.jsonPtr, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return 0.0;
        }
    
        if (Jansson.json_is_real(jsonValue) == 0 && Jansson.json_is_integer(jsonValue) == 0) {
            LeafyDebug.log("Key is not a number: " + key, WARNING);
            return 0.0;
        }
    
        return Jansson.json_is_real(jsonValue) == 1
            ? Jansson.json_real_value(jsonValue)
            : Jansson.json_integer_value(jsonValue) * 1.0;
    }
    

    /**
     * Get a boolean from a JSON
     * @param key The key of the object
     * @return Bool
     */
    public function getBoolean(key:String):Bool {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return false;
        }
        else if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return false;
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(this.jsonPtr, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return false;
        }

        if (Jansson.json_is_boolean(jsonValue) == 0) {
            LeafyDebug.log("Key is not a boolean: " + key, WARNING);
            return false;
        }

        return Jansson.json_boolean_value(jsonValue) != 0;
    }
    

    /**
     * Get an array of integers from a JSON
     * @param key The key of the object
     * @return Array<Int>
     */
    public function getArrayInt(key:String):Array<Int> {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return [];
        }
        else if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return [];
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(this.jsonPtr, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return [];
        }

        if (Jansson.json_is_array(jsonValue) == 0) {
            LeafyDebug.log("Key is not an array: " + key, WARNING);
            return [];
        }

        var result:Array<Int> = [];
        var arrayLength:Int = Jansson.json_array_size(jsonValue);
        for (i in 0...arrayLength) {
            var item:Ptr<Json_t> = Jansson.json_array_get(jsonValue, i);
            if (Jansson.json_is_integer(item) == 1) {
                result.push(Jansson.json_integer_value(item));
            }
        }
        return result;
    }

    /**
     * Get an array of floats from a JSON
     * @param key The key of the object
     * @return Array<Float>
     */
    public function getArrayFloat(key:String):Array<Float> {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return [];
        }
        else if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return [];
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(this.jsonPtr, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return [];
        }

        if (Jansson.json_is_array(jsonValue) == 0) {
            LeafyDebug.log("Key is not an array: " + key, WARNING);
            return [];
        }

        var arrayLength:Int = Jansson.json_array_size(jsonValue);
        var result:Array<Float> = [];
        for (i in 0...arrayLength) {
            var item:Ptr<Json_t> = Jansson.json_array_get(jsonValue, i);
            if (Jansson.json_is_real(item) == 1) {
                result.push(Jansson.json_real_value(item));
            }
        }
        return result;
    }

    /**
     * Get an array of strings from a JSON
     * @param key The key of the object
     * @return Array<String>
     */
    public function getArrayString(key:String):Array<String> {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return [];
        }
        else if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return [];
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(this.jsonPtr, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return [];
        }

        if (Jansson.json_is_array(jsonValue) == 0) {
            LeafyDebug.log("Key is not an array: " + key, WARNING);
            return [];
        }

        var arrayLength:Int = Jansson.json_array_size(jsonValue);
        var result:Array<String> = [];
        for (i in 0...arrayLength) {
            var item:Ptr<Json_t> = Jansson.json_array_get(jsonValue, i);
            if (Jansson.json_is_string(item) == 1) {
                result.push(Jansson.json_string_value(item).toString());
            }
        }
        return result;
    }

    /**
     * Get an array of JSON objects from a JSON
     * @param key The key of the object
     * @return Array<LfJson>
     */
    public function getArrayJson(key:String):Array<LfJson> {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return [];
        }
        else if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return [];
        }

        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(this.jsonPtr, ConstCharPtr.fromString(key));
        if (jsonValue == null || Jansson.json_is_array(jsonValue) == 0) {
            LeafyDebug.log("Key not found or not an array: " + key, WARNING);
            return [];
        }

        var array:Array<LfJson> = [];
        var arraySize:Int = Jansson.json_array_size(jsonValue);

        for (i in 0...arraySize) {
            var element:Ptr<Json_t> = Jansson.json_array_get(jsonValue, i);
            if (element != null) {
                array.push(new LfJson("", element));
            } else {
                LeafyDebug.log("Element at index " + i + " is null", WARNING);
            }
        }

        return array;
    }

    /**
     * Get a JSON object from a JSON
     * @param key The key of the object
     * @return LfJson
     */
    public function getObject(key:String):LfJson {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return null;
        }
        else if (this.jsonPtr == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return null;
        }

        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(this.jsonPtr, ConstCharPtr.fromString(key));
        if (jsonValue == null || Jansson.json_is_object(jsonValue) == 0) {
            LeafyDebug.log("Key is not an object or not found: " + key, WARNING);
            return null;
        }

        var jsonResult:LfJson = new LfJson("", jsonValue);

        return jsonResult;
    }
}
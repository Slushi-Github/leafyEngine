// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import Std;
import jansson.Jansson;
import leafy.filesystem.LfSystemPaths;
import leafy.utils.LfStringUtils;

typedef LeafyJson = {
    var json:Ptr<Json_t>;
    var error:Json_error_t;
}

/**
 * JSON parser, loader, and utility functions
 * 
 * Author: Slushi
 */
class LfJson {
    /**
     * Parse a JSON string
     * @param jsonStr 
     * @return LeafyJson
     */
    public static function parseJsonString(jsonStr:String):LeafyJson {
        if (jsonStr == "") {
            LeafyDebug.log("JSON string cannot be null or empty", ERROR);
            return null;
        }

        var rawJSONError:Json_error_t = new Json_error_t();
        var rawJSON:Ptr<Json_t> = Jansson.json_loads(ConstCharPtr.fromString(jsonStr), 0, Syntax.toPointer(rawJSONError));
        if (rawJSON == null) {
            LeafyDebug.log("Error parsing JSON string: " + rawJSONError.text + " (line " + rawJSONError.line + ")", ERROR);
            return null;
        }

        var jsonData:LeafyJson = {
            json: rawJSON,
            error: rawJSONError
        };

        LeafyDebug.log("JSON string loaded successfully", INFO);
        return jsonData;
    }

    /**
     * Parse a JSON file
     * @param jsonPath 
     * @return LeafyJson
     */
    public static function parseJsonFile(jsonPath:String):LeafyJson {
        if (jsonPath == null || jsonPath == "") {
            LeafyDebug.log("JSON file path cannot be null or empty", ERROR);
            return null;
        }

        if (!LfSystemPaths.exists(jsonPath) || !LfStringUtils.stringEndsWith(jsonPath, ".json")) {
            LeafyDebug.log("JSON file does not exist or is not a valid JSON file", ERROR);
            return null;
            
        }
        
        var rawJSONError:Json_error_t = new Json_error_t();
        var rawJSON:Ptr<Json_t> = Jansson.json_load_file(ConstCharPtr.fromString(jsonPath), 0, Syntax.toPointer(rawJSONError));
        if (rawJSON == null) {
            LeafyDebug.log("Error parsing JSON file: " + rawJSONError.text + " (line " + rawJSONError.line + ")", ERROR);
            return null;
        }

        var jsonData:LeafyJson = {
            json: rawJSON,
            error: rawJSONError
        };

        LeafyDebug.log("JSON file loaded successfully: " + jsonPath, INFO);
        return jsonData;
    }

    /**
     * Free a JSON from the memory
     * @param json The parent JSON
     */
    public static function freeJson(json:LeafyJson):Void {
        if (json == null) {
            LeafyDebug.log("JSON object cannot be null", ERROR);
            return;
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return;
        }

        Jansson.json_decref(json.json);
    }

    /////////////////////////////

    /**
     * Get a string from a JSON
     * @param json The parent JSON
     * @param key The key of the object
     * @return String
     */
    public static function getStringFromJson(json:LeafyJson, key:String):String {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return "";
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return "";
        }

        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
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
     * Get an integer from a JSON
     * @param json The parent JSON
     * @param key The key of the object
     * @return Int
     */
    public static function getIntegerFromJson(json:LeafyJson, key:String):Int {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return 0;
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return 0;
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return 0;
        }

        if (Jansson.json_is_integer(jsonValue) == 0) {
            LeafyDebug.log("Key is not an integer: " + key, WARNING);
            return 0;
        }

        return Jansson.json_integer_value(jsonValue);
    }

    /**
     * Get a float from a JSON
     * @param json The parent JSON
     * @param key The key of the object
     * @return Float
     */
    public static function getFloatFromJson(json:LeafyJson, key:String):Float {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return 0.0;
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return 0.0;
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return 0.0;
        }

        if (Jansson.json_is_real(jsonValue) == 0) {
            LeafyDebug.log("Key is not a float: " + key, WARNING);
            return 0.0;
        }

        return Jansson.json_real_value(jsonValue);
    }

    /**
     * Get a boolean from a JSON
     * @param json The parent JSON
     * @param key The key of the object
     * @return Bool
     */
    public static function getBooleanFromJson(json:LeafyJson, key:String):Bool {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return false;
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return false;
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
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
     * @param json The parent JSON
     * @param key The key of the object
     * @return Array<Int>
     */
    public static function getArrayIntegerFromJson(json:LeafyJson, key:String):Array<Int> {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return [];
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return [];
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
        if (jsonValue == null) {
            LeafyDebug.log("Key not found in JSON: " + key, WARNING);
            return [];
        }

        if (Jansson.json_is_array(jsonValue) == 0) {
            LeafyDebug.log("Key is not an array: " + key, WARNING);
            return [];
        }

        var arrayLength:Int = Jansson.json_array_size(jsonValue);
        var result:Array<Int> = [];
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
     * @param json The parent JSON
     * @param key The key of the object
     * @return Array<Float>
     */
    public static function getArrayFloatFromJson(json:LeafyJson, key:String):Array<Float> {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return [];
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return [];
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
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
     * @param json The parent JSON
     * @param key The key of the object
     * @return Array<String>
     */
    public static function getArrayStringFromJson(json:LeafyJson, key:String):Array<String> {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return [];
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return [];
        }
        /////////
        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
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
     * @param json The parent JSON
     * @param key The key of the object
     * @return Array<LeafyJson> The json with the requested object
     */
    public static function getArrayJsonFromJson(json:LeafyJson, key:String):Array<LeafyJson> {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return [];
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return [];
        }

        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
        if (jsonValue == null || Jansson.json_is_array(jsonValue) == 0) {
            LeafyDebug.log("Key not found or not an array: " + key, WARNING);
            return [];
        }

        var array:Array<LeafyJson> = [];
        var arraySize:Int = Jansson.json_array_size(jsonValue);

        for (i in 0...arraySize) {
            var element:Ptr<Json_t> = Jansson.json_array_get(jsonValue, i);
            if (element != null) {
                array.push({
                    json: element,
                    error: new Json_error_t()
                });
            } else {
                LeafyDebug.log("Element at index " + i + " is null", WARNING);
            }
        }

        return array;
    }

    /**
     * Get a JSON object from a JSON
     * @param json The parent JSONThe parent JSON
     * @param key The key of the object
     * @return LeafyJson The json with the requested object
     */
    public static function getObjectFromJson(json:LeafyJson, key:String):LeafyJson {
        if (key == null || key == "") {
            LeafyDebug.log("Key cannot be null or empty", ERROR);
            return null;
        }
        if (json.json == null) {
            LeafyDebug.log("JSON parent is null", ERROR);
            return null;
        }

        var jsonValue:Ptr<Json_t> = Jansson.json_object_get(json.json, ConstCharPtr.fromString(key));
        if (jsonValue == null || Jansson.json_is_object(jsonValue) == 0) {
            LeafyDebug.log("Key is not an object or not found: " + key, WARNING);
            return null;
        }

        var jsonResult:Ptr<Json_t> = jsonValue;
        var leafyJsonResult:LeafyJson = {
            json: jsonValue,
            error: new Json_error_t() 
        };

        return leafyJsonResult;
    }
}
// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.filesystem;

@:cppFileCode("
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

bool CPP_writeFile(const std::string& path, const std::string& content) {
    std::ofstream file(path);
    if (!file) {
        return false;
    }

    file << content;
    return true;
}

bool CPP_appendToFile(const std::string& path, const std::string& content) {
    std::ofstream file(path, std::ios::app); // Abrir en modo append
    if (!file) {
        return false;
    }

    file << content;
    return true;
}

std::string CPP_readFile(const std::string& path) {
    std::ifstream file(path);
    if (!file.is_open()) {
        return \"\"; // Return empty string on error
    }
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}
")

/**
 * A class for working with files
 * 
 * Author: Slushi
 */
class LfFile {
    /**
     * Write content to a file
     * @param path The path to the file
     * @param content The content to write
     * @return Bool (true if the content was written)
    */
    public static function writeFile(path:String, content:String):Bool {
        return untyped __cpp__("CPP_writeFile({0}, {1});", path, content);
    }

    /**
     * Append content to a file
     * @param path The path to the file
     * @param content The content to append
     * @return Bool (true if the content was appended)
    */
    public static function appendToFile(path:String, content:String):Bool {
        return untyped __cpp__("CPP_appendToFile({0}, {1});", path, content);
    }

    /**
     * Read content from a file
     * @param path The path to the file
     * @return String (the content of the file)
    */
    public static function readFile(path:String):String {
        return untyped __cpp__("CPP_readFile({0})", path);
    }
}
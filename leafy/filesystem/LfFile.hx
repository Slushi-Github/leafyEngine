package leafy.filesystem;

@:cppFileCode("
#include <iostream>
#include <fstream>
#include <string>

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
}
// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.filesystem;

import wiiu.SDCardUtil;
import leafy.backend.LeafyDebug;

@:cppFileCode("
#include <string>
#include <iostream>
#include <filesystem>

bool CPP_fileExists(const std::string& path) {
    return std::filesystem::exists(path);
}

bool CPP_createDirectory(const std::string& path) {
    if (!CPP_fileExists(path)) {
        return std::filesystem::create_directory(path);
    }
    return false;
}

bool CPP_deleteFile(const std::string& path) {
    if (CPP_fileExists(path)) {
        return std::filesystem::remove(path);
    }
    return false;
}

bool CPP_removeDirectory(const std::string& path) {
    if (CPP_fileExists(path)) {
        return std::filesystem::remove_all(path);
    }
    return false;
}

bool CPP_isDirectory(const std::string& path) {
    return std::filesystem::is_directory(path);
}

bool CPP_rename(const std::string& currentPath, const std::string& newPath) {
    if (std::filesystem::exists(currentPath)) {
        std::filesystem::rename(currentPath, newPath);
        return true;
    }
    return false;
}

std::shared_ptr<std::deque<std::string>> CPP_listDirectory(const std::string& path) {
    auto content = std::make_shared<std::deque<std::string>>();

    if (std::filesystem::exists(path) && std::filesystem::is_directory(path)) {
        for (const auto& entry : std::filesystem::directory_iterator(path)) {
            content->push_back(entry.path().string());
        }
    }

    return content;
}
")

/**
 * System paths, a class to manage the console file system
 * 
 * Author: Slushi
 */
class LfSystemPaths {
    private static var consolePath:String = "";
    private static var engineMainPath:String = "";

    /**
     * Initialize the file system
     */
    public static function initFSSystem():Void {
        SDCardUtil.prepareSDCard();
        consolePath = SDCardUtil.getSDCardPathFixed();
        LeafyDebug.log("Console path: " + consolePath, INFO);
    }

    /**
     * Shutdown the file system
     */
    public static function deinitFSSystem():Void {
        SDCardUtil.unmountSDCard();
    }

    //////////////////////////////////////////////////////////////

    /**
     * Set the engine main path, relative to the console path
     * @param path
     */
    public static function setEngineMainPath(path:String):Void {
        if (path == "") {
            return;
        }
        engineMainPath = consolePath + path;

        // Check if the path exists and create it if it doesn't
        if (!exists(engineMainPath)) {
            createDirectory(engineMainPath);
        } else {
            if (!isDirectory(engineMainPath)) {
                removeDirectory(engineMainPath);
                createDirectory(engineMainPath);
            }
        }
    }

    /**
     * Get the SD Card path ("/fs/vol/external01/wiiu/")
     */
    public static function getConsolePath():String {
        return consolePath;
    }

    /**
     * Get the engine main path
     */
    public static function getEngineMainPath():String {
        return engineMainPath;
    }

    //////////////////////////////////////////////////////////////

    /**
     * Check if a path exists
     * @param path The path to check
    */
    public static function exists(path:String):Bool {
        return untyped __cpp__("CPP_fileExists({0});", path);
    }

    /**
     * Delete a file
     * @param path The path to the file
     * @return Bool (true if the file was deleted)
    */
    public static function deleteFile(path:String):Bool {
        return untyped __cpp__("CPP_deleteFile({0});", path);
    }

    /**
     * Create a directory
     * @param path The path to the directory
     * @return Bool (true if the directory was created)
    */
    public static function createDirectory(path:String):Bool {
        return untyped __cpp__("CPP_createDirectory({0});", path);
    }

    /**
     * Remove a directory
     * @param path The path to the directory
     * @return Bool (true if the directory was removed)
    */
    public static function removeDirectory(path:String):Bool {
        return untyped __cpp__("CPP_removeDirectory({0});", path);
    }

    /**
     * Check if a path is a directory
     * @param path The directory path to check
     * @return Bool (true if the path is a directory)
    */
    public static function isDirectory(path:String):Bool {
        return untyped __cpp__("CPP_isDirectory({0});", path);
    }

    /**
     * Rename or move a file or directory 
     * @param currentPath The current path of the file or directory
     * @param newPath The new path of the file or directory
     * @return Bool (true if the file or directory was renamed or moved)
    */
    public static function rename(currentPath:String, newPath:String):Bool {
        return untyped __cpp__("CPP_rename({0}, {1});", currentPath, newPath);
    }

    /**
     * List the content of a directory
     * @param path The path to the directory
     * @return Array<String> (the content of the directory)
    */
    public static function listDirectory(path:String):Array<String> {
        return untyped __cpp__("CPP_listDirectory({0});", path);
    }
}
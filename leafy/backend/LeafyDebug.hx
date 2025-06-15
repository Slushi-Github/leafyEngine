// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import haxe.PosInfos; 
import Std;
import cxx.std.Exception;

import wut.coreinit.Debug;

import leafy.filesystem.LfFile;
import leafy.filesystem.LfSystemPaths;
import leafy.utils.LfStringUtils;
import leafy.system.console.SDCard;

/**
 * The log level
 */
enum LogLevel {
    INFO;
    WARNING;
    ERROR;
    DEBUG;
    CRITICAL;
}

@:cppFileCode("
#include <iostream>
#include <csignal>
#include <cstdlib>
#include <ctime>
#include <haxe_PosInfos.h>

std::string CPP_getCurrentDate() {
    time_t t = time(nullptr);
    tm* dateNow = localtime(&t);

    int day = dateNow->tm_mday;
    int month = dateNow->tm_mon + 1;
    int year = dateNow->tm_year + 1900;

    return std::to_string(day) + \"/\" + std::to_string(month) + \"/\" + std::to_string(year);
}

std::string CPP_getCurrentTime() {
    time_t t = time(nullptr);
    tm* timeNow = localtime(&t);

    int hour = timeNow->tm_hour;
    int minute = timeNow->tm_min;
    int second = timeNow->tm_sec;

    return std::to_string(hour) + \":\" + std::to_string(minute) + \":\" + std::to_string(second);
}
")

/**
 * The LeafyDebug class, used to log messages
 * 
 * Author: Slushi
 */
class LeafyDebug {
    /**
     * The path where the logs will be saved
     */
    private static var logsPath:String = "";

    /**
     * The current log file
     */
    private static var currentLogFile:String = "";

    /**
     * The start time of the logger
     */
    private static var startTime:Float = Sys.time();

    /**
     * The elapsed time
     */
    public static var elapsedTime:Float = 0.0;

    /**
     * Whether the logger has started
     */
    private static var started:Bool = false;

    /**
     * // Log a message
     * @param msg The message
     * @param level The log level
     */
    @:include("haxe_PosInfos.h")
    public static function log(msg:String, level:LogLevel, ?pos:PosInfos):Void {
        if (level == LogLevel.CRITICAL) {
            return;
        }

        var formattedMessage:String = prepareText(msg, level, pos);

        if (!started) {
            Sys.println("[Leafy Engine - no logger started] | " + formattedMessage);
            return;
        }

        LfFile.appendToFile(currentLogFile, formattedMessage);
        Sys.println(formattedMessage);
    }

    /**
     * // Log a message before the a crash
     * @param msg The message
     * @param level The log level
     */
    @:include("haxe_PosInfos.h")
    public static function criticalError(msg:String, ?pos:PosInfos):Void {
        crashConsole(msg, pos);
    }

    ///////////////////////////////////////////

    /**
     * // Initialize the logger
     */
    public static function initLogger():Void {
        try {
            SDCard.mountSDCard();
            var logsDir = logsPath = SDCard.getSDCardWiiUPath() + "LeafyLogs/";
            if (!LfSystemPaths.exists(logsDir)) {
                LfSystemPaths.createDirectory(logsDir);
            }
    
            var currentTimeStr:String = untyped __cpp__("CPP_getCurrentTime()");
            var currentTimeMod:String = currentTimeStr;
            currentTimeMod = LfStringUtils.stringReplacer(currentTimeMod, ":", "_");
            currentTimeMod = LfStringUtils.stringReplacer(currentTimeMod, ".", "_");
            currentTimeMod = LfStringUtils.stringReplacer(currentTimeMod, " ", "_");
    
            var currentDateStr:String = untyped __cpp__("CPP_getCurrentDate()");
            var currentDateMod:String = LfStringUtils.stringReplacer(currentDateStr, "/", "_");
    
            var logFile = logsDir + "leafyLog_" + currentTimeMod + "-" + currentDateMod + ".txt";
    
            if (!LfSystemPaths.exists(logFile)) {
                LfFile.writeFile(logFile, "Leafy Engine [" + LfEngine.version + "] Log File\n" + " - " + currentDateStr + " | " + currentTimeStr + "\n-------------------\n\n");
            }
    
            currentLogFile = logFile;
            started = true;
    
            log("Logger initialized!", INFO);
        }
        catch (e:Exception) {
            log("Failed to initialize logger: " + e.what().toString(), ERROR);
        }
    }

    /**
     * Update the elapsed time
     */
    public static function updateLogTime():Void {
        var currentTime:Float = Sys.time();
        var tempTime:Float = currentTime - startTime;
        elapsedTime = Math.fround(tempTime * 10) / 10;
    }

    /**
     * Get the current time
     * @return String
     */
    private static function getCurrentTime():String {
        return untyped __cpp__("CPP_getCurrentTime()");
    }

    /**
     * Get the haxe file position
     * @param pos 
     * @return String
     */
    private static function getHaxeFilePos(pos:PosInfos):String {
        if (pos == null) {
        return "UnknownLocation";
        }

		return pos.className + "/" + pos.methodName + ":" + pos.lineNumber;
	}

    /**
     * Get the haxe file position for crash
     * @param pos 
     * @return String
     */
    private static function getHaxeFilePosForCrash(pos:PosInfos):String {
        if (pos == null) {
        return "UnknownLocation";
        }
        
		return pos.fileName + ":\n\t" + pos.className + "." + pos.methodName + ":" + pos.lineNumber;
	}

    /**
     * Prepare the text to be logged
     * @param text 
     * @param logLevel 
     * @param pos 
     * @return String
     */
    private static function prepareText(text:String, logLevel:LogLevel, ?pos:PosInfos):String {
        var str:String = "";
        var levelStr:String = "";

        switch (logLevel) {
            case LogLevel.INFO:
                levelStr = "INFO";
            case LogLevel.WARNING:
                levelStr = "WARNING";
            case LogLevel.ERROR:
                levelStr = "ERROR";
            case LogLevel.DEBUG:
                levelStr = "DEBUG";
            case LogLevel.CRITICAL:
                levelStr = "CRITICAL";
        }

        str += "[" + getCurrentTime() + " (" + elapsedTime + ") | " + levelStr + " - " + getHaxeFilePos(pos) + "] " + text + "\n";
        return str;
    }

    /**
     * Crash the Wii U showing a crash message
     * @param crashError 
     * @param pos 
     */
    private static function crashConsole(crashError:String, ?pos:PosInfos):Void {
        var strPtr:ConstCharPtr = ConstCharPtr.fromString("[Leafy Engine " + LfEngine.version + " logger - " + getCurrentTime()
        + " - CRASH]\n\nCall stack:\n" + getHaxeFilePosForCrash(pos) + "\n\nError: " + crashError
		+ "\n\n\n\t\t    Please reset the console.");

        LfFile.appendToFile(currentLogFile, "---------------------");
        log("CRASH: " + crashError, ERROR, pos);
        log("Stopping the engine and console due to crash...", ERROR, pos);

        Debug.OSFatal(strPtr);
    }
}
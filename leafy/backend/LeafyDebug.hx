// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import haxe.PosInfos; 
import Std;
import cxx.std.Exception;
import haxe.Exception;
import haxe.CallStack;

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
    public static function log(msg:String = "", level:LogLevel = LogLevel.INFO, ?pos:PosInfos):Void {
        #if !debug
        if (level == LogLevel.DEBUG) {
            return;
        }
        #end

        var formattedMessage:String = prepareText(msg, level, pos);

        // Log to the Wii U console debug output (Maybe "/storage_slc/sys/logs"?)
        switch (level) {
            case LogLevel.INFO:
                Debug.OSReportInfo(ConstCharPtr.fromString(formattedMessage));
            case LogLevel.WARNING:
                Debug.OSReportWarn(ConstCharPtr.fromString(formattedMessage));
            case LogLevel.ERROR:
                Debug.OSReportWarn(ConstCharPtr.fromString(formattedMessage));
            case LogLevel.DEBUG:
                Debug.OSReportVerbose(ConstCharPtr.fromString(formattedMessage));
            default:
                Debug.OSReportInfo(ConstCharPtr.fromString(formattedMessage));
        }

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
                var hxcuDefinedVersion:String = untyped __cpp__("HXCOMPILEU_VERSION");
                var hxcuDefinedDate:String = untyped __cpp__("HXCOMPILEU_HAXE_APPROXIMATED_COMPILATION_DATE");
                LfFile.writeFile(logFile, "Leafy Engine [" + LfEngine.VERSION + "] Log File\n" + " - " + currentDateStr + " | " + currentTimeStr + "\n - Compilated with HxCompileU v" + hxcuDefinedVersion + "\n - Aproximate CPP compilation date: " + hxcuDefinedDate + "\n-------------------\n\n");
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
        return "UnknownPosition";
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
        return "UnknownPosition";
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
        var strPtr:ConstCharPtr = ConstCharPtr.fromString("[Leafy Engine " + LfEngine.VERSION + " logger - " + getCurrentTime()
        + " - CRASH]\n\nCall stack:\n" + getHaxeFilePosForCrash(pos) + "\n\nError: " + crashError
		+ "\n\n\n\t\t    Please reset the console.");

        LfFile.appendToFile(currentLogFile, "\n---------------------\n");
        log("CRASH: " + crashError, ERROR, pos);
        log("Call stack:\n\t" + getHaxeFilePosForCrash(pos), ERROR, pos);
        log("Executing WUT OSFatal call for crash...", ERROR, pos);

        Debug.OSFatal(strPtr);
    }

    /**
     * A crash handler that logs the Haxe call stack and error message
     * @param e The error message 
     */
    public static function crashHandler(e:String):Void {
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
        var callStackText:String = "Call stack:\n";

        for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					callStackText += file + ":" + line + "\n";
				case CFunction:
					callStackText += "Non-Haxe (C++) Function";
				case Module(c):
					callStackText += 'Module ${c}';
				default:
					callStackText += "Unknown stack item: " + Std.string(stackItem) + "\n";
			}
		}

        callStackText += "\nError: " + LfStringUtils.stringReplacer(e, "Error: ", "");
        LfFile.appendToFile(currentLogFile, "\n-- CRASH ------------\n");
        LfFile.appendToFile(currentLogFile, callStackText);
        LfFile.appendToFile(currentLogFile, "\n---------------------\n");
        LfFile.appendToFile(currentLogFile, "On real hardware, please check \"/storage_slc/sys/logs\" for more CafeOS info about this crash.\n");
        LfFile.appendToFile(currentLogFile, "Executing WUT OSFatal function for crash the console...");
        Debug.OSFatal(ConstCharPtr.fromString("[Leafy Engine " + LfEngine.VERSION + " logger - " + getCurrentTime() + " - CRASH]\n\n" + callStackText + "\n\n---------\n\nCheck the Leafy Engine log file for more info.\n"));
    }
}
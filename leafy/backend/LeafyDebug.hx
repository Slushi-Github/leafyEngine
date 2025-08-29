// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.backend;

import leafy.utils.LfUtils;
import Std;

import wut.coreinit.Debug;
import wut.coreinit.Memory;

import haxe.PosInfos; 
import haxe.Exception;
import haxe.CallStack;

import cxx.std.Exception;

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

#include \"coreinit/exception.h\"
#include \"coreinit/context.h\"

/**
 * Get the current date in the format DD/MM/YYYY
 */
std::string CPP_getCurrentDate() {
    time_t t = time(nullptr);
    tm* dateNow = localtime(&t);

    int day = dateNow->tm_mday;
    int month = dateNow->tm_mon + 1;
    int year = dateNow->tm_year + 1900;

    return std::to_string(day) + \"/\" + std::to_string(month) + \"/\" + std::to_string(year);
}

/**
 * Get the current time in the format HH:MM:SS
 */
std::string CPP_getCurrentTime() {
    time_t t = time(nullptr);
    tm* timeNow = localtime(&t);

    int hour = timeNow->tm_hour;
    int minute = timeNow->tm_min;
    int second = timeNow->tm_sec;

    return std::to_string(hour) + \":\" + std::to_string(minute) + \":\" + std::to_string(second);
}

///////////////////////////////////////////////////

/**
 * A custom crash handler for the Wii U
 * This function is called when a crash occurs in the system.
 * 
 * Part of this code is extracted from the conversion from Haxe to C++ made by Reflaxe/C++.
 */
static BOOL CPP_wutCrashHandler(OSContext* context) {
	uint32_t crash_addr = context->srr0;

	std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> callStack = haxe::_CallStack::CallStack_Impl_::exceptionStack(true);
	std::string callStackText = \"Haxe call stack:\\n\"s;
	int _g = 0;

	while(_g < (int)(callStack->size())) {
		std::shared_ptr<haxe::StackItem> stackItem = (*callStack)[_g];
		++_g;

		switch(stackItem->index) {
			case 0: {
				callStackText += \"Non-Haxe (C++) Function\"s;
				break;
			}
			case 1: {
				std::string _g2 = stackItem->getModule().m;
				callStackText += \"Module \"s + _g2;
				break;
			}
			case 2: {
				std::optional<std::shared_ptr<haxe::StackItem>> _g2 = stackItem->getFilePos().s;
				std::string _g1 = stackItem->getFilePos().file;
				int _g3 = stackItem->getFilePos().line;
				{
					std::optional<std::shared_ptr<haxe::StackItem>> s = _g2;
					std::string file = _g1;
					int line = _g3;

					callStackText += file + \":\"s + std::to_string(line) + \"\\n\"s;
				};
				break;
			}
			default: {
				callStackText += \"Unknown stack item: \"s + Std::string(stackItem) + \"\\n\"s;
				break;
			}
		};
	};

	callStackText += \"\\nPowerPC crash address: \"s + Std::string(crash_addr);
	leafy::filesystem::LfFile::appendToFile(leafy::backend::LeafyDebug::currentLogFilePath, \"\\n-- CRASH (By CafeOS exception handler) ------------\\n\"s);

	leafy::filesystem::LfFile::appendToFile(leafy::backend::LeafyDebug::currentLogFilePath, callStackText);
	leafy::filesystem::LfFile::appendToFile(leafy::backend::LeafyDebug::currentLogFilePath, \"\\n---------------------\\n\"s);
	leafy::filesystem::LfFile::appendToFile(leafy::backend::LeafyDebug::currentLogFilePath, \"On real hardware, please check \\\"/storage_slc/sys/logs\\\" for more CafeOS info about this crash.\\n\"s);
	leafy::filesystem::LfFile::appendToFile(leafy::backend::LeafyDebug::currentLogFilePath, \"You can use \\\"haxeCompileU --searchProblem \"s + Std::string(crash_addr) + \"\\\" to search for the crash line in the CPP source code.\\n\"s);
	leafy::filesystem::LfFile::appendToFile(leafy::backend::LeafyDebug::currentLogFilePath, \"Executing WUT OSFatal function for crash the console...\"s);

	const char* tempConstCharPtr;
	{
		std::string s = \"[Leafy Engine \"s + leafy::LfEngine::VERSION + \" logger - \"s + leafy::backend::LeafyDebug::getCurrentTime() + \" - CRASH (By CafeOS exception handler)]\\n\\n\"s + callStackText + \"\\n\\n---------\\n\\nCheck the Leafy Engine log file for more info.\\n\"s;

		tempConstCharPtr = s.c_str();
	};

	OSFatal(tempConstCharPtr);

	return TRUE;
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
    private static var currentLogFilePath:String = "";

    /**
     * The start time of the logger
     */
    private static var startTime:Float = Sys.time();

    /**
     * Whether the logger has started
     */
    private static var started:Bool = false;

    /**
     * The elapsed time
     */
    public static var elapsedTime:Float = 0.0;

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

        LfFile.appendToFile(currentLogFilePath, formattedMessage);
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

    public static function printToLogFileOnly(msg:String):Void {
        if (!started) {
            return;
        }

        LfFile.appendToFile(currentLogFilePath, msg);
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
    
            var currentTimeStr:String = getCurrentTime();
            var currentTimeMod:String = currentTimeStr;
            currentTimeMod = LfStringUtils.stringReplacer(currentTimeMod, ":", "_");
            currentTimeMod = LfStringUtils.stringReplacer(currentTimeMod, ".", "_");
            currentTimeMod = LfStringUtils.stringReplacer(currentTimeMod, " ", "_");

            var currentDateStr:String = getCurrentDate();
            var currentDateMod:String = LfStringUtils.stringReplacer(currentDateStr, "/", "_");

            var hxcuProjectName:String = LfUtils.getHxCUMetadata().projectName;
            var logFile = logsDir + hxcuProjectName + "_leafyLog_" + currentTimeMod + "-" + currentDateMod + ".txt";

            if (!LfSystemPaths.exists(logFile)) {
                var hxcuDefinedVersion:String = LfUtils.getHxCUMetadata().version;
                var hxcuDefinedDate:String = LfUtils.getHxCUMetadata().date;

                LfFile.writeFile(logFile, "Leafy Engine [" + LfEngine.VERSION + "] Log File\n" + " - " + currentDateStr + " | " + currentTimeStr + "\n - HxCompileU project name: " + hxcuProjectName + "\n - Compilated with HxCompileU v" + hxcuDefinedVersion + "\n - Aproximate CPP compilation date: " + hxcuDefinedDate + "\n-------------------\n\n");
            }
    
            currentLogFilePath = logFile;
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
     * Get the current time
     * @return String
     */
    private static function getCurrentDate():String {
        return untyped __cpp__("CPP_getCurrentDate()");
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
        LfFile.appendToFile(currentLogFilePath, "\n-- INTENTIONAL CRASH -------------------\n");
        LfFile.appendToFile(currentLogFilePath, "Call stack:\n" + getHaxeFilePosForCrash(pos) + "\n\n");
        LfFile.appendToFile(currentLogFilePath, "Error: " + crashError + "\n");
        LfFile.appendToFile(currentLogFilePath, "\n---------------------\n");
        LfFile.appendToFile(currentLogFilePath, "Executing WUT OSFatal function for crash the console...");

        Debug.OSFatal(ConstCharPtr.fromString("[Leafy Engine " + LfEngine.VERSION + " logger - " + getCurrentTime()
        + " - CRASH]\n\nCall stack:\n" + getHaxeFilePosForCrash(pos) + "\n\nError: " + crashError
		+ "\n\n\n\t\t    Please reset the console."));
    }

    /**
     * A crash handler from "Haxe" side that logs the Haxe call stack and error message
     * @param e The error message 
     */
    public static function hxCrashHandler(e:String):Void {
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
        LfFile.appendToFile(currentLogFilePath, "\n-- CRASH ------------\n");
        LfFile.appendToFile(currentLogFilePath, callStackText);
        LfFile.appendToFile(currentLogFilePath, "\n---------------------\n");
        LfFile.appendToFile(currentLogFilePath, "On real hardware, please check \"/storage_slc/sys/logs\" for more CafeOS info about this crash.\n");
        LfFile.appendToFile(currentLogFilePath, "Executing WUT OSFatal function for crash the console...");
        Debug.OSFatal(ConstCharPtr.fromString("[Leafy Engine " + LfEngine.VERSION + " logger - " + getCurrentTime() + " - CRASH]\n\n" + callStackText + "\n\n---------\n\nCheck the Leafy Engine log file for more info.\n"));
    }

    /*
     * Initialize the custom Wii U crash handler
     * This is managed by own CafeOS exception handler
     */
    public static function initWUTCrashHandler() {
        Debug.OSReportInfo(ConstCharPtr.fromString("[Leafy Engine - no logger started] | Initializing custom CafeOS crash handler..."));
        untyped __cpp__("OSSetExceptionCallbackEx(OS_EXCEPTION_MODE_GLOBAL, OS_EXCEPTION_TYPE_PROGRAM, CPP_wutCrashHandler)");
        Debug.OSReportInfo(ConstCharPtr.fromString("[Leafy Engine - no logger started] | Custom CafeOS crash handler initialized!"));
    }

    /**
     * Prints the used RAM in the log file
     * @return String
     */
    private static function printUsedRAM():Void {
        var ramTotal:UInt32 = 0;
        var ramFree:UInt32 = 0;

        var ramTotalStr:String = "";
        if (Memory.OSGetForegroundBucket(untyped __cpp__("NULL"), Syntax.toPointer(ramTotal)) && Memory.OSGetForegroundBucketFreeArea(untyped __cpp__("NULL"), Syntax.toPointer(ramFree))) {
            var usedRam:UInt32 = ramTotal - ramFree;
            var percent:Float = (ramTotal > 0) ? (100.0 * usedRam / ramTotal) : 0.0;
            ramTotalStr = "Wii U RAM: " + Std.string(usedRam / (1024 * 1024)) + " MB used -- " + Std.string(ramTotal / (1024 * 1024)) + " MB total assigned (" + Std.string(percent) + "% used)\n";
        }
        else {
            ramTotalStr = "Wii U RAM: Unable to retrieve RAM usage information.\n";
        }

        LfFile.appendToFile(currentLogFilePath, "\n-- FINAL Wii U RAM Usage -------------------\n");
        LfFile.appendToFile(currentLogFilePath, ramTotalStr);
        LfFile.appendToFile(currentLogFilePath, "---------------------\n");
    }
}
# Debugging the engine

Leafy Engine isn't really stable, is it? So you need to know what goes wrong when a crash occurs, whether in an emulator or on the actual hardware. The engine provides you with some tools to make that easier.

## Using the debugger

With ``leafy.backend.LeafyDebug``, the debugger is used for logs that are saved in the “leafyLogs” folder in ``/fs/vol/external01/wiiu/``.

```haxe
import leafy.backend.LeafyDebug;

// log a message
LeafyDebug.log("Hello world!", LogLevel.INFO);

// log an error
LeafyDebug.log("Error: something went wrong", LogLevel.ERROR);
```

--------

If there is something you did that, in case of failure, should prevent the program from continuing, there is a function to stop the console and display an error on the screen, as well as saving it in the log file.

```haxe
import leafy.backend.LeafyDebug;

// stop the console
LeafyDebug.criticalError("something went wrong");
```

--------

## The crash handler

The crash handler is used when the engine crashes. The crash handler is used to log the Haxe call stack and error message in the log file and display it on the screen, This should not be used directly, automatically when a critical error occurs, the crash handler appears.
#### Note: The crash handler in Leafy Engine is considered to be truly experimental, so I cannot guarantee that it will work properly in every case of an error that may occur at runtime.
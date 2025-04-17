package leafy.filesystem;

/**
 * A class for working with the engine files, like assets for a game
 * 
 * Author: Slushi
 */
class LfEngineFS {
    private static var engineFolders:Map<String, String> = [
        "assets" => LfSystemPaths.getEngineMainPath() + "/assets",
        "assets/data" => LfSystemPaths.getEngineMainPath() + "/assets/data",
        "assets/images" => LfSystemPaths.getEngineMainPath() + "/assets/images",
        "assets/sounds" => LfSystemPaths.getEngineMainPath() + "/assets/sounds",
        "assets/music" => LfSystemPaths.getEngineMainPath() + "/assets/music",
        "assets/textures" => LfSystemPaths.getEngineMainPath() + "/assets/textures",
        "assets/fonts" => LfSystemPaths.getEngineMainPath() + "/assets/fonts"
    ];

    /**
     * Get a folder from the engine
     * @param folderName The name of the folder
     * @return String The folder
     */
    public static function getEngineFolder(folderName:String):String {
        return engineFolders[folderName];
    }

    //////////////////////////////////////////////////////////////////

    /**
     * Get an asset from the ``assets`` folder of the engine
     * @param file The name of the file
     * @return String The file
     */
    public static function getAsset(file:String):String {
        return engineFolders["assets"] + "/" + file;
    }

    /**
     * Get an asset from the ``assets/data`` folder of the engine
     * @param file The name of the file
     * @return String The file
     */
    public static function getDataAsset(file:String):String {
        return engineFolders["assets/data"] + "/" + file;
    }

    /**
     * Get an asset from the ``assets/images`` folder of the engine
     * @param file The name of the file
     * @return String The file
     */
    public static function getImageAsset(file:String):String {
        return engineFolders["assets/images"] + "/" + file;
    }

    /**
     * Get an asset from the ``assets/sounds`` folder of the engine
     * @param file The name of the file
     * @return String The file
     */
    public static function getSoundAsset(file:String):String {
        return engineFolders["assets/sounds"] + "/" + file;
    }

    /**
     * Get an asset from the ``assets/music`` folder of the engine
     * @param file The name of the file
     * @return String The file
     */
    public static function getMusicAsset(file:String):String {
        return engineFolders["assets/music"] + "/" + file;
    }

    /**
     * Get an asset from the ``assets/textures`` folder of the engine
     * @param file The name of the file
     * @return String The file
     */
    public static function getTextureAsset(file:String):String {
        return engineFolders["assets/textures"] + "/" + file;
    }

    /**
     * Get an asset from the ``assets/fonts`` folder of the engine
     * @param file The name of the file
     * @return String The file
     */
    public static function getFontAsset(file:String):String {
        return engineFolders["assets/fonts"] + "/" + file;
    }

    //////////////////////////////////////////////////////////////////
}
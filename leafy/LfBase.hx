// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy;

/**
 * Base class for Leafy objects
 */
class LfBase {
    /**
     * Function to be executed when creating this class
     */
    public function new() {}

    /**
     * Function to be executed when creating this class
     */
    public function create():Void {
        // Create logic here
    }

    /**
     * Function to be executed when updating this class
     */
    public function update(elapsed:Float):Void {
        // Update logic here
    }

    /**
     * Function to be executed when rendering this class
     */
    public function render():Void {
        // Render logic here
    } 

    /**
     * Function to be executed when destroying this class
     */
    public function destroy():Void {
        // Destroy logic here
    }
}
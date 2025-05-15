// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.states;

import haxe.ds.List;
import Std;
import leafy.objects.LfObject;
import leafy.gamepad.LfGamepad;

/**
 * Base class for Leafy states
 * 
 * Author: Slushi
 */
class LfState extends LfBase {
    /**
     * The list of objects in the state
     */
    public var stateObjects:List<LfObject> = new List<LfObject>();

    public function new() {
        super();
    }

    /////////////////////////////////

    /**
     * Function called when the state is initialized
     */
    override public function create():Void {
        for (object in this.stateObjects) {
            object.create();
        }
    }

    /**
     * Function called when the state is updated
     * @param elapsed The elapsed time
     */
    override public function update(elapsed:Float):Void {
        for (object in this.stateObjects) {
            object.update(elapsed);
        }
    }


    /**
     * /* Function called when the state is rendered
     */
    override public function render():Void {
        for (obj in this.stateObjects) {
            if (untyped __cpp__("obj != nullptr")) {
                // Check if the object has a camera, if it does, skip
                // if (obj.camera != null) {
                //     continue;
                // }
                obj.render();
            }
        }
    }
    
    /**
     * Function called when the state is destroyed
     */
    override public function destroy():Void {
        for (object in this.stateObjects) {
            if (object == null) {
                LeafyDebug.log("Object [" + Std.string(object) + "] is null, skipping", WARNING);
                continue;
            }
            object.destroy();
        }

        this.stateObjects.clear();
    }
    
    /////////////////////////////////

    /**
     * Function to add an object to the state
     * @param object The object to add
     */
    public function addObject(object:LfObject):Void {
        if (object == null) {
            return;
        }

        // if (object.camera == null) {
        //     Leafy.camera.addObjToCam(object);
        // }

        this.stateObjects.add(object);
    }

    /**
     * Function to remove an object from the state
     * @param object The object to remove
     */
    public function removeObject(object:LfObject):Void {
        this.stateObjects.remove(object);
    }
}
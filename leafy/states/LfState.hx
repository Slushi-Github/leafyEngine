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
    public var stateObjects:Array<LfObject> = new Array<LfObject>();

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
        if (this.stateObjects == []) {
            return;
        }

        for (obj in this.stateObjects) {
            if (untyped __cpp__("obj != nullptr")) {
                obj.render();
            }
        }
    }
    
    /**
     * Function called when the state is destroyed
     */
    override public function destroy():Void {
        if (this.stateObjects == []) {
            return;
        }

        for (object in this.stateObjects) {
            if (object == null) {
                LeafyDebug.log("Object [" + Std.string(object) + "] is null, skipping", WARNING);
                continue;
            }
            object.destroy();
        }

        this.stateObjects.pop();
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

        this.stateObjects.push(object);
    }

    /**
     * Function to remove an object from the state
     * @param object The object to remove
     */
    public function removeObject(object:LfObject):Void {
        untyped __cpp__("
for (size_t i = 0; i < stateObjects->size(); i++) {
    auto obj = stateObjects->at(i);
    if (obj == object) {
        stateObjects->erase(stateObjects->begin() + i);
        return;
    }
}
        ");

        
    }
}
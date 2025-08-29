// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.states;

import haxe.Unserializer.TypeResolver;
import Std;

import leafy.objects.LfObject;

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

    /**
     * The sub-state of the state
     */
    public var subState:LfSubState = null;

    // /**
    //  * Whether the state should keep updating
    //  */
    // public var keepUpdating:Bool = true;

    // /**
    //  * Whether the state should keep rendering
    //  */
    // public var keepRendering:Bool = true;

    public function new() {
        super();
    }

    /////////////////////////////////

    /**
     * Function called when the state is initialized
     */
    override public function create():Void {
        for (object in this.stateObjects) {
            if (untyped __cpp__("object != nullptr")) {
                object.create();
            }
        }
    }

    /**
     * Function called when the state is updated
     * @param elapsed The elapsed time
     */
    override public function update(elapsed:Float):Void {
        // if (!keepUpdating) {
        //     return;
        // }

        for (object in this.stateObjects) {
            if (untyped __cpp__("object != nullptr")) {
                object.update(elapsed);
            }
        }

        if (untyped __cpp__("subState != NULL")) {
            this.subState.update(elapsed);
        }
    }

    /**
     * Function called when the state is rendered
     */
    override public function render():Void {
        // if (!keepRendering) {
        //     return;
        // }

        if (this.stateObjects == []) {
            return;
        }

        for (obj in this.stateObjects) {
            if (untyped __cpp__("obj != nullptr")) {
                obj.render();
            }
        }

        if (untyped __cpp__("subState != NULL")) {
            this.subState.render();
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
            if (untyped __cpp__("object == nullptr")) {
                LeafyDebug.log("Object [" + Std.string(object) + "] is null, skipping", WARNING);
                continue;
            }
            object.destroy();
        }

        if (untyped __cpp__("subState != NULL")) {
            this.subState.destroy();
        }

        this.stateObjects.pop();
    }
    
    /////////////////////////////////

    /**
     * Function to add an object to the state
     * @param object The object to add
     */
    public function addObject(object:LfObject):Void {
        if (untyped __cpp__("object == nullptr")) {
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
if (object == nullptr) {
    return;
}
    
for (size_t i = 0; i < stateObjects->size(); i++) {
    auto obj = stateObjects->at(i);
    if (obj == object) {
        stateObjects->erase(stateObjects->begin() + i);
        return;
    }
}
        ");
    }

    /**
     * Function to set the sub-state of the state
     * @param newSubState The new sub-state to set
     */
    public function setSubState(newSubState:LfSubState):Void {
        if (newSubState == null) {
            return;
        }

        if (untyped __cpp__("subState != NULL")) {
            this.subState.destroy();
        }

        this.subState = newSubState;
        if (untyped __cpp__("subState != NULL")) {
            this.subState.create();
        }
    }

    /**
     * Function to get the sub-state of the state
     * @return The current sub-state
     */
    public function getSubState():LfSubState {
        return this.subState;
    }
}
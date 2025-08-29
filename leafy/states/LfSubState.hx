// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.states;

import Std;

import leafy.objects.LfObject;

/**
 * Base class for Leafy sub-states
 * 
 * Author: Slushi
 */
class LfSubState extends LfBase {
    /**
     * The list of objects in the subState
     */
    public var subStateObjects:Array<LfObject> = new Array<LfObject>();

    /**
     * Whether the subState is visible
     */
    public var isVisible:Bool = false;

    /**
     * Whether the subState is active
     */
    public var isActive:Bool = true;

    public function new() {
        super();
    }

    /////////////////////////////////

    /**
     * Function called when the subState is initialized
     */
    override public function create():Void {
        for (object in this.subStateObjects) {
            if (untyped __cpp__("object != nullptr")) {
                object.create();
            }
        }

        this.isVisible = true;
    }

    /**
     * Function called when the subState is updated
     * @param elapsed The elapsed time
     */
    override public function update(elapsed:Float):Void {
        if (!isActive) {
            return;
        }

        for (object in this.subStateObjects) {
            if (untyped __cpp__("object != nullptr")) {
                object.update(elapsed);
            }
        }
    }

    /**
     * Function called when the subState is rendered
     */
    override public function render():Void {
        if (!isVisible) {
            return;
        }
        else if (!isActive) {
            return;
        }

        if (this.subStateObjects == []) {
            return;
        }

        for (obj in this.subStateObjects) {
            if (untyped __cpp__("obj != nullptr")) {
                obj.render();
            }
        }
    }
    
    /**
     * Function called when the subState is destroyed
     */
    override public function destroy():Void {
        if (this.subStateObjects == []) {
            return;
        }

        for (object in this.subStateObjects) {
            if (untyped __cpp__("object == nullptr")) {
                LeafyDebug.log("Object [" + Std.string(object) + "] is null, skipping", WARNING);
                continue;
            }
            object.destroy();
        }

        this.subStateObjects.pop();
    }
    
    /////////////////////////////////

    /**
     * Function to add an object to the subState
     * @param object The object to add
     */
    public function addObject(object:LfObject):Void {
        if (untyped __cpp__("object == nullptr")) {
            return;
        }

        this.subStateObjects.push(object);
    }

    /**
     * Function to remove an object from the subState
     * @param object The object to remove
     */
    public function removeObject(object:LfObject):Void {
        untyped __cpp__("
if (object == nullptr) {
    return;
}

for (size_t i = 0; i < subStateObjects->size(); i++) {
    auto obj = subStateObjects->at(i);
    if (obj == object) {
        subStateObjects->erase(subStateObjects->begin() + i);
        return;
    }
}
        ");
    }
}
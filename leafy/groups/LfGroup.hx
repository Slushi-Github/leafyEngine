// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package leafy.groups;

import Std;
import haxe.ds.List;
import leafy.objects.LfObject;

/**
 * A group of objects, used to manage multiple objects at once
 */
class LfGroup extends LfObject {
    /**
     * List of objects in the group
     */
    public var objectsList:Array<LfObject>;

    /**
     * The length of the group
     */
    public var length(default, null):Int = 0;

    /**
     * Create a new group
     */
    public function new() {
        super();

        objectsList = new Array<LfObject>();
    }

    /**
     * Add an object to the group
     * @param item The object to add
     */
    public function add(item:LfObject):Void {
        
        if (item != null && !objectsList.contains(item)) {
            objectsList.push(item);
        }

        this.length = objectsList.length;
    }

    /**
     * Remove an object from the group
     * @param item The object to remove
     */
    public function remove(item:LfObject):Void {
        if (item == null) {
            return;
        }

        objectsList.remove(item);
        this.length = objectsList.length;
    }

    override public function create():Void {
        super.create();

        for (obj in objectsList) {
            if (obj == null) {
                continue;
            }
            obj.create();
        }
    }

    override public function update(elapsed:Float):Void {
        for (obj in objectsList) {
            if (obj == null) {
                continue;
            }
            obj.update(elapsed);
        }
    }

    override public function render():Void {
        for (obj in objectsList) {
            if (obj == null) {
                continue;
            }
            obj.render();
        }
    }

    override public function destroy():Void {
        super.destroy();

        for (obj in objectsList) {
            if (obj == null) {
                continue;
            }
            obj.destroy();
        }
    }
}
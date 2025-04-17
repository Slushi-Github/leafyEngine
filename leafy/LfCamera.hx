package leafy;

import leafy.objects.LfObject;
import leafy.utils.LfUtils.LfVector2D;

class LfCamera extends LfBase {
//     private static var camObjects:Array<LfObject> = new Array<LfObject>();

//     /**
//      * The x position of the camera
//      */
//     public var x:Int = 0;

//     /**
//      * The y position of the camera
//      */
//     public var y:Int = 0;

//     /**
//      * The zoom of the camera
//      */
//     public var zoom:Float = 1;

//     /**
//      * The angle of the camera
//      */
//     public var angle:Float = 0;

//     public function new() {
//         super();
//     }

//     override public function render():Void {
//         for (obj in camObjects) {
//             if (obj != null) {
//                 obj.render();
//             }
//         }
//     }

//     override public function destroy():Void {
//         camObjects = null;
//     }

//     public function addObjToCam(object:LfObject):Void {
//         if (object == null) {
//             return;
//         }
//         object.camera = this;
//         camObjects.push(object);
//     }

//     public function removeObjFromCam(object:LfObject):Void {
//         untyped __cpp__("
// for (size_t i = 0; i < camObjects->size(); i++) {
//     auto obj = camObjects->at(i);
//     if (obj == object) {
//         obj->destroy();
//         camObjects->erase(camObjects->begin() + i);
//         return;
//     }
// }");
//     }
}
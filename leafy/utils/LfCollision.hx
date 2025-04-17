package leafy.utils;

import Std;

import leafy.objects.LfSprite;

class LfCollision {
    public static function checkCollision(a:LfSprite, b:LfSprite):Bool {
        return (a.x < b.x + b.width &&
                a.x + a.width > b.x &&
                a.y < b.y + b.height &&
                a.y + a.height > b.y);
    }

    public static function separate(a:LfSprite, b:LfSprite):Void {
    if (!checkCollision(a, b)) return;

    var overlapX = 0.0;
    var overlapY = 0.0;

    var aCenterX = a.x + a.width / 2;
    var bCenterX = b.x + b.width / 2;
    var aCenterY = a.y + a.height / 2;
    var bCenterY = b.y + b.height / 2;

    // Calcular la superposición en X
    if (aCenterX < bCenterX)
        overlapX = (a.x + a.width) - b.x;
    else
        overlapX = a.x - (b.x + b.width);

    // Calcular la superposición en Y
    if (aCenterY < bCenterY)
        overlapY = (a.y + a.height) - b.y;
    else
        overlapY = a.y - (b.y + b.height);

    // Separar en el eje con menos solapamiento
    if (Math.abs(overlapX) < Math.abs(overlapY)) {
        a.x -= Std.int(overlapX);
        a.velocity.x = 0;
    } else {
        a.y -= Std.int(overlapY);
        a.velocity.y = 0;
    }
}

}
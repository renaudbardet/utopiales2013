package utopiales2013;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Canvas;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import utopiales2013.Ghost;
import utopiales2013.Hero;

/**
 * ...
 * @author Lythom
 */
class Vision extends Entity
{
	private var _detectionDistance:Int;
	private var _moveSpanX:Float;
	private var _moveSpanY:Float;
	private var _ghost:Ghost;
	var canvasH:Canvas;
	var canvasV:Canvas;
	
	private static var TOLERANCE:Int = 2;

	public function new(ghost:Ghost, detectionDistance:Int, moveSpanX:Float, moveSpanY:Float)
	{
		_ghost = ghost;
		_detectionDistance = detectionDistance;
		_moveSpanX = moveSpanX;
		_moveSpanY = moveSpanY;
		
		canvasH = new Canvas(Math.ceil(detectionDistance * moveSpanX), Math.ceil(moveSpanY));
		canvasH.fill(new Rectangle(0, 0, canvasH.width, canvasH.height), 0x5481E9,0.8);
		canvasV = new Canvas(Math.ceil(moveSpanX), Math.ceil(detectionDistance * moveSpanY));
		canvasV.fill(new Rectangle(0, 0, canvasV.width, canvasV.height), 0x5481E9,0.8);
		
		super();
	}
	
	override public function added():Void
	{
		this.type = "vision";
		super.added();
		
	}
	
	override public function update():Void
	{
		super.update();

		// part du milieu
		x = (_ghost.x + _moveSpanX / 2) + (_ghost.directionPoint.x * width + _moveSpanX / 2) * (_ghost.directionPoint.x);
		
		switch(_ghost.direction) {
			case Direction.Up:
				width = Math.ceil(_moveSpanX);
				height = Math.ceil(_detectionDistance * _moveSpanY);
				x = _ghost.x + TOLERANCE;
				y = _ghost.y - height + _moveSpanY - TOLERANCE;
				
				var scaleY:Float = 1;
				var yTest = height;
				while (yTest > 0) {
					yTest -= 10;
					if (world.collidePoint("solid", x, y+yTest) != null) {
						var length = height-(yTest);
						scaleY = length / height;
						height = length;
						y = y + yTest;
						break;
					}
				}
				canvasV.scaleY = scaleY;
				
				graphic = canvasV;
				
			case Direction.Down:
				width = Math.ceil(_moveSpanX);
				height = Math.ceil(_detectionDistance * _moveSpanY);
				x = _ghost.x + TOLERANCE;
				y = _ghost.y + TOLERANCE;
				
				var scaleY:Float = 1;
				var yTest = 0;
				while (yTest < height) {
					yTest += 10;
					if (world.collidePoint("solid", x, y+yTest) != null) {
						var length = yTest;
						scaleY = length / height;
						height = length;
						break;
					}
				}
				canvasV.scaleY = scaleY;
				
				graphic = canvasV;
			case Direction.Left:
				width = Math.ceil(_detectionDistance * _moveSpanX);
				height = Math.ceil(_moveSpanY);
				x = _ghost.x - width + _moveSpanX - TOLERANCE;
				y = _ghost.y + TOLERANCE;
				
				var scaleX:Float = 1;
				var xTest = width;
				while (xTest > 0) {
					xTest -= 10;
					if (world.collidePoint("solid", x+xTest, y) != null) {
						var length = width-(xTest);
						scaleX = length / width;
						width = length;
						x = x + xTest;
						break;
					}
				}
				canvasH.scaleX = scaleX;
				
				graphic = canvasH;
			case Direction.Right:
				width = Math.ceil(_detectionDistance * _moveSpanX);
				height = Math.ceil(_moveSpanY);
				x = _ghost.x + TOLERANCE;
				y = _ghost.y + TOLERANCE;
				
				var scaleX:Float = 1;
				var xTest = 0;
				while (xTest < width) {
					xTest += 10;
					if (xTest%10 == 0) {
						if (world.collidePoint("solid", x + xTest, y) != null) {
							var length = xTest;
							scaleX = length / width;
							width = length;
							break;
						}
					}
				}
				canvasH.scaleX = scaleX;
				
				graphic = canvasH;
		}
		setHitbox(width-2*TOLERANCE, height-2*TOLERANCE);
	}
	
}
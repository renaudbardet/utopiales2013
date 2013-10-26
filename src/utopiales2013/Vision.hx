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
		
		collidable = true;
		type = "vision";
		
		super();
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
				x = _ghost.x;
				y = _ghost.y - height + _moveSpanY;
				graphic = canvasV;
			case Direction.Down:
				width = Math.ceil(_moveSpanX);
				height = Math.ceil(_detectionDistance * _moveSpanY);
				x = _ghost.x;
				y = _ghost.y;
				graphic = canvasV;
			case Direction.Left:
				width = Math.ceil(_detectionDistance * _moveSpanX);
				height = Math.ceil(_moveSpanY);
				x = _ghost.x - width + _moveSpanX;
				y = _ghost.y;
				graphic = canvasH;
			case Direction.Right:
				width = Math.ceil(_detectionDistance * _moveSpanX);
				height = Math.ceil(_moveSpanY);
				x = _ghost.x;
				y = _ghost.y;
				graphic = canvasH;
		}
		setHitbox(width, height);
	}
	
}
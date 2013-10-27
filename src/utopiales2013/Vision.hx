package utopiales2013;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Canvas;
import com.haxepunk.graphics.Spritemap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import openfl.Assets;
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
	var canvasL:Spritemap;
	var canvasR:Spritemap;
	var canvasU:Spritemap;
	var canvasB:Spritemap;

	public function new(ghost:Ghost, detectionDistance:Int, moveSpanX:Float, moveSpanY:Float)
	{
		_ghost = ghost;
		_detectionDistance = detectionDistance;
		_moveSpanX = moveSpanX;
		_moveSpanY = moveSpanY;
		/*
		canvasH = new Canvas(Math.ceil(detectionDistance * moveSpanX), Math.ceil(moveSpanY));
		canvasH.fill(new Rectangle(0, 0, canvasH.width, canvasH.height), 0x5481E9,0.8);
		canvasV = new Canvas(Math.ceil(moveSpanX), Math.ceil(detectionDistance * moveSpanY));
		canvasV.fill(new Rectangle(0, 0, canvasV.width, canvasV.height), 0x5481E9,0.8);
		*/
		
		var canvasRB:BitmapData = Assets.getBitmapData("gfx/torche.png");
		var canvasBB:BitmapData = Assets.getBitmapData("gfx/torche2.png");
		
		//flip vertical matrix
		var flipVerticalMatrix = new Matrix();
		flipVerticalMatrix.scale(1, -1);
		flipVerticalMatrix.translate(0, canvasBB.height);

		//flip horizontal matrix
		var flipHorizontalMatrix = new Matrix();
		flipHorizontalMatrix.scale( -1, 1);
		flipHorizontalMatrix.translate(canvasRB.width, 0);

		var canvasLB:BitmapData = new BitmapData(canvasRB.width, canvasRB.height,true,0);
		canvasLB.draw(canvasRB, flipHorizontalMatrix);
		
		var canvasUB:BitmapData =new BitmapData(canvasBB.width, canvasBB.height,true,0);
		canvasUB.draw(canvasBB, flipVerticalMatrix);
		
		canvasL = new Spritemap(canvasLB, 60, 20);
		canvasL.add("play", [1, 2], 10);
		canvasL.alpha = 0.7;
		canvasL.play("play");
		canvasR = new Spritemap(canvasRB, 60, 20);
		canvasR.add("play", [1, 2], 10);
		canvasR.alpha = 0.7;
		canvasR.play("play");
		canvasU = new Spritemap(canvasUB, 20, 60);
		canvasU.add("play", [1, 2], 10);
		canvasU.alpha = 0.7;
		canvasU.play("play");
		canvasB = new Spritemap(canvasBB, 20, 60);
		canvasB.add("play", [1, 2], 10);
		canvasB.alpha = 0.7;
		canvasB.play("play");

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
				canvasU.scaleY = scaleY;
				canvasU.x = -2;
				graphic = canvasU;
				
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
				canvasB.scaleY = scaleY;
				canvasB.x = -2;
				graphic = canvasB;
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
				canvasL.scaleX = scaleX;
				canvasL.x = 10;
				graphic = canvasL;
				
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
				canvasR.scaleX = scaleX;
				canvasR.x = 10;
				graphic = canvasR;
		}
		setHitbox(width-2*TOLERANCE, height-2*TOLERANCE);
	}
	
	function get_ghost():Ghost
	{
		return _ghost;
	}
	
	function set_ghost(value:Ghost):Ghost
	{
		return _ghost = value;
	}
	
	public var ghost(get_ghost, set_ghost):Ghost;
	
}
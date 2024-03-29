package utopiales2013;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Tween.CompleteCallback;
import com.haxepunk.Tween.TweenType;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.utils.Ease;
import com.haxepunk.utils.Ease.EaseFunction;
import flash.geom.Point;
import utopiales2013.Hero.Direction;

enum Direction {
	Up;
	Down;
	Right;
	Left;
}

/**
 * ...
 * @author Lythom
 */
class Hero extends Entity
{
	private var _spritemap:Spritemap;
	private var _direction:Direction;
	var _directionPoint:Point;

	public function new()
	{
		_spritemap = new Spritemap("gfx/heros.png", 20, 30);
		_spritemap.add("right", [0], 5);
		_spritemap.add("left", [4], 5);
		_spritemap.add("up", [9], 5);
		_spritemap.add("down",  [14], 5);
		_spritemap.add("moveright", [0, 1, 2, 3, 2, 1], 5);
		_spritemap.add("moveleft", [4, 5, 6, 7, 6 , 5], 5);
		_spritemap.add("moveup", [8, 9, 10, 11, 10, 9], 5);
		_spritemap.add("movedown",  [12, 13, 14, 15, 14 , 13], 5);
		_spritemap.add("jumpright",  [16], 5);
		_spritemap.add("jumpleft",  [17], 5);
		_spritemap.add("jumpup",  [18], 5);
		_spritemap.add("jumpdown",  [19], 5);
		_spritemap.y = -10;
		graphic = _spritemap;
		_spritemap.play("down");
		_spritemap.frame = 1;
		_direction = Direction.Down;
		collidable = true;
		
		_directionPoint = new Point(0,1);
		
		super() ;
		
		setHitbox(16, 16, -2, -2);
	}
	
	override public function update():Void
	{
		super.update();
	}
	
	/**
	 * Change la directio ndu héro et l'animation correspondante
	 * @param	direction
	 * @param	isMoving
	 */
	public function play(direction:Direction, isMoving:Bool) {
		_direction = direction;
		switch (direction)
		{
			case Direction.Up:
				if (isMoving) {
					_spritemap.play("moveup");
				} else {
					_spritemap.play("up");
				}
				
			case Direction.Down:
				if (isMoving) {
					_spritemap.play("movedown");
				} else {
					_spritemap.play("down");
				}
			case Direction.Left:
				if (isMoving) {
					_spritemap.play("moveleft");
				} else {
					_spritemap.play("left");
				}
			case Direction.Right:
				if (isMoving) {
					_spritemap.play("moveright");
				} else {
					_spritemap.play("right");
				}
		}
	}
	
	public function jump(direction:Direction) {
		
		var jumpTweener:VarTween = new VarTween(function(e):Void {
				var jumpTweener2:VarTween = new VarTween(function(e):Void {}, TweenType.OneShot);
				jumpTweener2.tween(this, "y", this.y + 15, 15, Ease.sineOut);
				addTween(jumpTweener2, true);
			}, TweenType.OneShot);
		jumpTweener.tween(this, "y", this.y - 15, 15, Ease.sineIn);
		addTween(jumpTweener, true);
		
		switch (direction)
		{
			case Direction.Up:
				_spritemap.play("jumpup");
			case Direction.Down:
				_spritemap.play("jumpdown");
			case Direction.Left:
				_spritemap.play("jumpleft");
			case Direction.Right:
				_spritemap.play("jumpright");
		}
	}
	
	/**
	 * Déplace le héro en tenant compte des collisions, change son animation si besoin
	 * @param	direction
	 * @param	speed
	 */
	public function move(direction:Direction, speed:Float) {

		play(direction, true);
		switch (direction)
		{
			case Direction.Up:
				moveBy( 0, -speed, "solid");
			case Direction.Down:
				moveBy( 0, speed, "solid");
			case Direction.Left:
				moveBy( -speed, 0, "solid");
			case Direction.Right:
				moveBy( speed, 0, "solid");
		}
	}
	
	/**
	 * Arrête l'animation du héro
	 */
	public function stop()
	{
		play(direction, false);
	}
	
	public var direction(get_direction, null):Direction;
	private function get_direction():Direction {
		return _direction;
	}
	
	public var backDirection(get_backDirection, null):Direction;
	private function get_backDirection():Direction {
		switch (_direction)
		{
			case Direction.Up:
				return Direction.Down;
			case Direction.Down:
				return Direction.Up;
			case Direction.Left:
				return Direction.Right;
			case Direction.Right:
				return Direction.Left;
		}
		return Direction.Down;
	}
	
	public var directionPoint(get_directionPoint, null):Point;
	function get_directionPoint():Point
	{
		switch (_direction)
		{
			case Direction.Up:
				_directionPoint.x = 0;
				_directionPoint.y = -1;
			case Direction.Down:
				_directionPoint.x = 0;
				_directionPoint.y = 1;
			case Direction.Left:
				_directionPoint.x = -1;
				_directionPoint.y = 0;
			case Direction.Right:
				_directionPoint.x = 1;
				_directionPoint.y = 0;
		}
		return _directionPoint;
	}

}

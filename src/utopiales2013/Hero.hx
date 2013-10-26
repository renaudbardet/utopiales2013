package utopiales2013;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
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
	public var speed:Float = 2; // px/tick
	
	
	private var _spritemap:Spritemap;
	private var _direction:Direction;

	public function new()
	{
		_spritemap = new Spritemap("gfx/hero.png", 20, 30);
		_spritemap.add("up", [0], 5);
		_spritemap.add("down", [3], 5);
		_spritemap.add("left", [6], 5);
		_spritemap.add("right",  [9], 5);
		_spritemap.add("moveup", [0, 1, 2, 1], 5);
		_spritemap.add("movedown", [3, 4, 5, 4], 5);
		_spritemap.add("moveleft", [6, 7, 8, 7], 5);
		_spritemap.add("moveright",  [9, 10, 11, 10], 5);
		_spritemap.y = -10;
		graphic = _spritemap;
		_spritemap.play("down");
		_spritemap.frame = 1;
		_direction = Direction.Down;
		collidable = true;
		
		super() ;
		
		setHitbox(20, 20, 0, 0);
	}
	
	override public function update():Void
	{
		super.update();
	}
	
	public function move(direction:Direction) {
		_direction = direction;
		switch (direction)
		{
			case Direction.Up:
				moveBy( 0, -speed, "solid");
				_spritemap.play("moveup");
			case Direction.Down:
				moveBy( 0, speed, "solid");
				_spritemap.play("movedown");
			case Direction.Left:
				moveBy( -speed, 0, "solid");
				_spritemap.play("moveleft");
			case Direction.Right:
				moveBy( speed, 0, "solid");
				_spritemap.play("moveright");
		}
	}
	
	public function stop()
	{
		switch (_direction)
		{
			case Direction.Up:
				_spritemap.play("up");
			case Direction.Down:
				_spritemap.play("down");
			case Direction.Left:
				_spritemap.play("left");
			case Direction.Right:
				_spritemap.play("right");
		}
	}
	
	public var direction(get_direction, null):Direction;
	private function get_direction():Direction {
		return _direction;
	}
	
}

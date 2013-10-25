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
	public var speed:Float = 5; // px/second
	
	
	private var _spritemap:Spritemap;
	private var _direction:Direction;

	public function new()
	{
		_spritemap = new Spritemap("gfx/hero.png", 20, 30);
		_spritemap.add("up", [0, 1, 2, 1], 1 / 60);
		_spritemap.add("down", [3, 4, 5, 4], 1 / 60);
		_spritemap.add("left", [6, 7, 8, 7], 1 / 60);
		_spritemap.add("right",  [9, 10, 11, 10], 1 / 60);
		_spritemap.y = -10;
		graphic = _spritemap;
		_spritemap.play("down");
		_spritemap.pause();
		_spritemap.frame = 1;
		_direction = Direction.Down;
		
		height = 20;
		width = 20;
		collidable = true;
		super() ;
	}
	
	public function move(direction:Direction) {
		_direction = direction;
		switch (direction)
		{
			case Direction.Up:
				y -= speed;
				_spritemap.play("up");
			case Direction.Down:
				y += speed;
				_spritemap.play("down");
			case Direction.Left:
				x -= speed;
				_spritemap.play("left");
			case Direction.Right:
				x += speed;
				_spritemap.play("right");
		}
	}
	
	public var direction(get_direction, null):Direction;
	private function get_direction():Direction {
		return _direction;
	}
	
}
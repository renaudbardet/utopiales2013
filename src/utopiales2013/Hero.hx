package utopiales2013;
import com.haxepunk.animation.AnimatedSprite;
import com.haxepunk.animation.BitmapFrame;
import com.haxepunk.animation.Sequence;
import com.haxepunk.graphics.Spritemap;
import flash.geom.Point;
import openfl.Assets;

/**
 * ...
 * @author Lythom
 */
class Hero extends Entity
{

	public function new()
	{
		var g:Spritemap = new Spritemap("gfx/hero.png", 20, 30);
		g.add("up", [0, 1, 2, 1], 1 / 60);
		g.add("bottom", [3, 4, 5, 4], 1 / 60);
		g.add("left", [6, 7, 8, 7], 1 / 60);
		g.add("right",  [9, 10, 11, 10], 1 / 60);
		g.y = -10;
		graphic = g;
	}
	
}
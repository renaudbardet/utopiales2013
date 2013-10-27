package utopiales2013;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author Lythom
 */
class Piece extends Entity
{

	private static var skins : Array<Spritemap> ;
	private static function __init__()
	{
		skins = [] ;

		var src:BitmapData = openfl.Assets.getBitmapData("gfx/pieces.png") ;
		
		var skin1 = new BitmapData( 20, 20, true ) ;
		skin1.copyPixels( src, new Rectangle(0,0,20,20), new Point() ) ;
		var skin2 = new BitmapData( 20, 20, true ) ;
		skin2.copyPixels( src, new Rectangle(0,20,20,20), new Point() ) ;
		var skin3 = new BitmapData( 20, 20, true ) ;
		skin3.copyPixels( src, new Rectangle(0,40,20,20), new Point() ) ;
		var skin4 = new BitmapData( 20, 20, true ) ;
		skin4.copyPixels( src, new Rectangle(0,80,20,20), new Point() ) ;

		for( skin in [skin1, skin2, skin3, skin4] )
		{
			var animSrc = new BitmapData( 66, 22, true ) ;
			var tmpRect = new Rectangle(0,0,22,22) ;
			var tmpPoint = new Point() ;

			var tmp = new BitmapData(22,22,true) ;
			tmp.applyFilter( skin, tmpRect, new Point(2,3), new GlowFilter(0x9999FF, .5) ) ;
			animSrc.copyPixels( tmp, tmpRect, tmpPoint ) ;

			tmp.applyFilter( skin, tmpRect, new Point(2,2), new GlowFilter(0x9999FF, .9) ) ;
			tmpPoint.x = 22 ;
			animSrc.copyPixels( tmp, tmpRect, tmpPoint ) ;

			tmp.applyFilter( skin, tmpRect, new Point(2,1), new GlowFilter(0x9999FF, .5) ) ;
			tmpPoint.x = 44 ;
			animSrc.copyPixels( tmp, tmpRect, tmpPoint ) ;

			var spm = new Spritemap( animSrc, 22, 22 ) ;
			spm.add("std", [0,1,2,1], 2 ) ;
			spm.play("std") ;
			skins.push(spm) ;
		}

	}

	public function new()
	{
		super() ;
		
		graphic = skins[Std.int( Math.random() * skins.length)] ;
		graphic.x = -1;
		graphic.y = -1;

		type = "piece" ;
		setHitbox(19, 19, -2, -2);

	}
	
	override public function update():Void
	{
		super.update();
	}

}

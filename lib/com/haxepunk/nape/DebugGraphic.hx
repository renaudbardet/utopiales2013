package com.haxepunk.nape;
import com.haxepunk.HXP;
import flash.display.Bitmap;
import flash.geom.Point;
import com.haxepunk.Graphic;
import flash.display.BitmapData;
import nape.space.Space;
import nape.util.BitmapDebug;

/**
 * ...
 * @author Samuel Bouchet
 */

class DebugGraphic extends Graphic
{
	private var debug:BitmapDebug;
	private var space:Space;

	public function new(debug:BitmapDebug, space:Space) 
	{
		this.debug = debug;
		this.space = space;
		super();
	}
	
	override public function render(target:BitmapData, point:Point, camera:Point) 
	{
		// Clear the debug display.
		debug.clear();
		// Draw our Space.
		debug.draw(space);
		// Flush draw calls, until this is called nothing will actually be displayed.
		debug.flush();
		
		var bmp:Bitmap = cast(debug.display, Bitmap);
		if (bmp != null) {
			_point.x = point.x + x - camera.x * scrollX;
			_point.y = point.y + y - camera.y * scrollY;
			target.copyPixels(bmp.bitmapData, bmp.bitmapData.rect, _point, null, null, true);
		}
		super.render(target, point, camera);
	}
	
}
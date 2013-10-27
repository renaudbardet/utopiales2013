package com.haxepunk.gui.graphic.flash;

import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author AClockWorkLemon
 */
class CheckedNineSlice extends NineSlice
{

	private var _checkGraphic:Image;
	private var _checkClipRect:Rectangle;
	private var _checkPoint:Point;

	/**
	 * Create an Image composed by a NineSlice and a "checked" Image. Used for checkbox or similar behaviour composants.
	 * @param	width		Initial Width of the 9slice
	 * @param	height		Initial Height of the 9slice
	 * @param	nineSliceClipRect	Rectangle of the first Slice area on the skin
	 * @param	checkClipRect		Rectangle of the total area on the skin to use for check graphic
	 * @param	skin		optional custom skin
	 */
	public function new(width:Float, height:Float, ?nineSliceClipRect:Rectangle, ?checkClipRect:Rectangle, ?skin:BitmapData)
	{
		super(width, height, nineSliceClipRect, skin);

		_checkClipRect = checkClipRect;
		_checkPoint = new Point();
		_checkGraphic = new Image(_skin, new Rectangle(checkClipRect.x, checkClipRect.y, checkClipRect.width, checkClipRect.height));
	}

	/**
	 * Render the image on top of the parent.
	 * @param	target
	 * @param	point
	 * @param	camera
	 */
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		super.render(target, point, camera);

		// scale only by multiples of 2 to ensure good rendering
		_checkGraphic.scaleX = this.width / _checkClipRect.width;
		if (_checkGraphic.scaleX > 2) _checkGraphic.scaleX = Math.round(_checkGraphic.scaleX*2)/2;
		else if (_checkGraphic.scaleX > 1) _checkGraphic.scaleX = Math.round(_checkGraphic.scaleX);

		_checkGraphic.scaleY = this.height / _checkClipRect.height;
		if (_checkGraphic.scaleY > 2) _checkGraphic.scaleY = Math.round(_checkGraphic.scaleY*2)/2;
		else if (_checkGraphic.scaleY > 1) _checkGraphic.scaleY = Math.round(_checkGraphic.scaleY);

		_checkPoint.x = point.x + this.width / 2 - (_checkClipRect.width*_checkGraphic.scaleX) / 2;
		_checkPoint.y = point.y + this.height / 2 - (_checkClipRect.height * _checkGraphic.scaleX) / 2;
		_checkGraphic.render(target, _checkPoint, camera);
	}


}
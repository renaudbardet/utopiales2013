package com.haxepunk.gui.graphic.native;

import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.graphics.atlas.AtlasRegion;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

class CheckedNineSlice extends NineSlice
{

	/**
	 * Create an Image composed by a NineSlice and a "checked" Image. Used for checkbox or similar behaviour composants.
	 * @param	width		Initial Width of the 9slice
	 * @param	height		Initial Height of the 9slice
	 * @param	nineSliceClipRect	Rectangle of the first Slice area on the skin
	 * @param	checkClipRect		Rectangle of the total area on the skin to use for check graphic
	 * @param	skin		optional custom skin
	 */
	public function new(width:Float, height:Float, ?nineSliceClipRect:Rectangle, ?checkClipRect:Rectangle, ?skin:AtlasRegion)
	{
		super(width, height, nineSliceClipRect, skin);

		_checkGraphic = _skin.clip(checkClipRect);

		_scale = new Point((width - _clipRect.width * 2) / _clipRect.width, (height - _clipRect.height * 2) / _clipRect.height);
		_checkOffset = new Point(_clipRect.width, _clipRect.height);
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

		_checkGraphic.draw(_point.x + _checkOffset.x, _point.x + _checkOffset.y, layer, _scale.x, _scale.y);
	}

	private var _checkGraphic:AtlasRegion;
	private var _checkOffset:Point;
	private var _scale:Point;

}
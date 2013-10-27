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
 * @author Lythom
 */
class NineSlice extends Graphic
{
	private var _skin:BitmapData;

	private var _topLeft:Image;
	private var _topCenter:Image;
	private var _topRight:Image;
	private var _centerLeft:Image;
	private var _centerCenter:Image;
	private var _centerRight:Image;
	private var _bottomLeft:Image;
	private var _bottomCenter:Image;
	private var _bottomRight:Image;

	private var _xScale:Float;
	private var _yScale:Float;

	private var _clipRect:Rectangle;

	private var _width:Float;
	private var _height:Float;
	private var _camera:Point;

	/**
	 * Create an Image setting its width, height and the position and size of the first slice.
	 * A slice is 1/3 of the source image ("skin" if not null, else defaultGuiSkin).
	 * @param	width		Initial Width of the 9slice
	 * @param	height		Initial Height of the 9slice
	 * @param	clipRect	Rectangle of the first slice area on the skin
	 * @param	skin		optional custom skin
	 */
	public function new(width:Float, height:Float, ?clipRect:Rectangle, ?skin:BitmapData)
	{
		super();
		_camera = new Point();
		_skin = (skin != null) ? skin : Control.currentSkin;
		this.width = width;
		this.height = height;

		if (clipRect == null) clipRect = new Rectangle(0, 0, 1, 1);
		_clipRect = clipRect;

		_topLeft      = new Image(_skin, new Rectangle(clipRect.x                     , clipRect.y                      , clipRect.width, clipRect.height));
		_topCenter    = new Image(_skin, new Rectangle(clipRect.x + clipRect.width    , clipRect.y                      , clipRect.width, clipRect.height));
		_topRight     = new Image(_skin, new Rectangle(clipRect.x + clipRect.width * 2, clipRect.y                      , clipRect.width, clipRect.height));
		_centerLeft   = new Image(_skin, new Rectangle(clipRect.x                     , clipRect.y + clipRect.height    , clipRect.width, clipRect.height));
		_centerCenter = new Image(_skin, new Rectangle(clipRect.x + clipRect.width    , clipRect.y + clipRect.height    , clipRect.width, clipRect.height));
		_centerRight  = new Image(_skin, new Rectangle(clipRect.x + clipRect.width * 2, clipRect.y + clipRect.height    , clipRect.width, clipRect.height));
		_bottomLeft   = new Image(_skin, new Rectangle(clipRect.x                     , clipRect.y + clipRect.height * 2, clipRect.width, clipRect.height));
		_bottomCenter = new Image(_skin, new Rectangle(clipRect.x + clipRect.width    , clipRect.y + clipRect.height * 2, clipRect.width, clipRect.height));
		_bottomRight  = new Image(_skin, new Rectangle(clipRect.x + clipRect.width * 2, clipRect.y + clipRect.height * 2, clipRect.width, clipRect.height));
	}

	/**
	 * Render the Image.
	 */
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		calculateRendering();
		_camera.x = Math.round(camera.x);
		_camera.y = Math.round(camera.y);
		doRender(target, point, _camera);
	}

	/**
	 * Calculate position and scale of each tile
	 */
	private function calculateRendering():Void
	{
		_xScale = (width - _clipRect.width * 2) / _clipRect.width;
		_yScale = (height - _clipRect.height * 2) / _clipRect.height;

		_topCenter.scaleX = _xScale;
		_centerLeft.scaleY = _yScale;
		_centerCenter.scaleX = _xScale;
		_centerCenter.scaleY = _yScale;
		_centerRight.scaleY = _yScale;
		_bottomCenter.scaleX = _xScale;

		// width and height
		var hw = _clipRect.width;
		var hh = _clipRect.height;
		// scaled width and height
		var hsw = (_clipRect.width + (_xScale * _clipRect.width));
		var hsh = (_clipRect.height + (_yScale * _clipRect.height));

		_topCenter.x    = hw;
		_topRight.x     = hsw;
		_centerLeft.y   = hh;
		_centerCenter.x = hw;
		_centerCenter.y = hh;
		_centerRight.x  = hsw;
		_centerRight.y  = hh;
		_bottomLeft.y   = hsh;
		_bottomCenter.x = hw;
		_bottomCenter.y = hsh;
		_bottomRight.x  = hsw;
		_bottomRight.y  = hsh;
	}

	/**
	 * Draw tiles to the target bitmap at point looking from camera.
	 * @param	target
	 * @param	point
	 * @param	camera
	 */
	private function doRender(target:BitmapData, point:Point, camera:Point):Void
	{
		_point.x = Math.round(point.x + this.x);
		_point.y = Math.round(point.y + this.y);
		if(_topLeft.visible)
		{
			_topLeft.render(target, _point, camera);
		}
		if(_topCenter.visible)
		{
			_topCenter.render(target, _point, camera);
		}
		if(_topRight.visible)
		{
			_topRight.render(target, _point, camera);
		}

		if(_centerLeft.visible)
		{
			_centerLeft.render(target, _point, camera);
		}
		if(_centerCenter.visible)
		{
			_centerCenter.render(target, _point, camera);
		}
		if(_centerRight.visible)
		{
			_centerRight.render(target, _point, camera);
		}

		if(_bottomLeft.visible)
		{
			_bottomLeft.render(target, _point, camera);
		}
		if(_bottomCenter.visible)
		{
			_bottomCenter.render(target, _point, camera);
		}
		if(_bottomRight.visible)
		{
			_bottomRight.render(target, _point, camera);
		}
	}

	public function hideTop()
	{
		_topLeft.visible = false;
		_topCenter.visible = false;
		_topRight.visible = false;
	}


	private function get_width():Float
	{
		return _width;
	}

	private function set_width(value:Float):Float
	{
		return _width = value;
	}

	public var width(get_width, set_width):Float;

	private function get_height():Float
	{
		return _height;
	}

	private function set_height(value:Float):Float
	{
		return _height = value;
	}
	public var height(get_height, set_height):Float;

	private function get_topLeft():Image
	{
		return _topLeft;
	}

	private function set_topLeft(value:Image):Image
	{
		return _topLeft = value;
	}

	public var topLeft(get_topLeft, set_topLeft):Image;

	private function get_topCenter():Image
	{
		return _topCenter;
	}

	private function set_topCenter(value:Image):Image
	{
		return _topCenter = value;
	}

	public var topCenter(get_topCenter, set_topCenter):Image;

	private function get_topRight():Image
	{
		return _topRight;
	}

	private function set_topRight(value:Image):Image
	{
		return _topRight = value;
	}

	public var topRight(get_topRight, set_topRight):Image;

	private function get_centerLeft():Image
	{
		return _centerLeft;
	}

	private function set_centerLeft(value:Image):Image
	{
		return _centerLeft = value;
	}

	public var centerLeft(get_centerLeft, set_centerLeft):Image;

	private function get_centerCenter():Image
	{
		return _centerCenter;
	}

	private function set_centerCenter(value:Image):Image
	{
		return _centerCenter = value;
	}

	public var centerCenter(get_centerCenter, set_centerCenter):Image;

	private function get_centerRight():Image
	{
		return _centerRight;
	}

	private function set_centerRight(value:Image):Image
	{
		return _centerRight = value;
	}

	public var centerRight(get_centerRight, set_centerRight):Image;


	private function get_bottomLeft():Image
	{
		return _bottomLeft;
	}

	private function set_bottomLeft(value:Image):Image
	{
		return _bottomLeft = value;
	}

	public var bottomLeft(get_bottomLeft, set_bottomLeft):Image;

	private function get_bottomCenter():Image
	{
		return _bottomCenter;
	}

	private function set_bottomCenter(value:Image):Image
	{
		return _bottomCenter = value;
	}

	public var bottomCenter(get_bottomCenter, set_bottomCenter):Image;

	private function get_bottomRight():Image
	{
		return _bottomRight;
	}

	private function set_bottomRight(value:Image):Image
	{
		return _bottomRight = value;
	}

	public var bottomRight(get_bottomRight, set_bottomRight):Image;


}
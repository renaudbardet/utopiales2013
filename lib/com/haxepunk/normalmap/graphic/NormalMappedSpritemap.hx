package com.haxepunk.normalmap.graphic;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.normalmap.Light;
import com.haxepunk.normalmap.NormalMappedBitmapData;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

/**
 * Not efficient at all ! Please use NormalMappedAnimatedSprite instead.
 * @author Samuel Bouchet
 */
class NormalMappedSpritemap extends Spritemap
{

	/**
	 * Constructor.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 * @param	callback		Optional callback function for animation end.
	 */
	public function new(source:NormalMappedBitmapData, frameWidth:Int = 0, frameHeight:Int = 0, cbFunc:CallbackFunction = null, name:String = "")
	{
		pos = new Vector3D();
		super(source, frameWidth, frameHeight, cbFunc, name);
	}
	
	public var normalMapSource(get_normalMapSource, null):NormalMappedBitmapData;
	private function get_normalMapSource():NormalMappedBitmapData { return cast(_source); }
	
	private var pos:Vector3D;
	private var lastLights:Array<Light>;
	
	public function updateLightning(bitmapPosition:Vector3D, lights:Array<Light>) 
	{
		pos.x = bitmapPosition.x;
		pos.y = bitmapPosition.y;
		pos.z = bitmapPosition.z;
		lastLights = lights;
		updateBuffer();
	}
	
	override public function updateBuffer(clearBefore:Bool = false) 
	{
		// get position of the current frame
		// Original Spritemap.updateBuffer
		#if neko
			if (_width == null) return;
		#end
		
		_rect.x = _rect.width * _frame;
		_rect.y = Std.int(_rect.x / _width) * _rect.height;
		_rect.x = _rect.x % _width;

		if (flipped) _rect.x = (_width - _rect.width) - _rect.x;
		
		// change : lightening
		pos.x -= _rect.x;
		pos.y -= _rect.y;
		if (lastLights != null) {
			normalMapSource.updateLightning(pos, lastLights);
		}
		pos.x += _rect.x;
		pos.y += _rect.y;

		// update the buffer
		// Image method called via super.updateBuffer from Spritemap.updateBuffer
		if (_source == null) return;
		if (clearBefore) _buffer.fillRect(_bufferRect, HXP.blackColor);
		_buffer.copyPixels(_source, _sourceRect, HXP.zero);
		if (_tint != null) _buffer.colorTransform(_bufferRect, _tint);
	}
	
	
}
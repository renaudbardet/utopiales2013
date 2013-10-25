package com.haxepunk.normalmap.graphic;
import com.haxepunk.graphics.Image;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

/**
 * ...
 * @author Samuel Bouchet
 */

class NormalMappedImage extends Image
{

	public function new(source:NormalMappedBitmapData, clipRect:Rectangle = null, name:String = "")
	{
		super(source, clipRect, name);
	}
	
	public var normalMapSource(get_normalMapSource, null):NormalMappedBitmapData;
	private function get_normalMapSource():NormalMappedBitmapData { return cast(_source); }
	
	public function updateLightning(bitmapPosition:Vector3D, lights:Array<Light>) 
	{
		normalMapSource.updateLightning(bitmapPosition, lights);
		updateBuffer();
	}
	
	
}
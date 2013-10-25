package com.haxepunk.normalmap;
import flash.geom.Vector3D;
import tools.display.RGB;

/**
 * ...
 * @author Samuel Bouchet
 */

class NormalMappedPixelData 
{
	/**
	 * Color that this light gives to the global color (reference to the LightBitmapDataInfo buffer).
	 */
	public var lightBufferPixel:RGB;
	/**
	 * (reference to the NormalMappedBitmapData source)
	 */
	public var sourcePixelColor:RGB;
	/**
	 * Angle of the normal map at this pixel (reference to the NormalMappedBitmapData angle).
	 */
	public var mapAngle:Vector3D;
	/**
	 * (reference to the NormalMappedBitmapData pixelsRGB)
	 */
	public var globalBufferPixel:RGB;
	
	public var pxX:Int;
	public var pxY:Int;

	/**
	 * Data of one pixel needed to calculate the normal mapping.
	 * This class is intended to be used in the NormalMappingEngine for fast process.
	 * The engine while also need light and position information to render.
	 * @param	sourcePixelColor
	 * @param	mapAngle
	 * @param	globalBufferPixel
	 * @param 	lightBufferPixel
	 */
	public function new(sourcePixelColor:RGB, mapAngle:Vector3D, globalBufferPixel:RGB, lightBufferPixel:RGB, pxX:Int, pxY:Int) 
	{
		this.sourcePixelColor = sourcePixelColor;
		this.mapAngle = mapAngle;
		this.globalBufferPixel = globalBufferPixel;
		this.lightBufferPixel = lightBufferPixel;
		this.pxX = pxX;
		this.pxY = pxY;
	}
	
}
package com.haxepunk.animation;
import flash.geom.Point;
import flash.display.BitmapData;

/**
 * A frame the inclide a bitmapData, a pivotPoint, a width and a heigth.
 * Ported from alkemi-games framwork "CachedFrame".
 * @author Alkemi-games
 * @author Lythom
 */
class BitmapFrame 
{

	public var bitmapData:BitmapData ;
	public var pivot:Point;
	public var width:Int;
	public var height:Int;
	
	/**
	 * Stores bitmap and pivot (origin) information for each frame of a MovieClip converted to a CachedAnimation
	 * @param	bmp the bitmapData rasterized from the target MovieClip for one frame
	 * @param	pivot position of the Frame pivot (origin) in the coordinates space of the top left of the bitmap
	 */
	public function new( bmp:BitmapData, pivot:Point)
	{
		this.bitmapData = bmp;
		this.pivot = pivot;
		width = bitmapData.width;
		height = bitmapData.height;
	}
	
	public function clear ()
	{
		bitmapData.dispose () ;
		bitmapData = null ;
	}
	
}
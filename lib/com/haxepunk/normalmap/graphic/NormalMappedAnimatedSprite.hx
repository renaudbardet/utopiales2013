package com.haxepunk.normalmap.graphic;
import com.haxepunk.animation.AnimatedSprite;
import com.haxepunk.animation.BitmapFrame;
import com.haxepunk.normalmap.Light;
import com.haxepunk.normalmap.NormalMappedBitmapData;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Vector3D;

/**
 * Graphics of animated normal mapped Sprite.
 * Use createFramesFromBitmap to create the frames, then put the frames in sequences using sequence.addFrames. Finally,
 * add sequences to a NormalMappedAnimatedSprite instance. This instance can be used as Graphics.
 * @author Samuel Bouchet
 */
class NormalMappedAnimatedSprite extends AnimatedSprite
{
	private var pos:Vector3D;
	private var lastLights:Array<Light>;

	/**
	 * Constructor.
	 */
	public function new()
	{
		pos = new Vector3D();
		super();
	}
	
	/**
	 * Create a BitmapFrame list from a NormalMappedBitmapData source, setting defaultPivotPoint as Pivot point for thoses frames.
	 * Each BitmapFrame will contain a NormalMappedBitmapData as BitmapData.
	 * @param	bmpData
	 * @param	defaultPivotPoint
	 * @return	Array<BitmapFrame>
	 */
	static public function createFramesFromBitmap(bmpData:NormalMappedBitmapData, frameWidth:Int, frameHeight:Int, defaultPivotPoint:Point=null):Array<BitmapFrame> {
		if (bmpData == null) throw "source BitmapData can't be null";
		if (defaultPivotPoint == null) {
			defaultPivotPoint = AnimatedSprite.zeroPoint;
		}

		var cols = Math.ceil(bmpData.width / frameWidth);
		var rows = Math.ceil(bmpData.height / frameHeight);
		AnimatedSprite.rect.height = frameHeight;
		AnimatedSprite.rect.width = frameWidth;
		
		var array:Array<BitmapFrame> = new Array<BitmapFrame>();
		for (r in 0...rows) {
			for (c in 0...cols) {
				AnimatedSprite.rect.x = c * frameWidth;
				AnimatedSprite.rect.y = r * frameHeight;
				
				var bmpD:BitmapData = new BitmapData(frameWidth, frameHeight);
				bmpD.copyPixels(bmpData.source, AnimatedSprite.rect, AnimatedSprite.zeroPoint);
				
				var mapBmpD:BitmapData = new BitmapData(frameWidth, frameHeight);
				mapBmpD.copyPixels(bmpData.mapSource, AnimatedSprite.rect, AnimatedSprite.zeroPoint);
				
				var nmBmpD:NormalMappedBitmapData = new NormalMappedBitmapData(bmpD, mapBmpD);
				
				array.push(new BitmapFrame(nmBmpD, new Point(defaultPivotPoint.x, defaultPivotPoint.y)));
			}
		}
		return array;
	}
	
	/**
	 * When you want to recalculate light.
	 * @param	bitmapPosition
	 * @param	lights
	 */
	public function updateLightning(bitmapPosition:Vector3D, lights:Array<Light>) 
	{
		pos.x = bitmapPosition.x;
		pos.y = bitmapPosition.y;
		pos.z = bitmapPosition.z;
		lastLights = lights;
		
		var nmBmpData:NormalMappedBitmapData = cast(_frame.bitmapData, NormalMappedBitmapData);
		if (nmBmpData!=null) {
			nmBmpData.updateLightning(pos, lastLights);
		}
	}
	
	override public function set_frame(bitmapFrame:BitmapFrame):BitmapFrame 
	{
		if (bitmapFrame != _frame && bitmapFrame != null && lastLights!=null) {
			var nmBmpData:NormalMappedBitmapData = cast(bitmapFrame.bitmapData, NormalMappedBitmapData);
			if (nmBmpData!=null) {
				nmBmpData.updateLightning(pos, lastLights);
			}
		}
		return super.set_frame(bitmapFrame);
	}
	
	
}
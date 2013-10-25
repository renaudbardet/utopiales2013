package com.haxepunk.normalmap;
import com.gigglingcorpse.utils.Profiler;
import com.haxepunk.normalmap.Light;
import com.haxepunk.normalmap.NormalMappingEngine;
import haxe.ds.ObjectMap;
import openfl.Assets;
import flash.display.BitmapData;
import flash.geom.Vector3D;
import flash.Vector;
import haxe.ds.GenericStack;
import tools.display.ColorConverter;
import tools.display.RGB;
using Lambda;

/**
 * A BitmapData that contains data for a source picture and a normal map.
 * It works with NormalMappingEngine to calculate lightening.
 * @author Samuel Bouchet
 */
class NormalMappedBitmapData extends BitmapData
{
	private var _source:BitmapData;
	private var _mapSource:BitmapData;
	private var rgb:RGB;
	private var _fastLights:GenericStack<Light>;
	
	public var lightsInfo:ObjectMap<Light, LightBitmapDataInfo>;
	
	// buffer, list of the pixels to display. They are applied to the bitmapData using setVector().
	private var thisPixels:Vector<UInt>;

	// source picture pixels as RGB
	public var sourcePixels:Vector<RGB>;
	// list of angles calculated from the normalMap
	public var normalMapAngles:Vector<Vector3D>;
	
	/**
	 * buffer, list of the pixels as RGB to display.
	 * They are converted into Vector<Int> then applied to the bitmapData using setVector().
	 */
	public var pixelsRGB:Vector<RGB>;
	/**
	 * FastList referencing pixelsRGBs for fast looping.
	 */
	public var fastPixelsRGB:GenericStack<RGB>;

	/**
	 * Create a BitmapData that contains data for a source picture and a normal map.
	 * @param	source		Source resource name or BitmapData.
	 * @param 	mapSource	NormalMap resource name or BitmapData.
	 */
	public function new(source:Dynamic, mapSource:Dynamic)
	{
		// init source and map
		if (Std.is(mapSource, BitmapData))
		{
			_mapSource = cast(mapSource, BitmapData);
		}
		else if (Std.is(mapSource, String)){
			_mapSource = Assets.getBitmapData(mapSource);
		}
		if (_mapSource == null) throw "Invalid map source image.";
		
		if (Std.is(source, BitmapData))
		{
			_source = cast(source, BitmapData);
		}
		else if (Std.is(mapSource, String)){
			_source = Assets.getBitmapData(source);
		}
		if (_source == null) throw "Invalid source image.";
		
		if (_source.width != _mapSource.width || _source.height != _mapSource.height) {
			throw "source and mapSource must be the same size.";
		}
		
		// call super
		super(_source.width, _source.height, true);
		
		_fastLights = new GenericStack<Light>();
		lightsInfo = new ObjectMap<Light, LightBitmapDataInfo>();
		rgb = new RGB();
		
		// init vectors for fast access
		var sourcePixelsVector = _source.getVector(rect);
		sourcePixels = new Vector<RGB>();
		for (sourcePixel in sourcePixelsVector) {
			sourcePixels.push(ColorConverter.toRGB(sourcePixel));
		}
		var normalMapPixels:Vector<UInt> = _mapSource.getVector(rect);
		thisPixels = this.getVector(rect);
		pixelsRGB = new Vector<RGB>();
		fastPixelsRGB = new GenericStack<RGB>();
		var rgb:RGB;
		for (i in 0...thisPixels.length) {
			rgb = new RGB();
			rgb.a = sourcePixels[i].a;
			rgb.userData.changed = true;
			pixelsRGB.push(rgb);
			fastPixelsRGB.add(rgb);
		}
		
		//for each pixel
		normalMapAngles = new Vector<Vector3D>();
		for (mapPixelColor in normalMapPixels){
			// amount of red gives X-axis angle
			var mapAngle:Vector3D = new Vector3D();
			mapAngle.x = (((mapPixelColor >> 16) & 255) / 255 - 0.5);
			// amount of green gives Y-axis angle
			mapAngle.y = (((mapPixelColor >> 8) & 255) / 255 - 0.5);
			// amount of blue gives Z-axis angle
			mapAngle.z = ((mapPixelColor & 255) / 255 - 0.5);
			mapAngle.normalize();
			normalMapAngles.push(mapAngle);
		}
	}
	
	/**
	 * calculate a new bitmapData from current bitmapData position and lights data.
	 * @param	bitmapPosition 	Position of the bitmap
	 * @param	lights			list of lights to consider
	 */
	public function updateLightning(bitmapPosition:Vector3D, lights:Array<Light>) 
	{
		var lightInfo:LightBitmapDataInfo;
		var changed:Bool = false;
		var lastLightCount:Int = 0;
		
		// check for light suppression
		while (_fastLights.first() != null) {
			// same instances ?
			var l:Light = _fastLights.pop();
			var found:Bool = false;
			var i:Int = 0;
			while (i<lights.length && !found) {
				if (lights[i] == l) {
					found = true;
				}
				i++;
			}
			if (!found) {
				// remove the values if light is removed
				for (pixelData in lightsInfo.get(l).pixelsData) {
					pixelData.globalBufferPixel.remove(pixelData.lightBufferPixel, false);
					pixelData.globalBufferPixel.userData.changed = true;
				}
				changed = true;
			}
		}
		
		// update light info
		// calculate buffers if needed
		for (l in lights) {
			if (lightsInfo.exists(l)) {
				lightInfo = lightsInfo.get(l);
			} else {
				lightInfo = new LightBitmapDataInfo(this, l);
				lightsInfo.set(l, lightInfo);
			}
			if (lightInfo.angleChanged(bitmapPosition, l.position) || lightInfo.propertyChanged(l)) {
				// redraw buffers
				Profiler.start("buffer update");
				if (NormalMappingEngine.update(lightInfo, bitmapPosition)) {
					changed = true;
				}
				Profiler.stop("buffer update");
				lightInfo.updateLastEntityLightAngles(bitmapPosition, l.position);
				lightInfo.updateLastLightProperties(l);
			}
			_fastLights.add(l);
		}
		
		
		// copy buffers
		if (changed) {
			Profiler.start("copy buffers");
			
			// fast list are stored reversed, so loop from the end to have everything in order.
			var i = pixelsRGB.length - 1;
			for (pxRGB in fastPixelsRGB) {
				if(pxRGB.userData.changed){
					rgb.r = pxRGB.r * 255;
					rgb.r = (255 > rgb.r)?rgb.r:255;
					rgb.r = (0 < rgb.r)?rgb.r:0;
					rgb.g = pxRGB.g * 255;
					rgb.g = (255 > rgb.g)?rgb.g:255;
					rgb.g = (0 < rgb.g)?rgb.g:0;
					rgb.b = pxRGB.b * 255;
					rgb.b = (255 > rgb.b)?rgb.b:255;
					rgb.b = (0 < rgb.b)?rgb.b:0;
					thisPixels[i] = Std.int(pxRGB.a * 255) << 24
									| Std.int(rgb.r) << 16
									| Std.int(rgb.g) << 8
									| Std.int(rgb.b);
					pxRGB.userData.changed = false;
				}
				i--;
			}
			/* same as above but less efficient
			 * for (i in 0...thisPixels.length) {
				thisPixels[i] = ColorConverter.toInt(pixelsRGB[i]);
			}*/
			Profiler.stop("copy buffers");
			Profiler.start("setVector");
			this.setVector(rect, thisPixels);
			Profiler.stop("setVector");
		}
	}
	
	private function get_source():BitmapData 
	{
		return _source;
	}
	
	public var source(get_source, null):BitmapData;
	
	private function get_mapSource():BitmapData 
	{
		return _mapSource;
	}
	
	public var mapSource(get_mapSource, null):BitmapData;

}
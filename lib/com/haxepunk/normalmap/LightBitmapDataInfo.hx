package com.haxepunk.normalmap;
import haxe.ds.GenericStack;
import flash.geom.Vector3D;
import flash.Vector;
import tools.display.RGB;

/**
 * Every data shared by a NormalMappedPixelData and a Light.
 * @author Lyth
 */
class LightBitmapDataInfo 
{
	private var _light:Light;
	private var _normalMappedBitmapData:NormalMappedBitmapData;
	private var _lastEntityLightAngles:Vector3D;
	private var _lastLightProperties:Light;
	private var _lightBuffer:Vector<RGB>;
	private var _changed:Bool = false;
	
	private var _pixelsData:GenericStack<NormalMappedPixelData>;
	
	/**
	 * Record temporary calculation data for each NormalMappedBitmapData and Light.
	 * @param	normalMappedBitmapData
	 * @param	light
	 */
	public function new(normalMappedBitmapData:NormalMappedBitmapData, light:Light) 
	{
		_light = light;
		_normalMappedBitmapData = normalMappedBitmapData;
		_lastEntityLightAngles = new Vector3D();
		_lastLightProperties = new Light();
		_lightBuffer = new Vector<RGB>();
		pixelsData = new GenericStack<NormalMappedPixelData>();
		var _lightBufferRGB:RGB;
		for (i in 0..._normalMappedBitmapData.getVector(_normalMappedBitmapData.rect).length) {
			_lightBuffer.push(_lightBufferRGB = new RGB());
			pixelsData.add(new NormalMappedPixelData(
				normalMappedBitmapData.sourcePixels[i],
				normalMappedBitmapData.normalMapAngles[i],
				normalMappedBitmapData.pixelsRGB[i],
				_lightBufferRGB,
				i % Std.int(normalMappedBitmapData.width), // pxX
				Std.int(i / normalMappedBitmapData.width) // pxY
			));
		}
	}
	
	/**
	 * Did the angle changed since last calculation ?
	 */
	public function angleChanged(entityPosition:Vector3D, lightPosition:Vector3D):Bool {
		return (_lastEntityLightAngles.x != entityPosition.x - lightPosition.x)
			|| (_lastEntityLightAngles.y != entityPosition.y - lightPosition.y)
			|| (_lastEntityLightAngles.z != entityPosition.z - lightPosition.z);
	}
	
	/**
	 * Did any light property changed since last calculation ?
	 */
	public function propertyChanged(lightInfo:Light):Bool {
		return (_lastLightProperties.color != lightInfo.color)
			|| (_lastLightProperties.radius != lightInfo.radius)
			|| (_lastLightProperties.intensity != lightInfo.intensity);
	}
	
	
	public function updateLastEntityLightAngles(entityPosition:Vector3D, lightPosition:Vector3D) {
		_lastEntityLightAngles.x = entityPosition.x - lightPosition.x;
		_lastEntityLightAngles.y = entityPosition.y - lightPosition.y;
		_lastEntityLightAngles.z = entityPosition.z - lightPosition.z;
	}
	
	public function updateLastLightProperties(lightInfo:Light) {
		_lastLightProperties.color = lightInfo.color;
		_lastLightProperties.radius = lightInfo.radius;
		_lastLightProperties.intensity = lightInfo.intensity;
	}
	
	private function get_light():Light 
	{
		return _light;
	}
	
	private function set_light(value:Light):Light 
	{
		return _light = value;
	}
	
	public var light(get_light, set_light):Light;
	
	private function get_normalMappedBitmapData():NormalMappedBitmapData 
	{
		return _normalMappedBitmapData;
	}
	
	private function set_normalMappedBitmapData(value:NormalMappedBitmapData):NormalMappedBitmapData 
	{
		return _normalMappedBitmapData = value;
	}
	
	public var normalMappedBitmapData(get_normalMappedBitmapData, set_normalMappedBitmapData):NormalMappedBitmapData;
	
	private function get_pixelsData():GenericStack<NormalMappedPixelData> 
	{
		return _pixelsData;
	}
	
	private function set_pixelsData(value:GenericStack<NormalMappedPixelData>):GenericStack<NormalMappedPixelData> 
	{
		return _pixelsData = value;
	}
	
	public var pixelsData(get_pixelsData, set_pixelsData):GenericStack<NormalMappedPixelData>;
	
	private function get_lightBuffer():Vector<RGB> 
	{
		return _lightBuffer;
	}
	
	private function set_lightBuffer(value:Vector<RGB>):Vector<RGB> 
	{
		return _lightBuffer = value;
	}
	
	public var lightBuffer(get_lightBuffer, set_lightBuffer):Vector<RGB>;
	
	private function get_changedLastTime():Bool 
	{
		return _changed;
	}
	
	private function set_changedLastTime(value:Bool):Bool 
	{
		return _changed = value;
	}
	
	public var changedLastTime(get_changedLastTime, set_changedLastTime):Bool;
	
}
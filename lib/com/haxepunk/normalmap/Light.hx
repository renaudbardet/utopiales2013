package com.haxepunk.normalmap;
import flash.geom.Vector3D;
import tools.display.ColorConverter;
import tools.display.RGB;
import tools.FastMath;

/**
 * An omnidirectionnal light.
 * @author Samuel Bouchet
 */
class Light 
{
	private var _x:Int;
	private var _y:Int;
	private var _z:Int;
	private var _color:UInt;
	private var _radius:Float;
	private var _intensity:Float;
	
	private var _pxPosition:Vector3D;
	private var _position:Vector3D;

	private var _colorAsRGB:RGB;
	public function new(x:Int = 0, y:Int = 0, color:UInt = 0xFAF5A9, radius:Float = 50, intensity:Float = 1, layer:Int = 0) 
	{
		_position = new Vector3D();
		_position.x = x;
		_position.y = y;
		_position.z = layer;
		_colorAsRGB = new RGB();
		this.color = color;
		_radius = radius;
		_intensity = intensity;
		if (intensity < 0) {
			throw "Light intensity can't be negative";
		}
		
		_pxPosition = new Vector3D();
	}
	
	/**
	 * Give intensity at a point using absolute x,y coordinates.
	 * @param	pxX
	 * @param	pxY
	 * @return
	 */
	public function getIntensityAt(pxX:Float, pxY:Float, pxZ:Float=0):Float {
		_pxPosition.x = pxX;
		_pxPosition.y = pxY;
		_pxPosition.z = pxZ;
		var dist:Float = FastMath.fastDistance2D(_pxPosition, _position);
		var f:Float = (radius - dist) / radius;
		if (f > 0) {
			return f * intensity;
		} else {
			return 0;
		}
	}
	
	private function get_color():UInt 
	{
		return _color;
	}
	
	private function set_color(value:UInt):UInt 
	{
		ColorConverter.setRGB(value, _colorAsRGB);
		return _color = value;
	}
	
	public var color(get_color, set_color):UInt;
	
	private function get_radius():Float 
	{
		return _radius;
	}
	
	private function set_radius(value:Float):Float 
	{
		return _radius = value;
	}
	
	public var radius(get_radius, set_radius):Float;
	
	private function get_intensity():Float 
	{
		return _intensity;
	}
	
	private function set_intensity(value:Float):Float 
	{
		return _intensity = value;
	}
	
	public var intensity(get_intensity, set_intensity):Float;
	
	private function get_position():Vector3D 
	{
		return _position;
	}
	
	private function set_position(value:Vector3D):Vector3D 
	{
		return _position = value;
	}
	
	public var position(get_position, set_position):Vector3D;
	
	private function get_colorAsRGB():RGB 
	{
		return _colorAsRGB;
	}
	
	private function set_colorAsRGB(value:RGB):RGB 
	{
		return _colorAsRGB = value;
	}
	
	public var colorAsRGB(get_colorAsRGB, set_colorAsRGB):RGB;
}
package tools;
import flash.geom.Point;
import flash.geom.Vector3D;

/**
 * ...
 * @author Samuel Bouchet
 */

class FastMath 
{
	public static var math = Math;

	public static function fastDistance(p1:Point, p2:Point):Float {
		var dx:Int = Std.int(p1.x - p2.x);
		var dy:Int = Std.int(p1.y - p2.y);
		var min:Int;
		var max:Int;
		
		if ( dx < 0 ) dx = -dx;
		if ( dy < 0 ) dy = -dy;

		if ( dx < dy ) {
			min = dx;
			max = dy;
		} else {
			min = dy;
			max = dx;
		}

		// coefficients equivalent to ( 123/128 * max ) and ( 51/128 * min )
		return ((( max << 8 ) + ( max << 3 ) - ( max << 4 ) - ( max << 1 ) + 
			( min << 7 ) - ( min << 5 ) + ( min << 3 ) - ( min << 1 )) >> 8 );
	}
	
	public static function fastDistance2D(v1:Vector3D, v2:Vector3D):Float {
		var dx:Int = Std.int(v1.x - v2.x);
		var dy:Int = Std.int(v1.y - v2.y);
		var min:Int;
		var max:Int;
		
		if ( dx < 0 ) dx = -dx;
		if ( dy < 0 ) dy = -dy;

		if ( dx < dy ) {
			min = dx;
			max = dy;
		} else {
			min = dy;
			max = dx;
		}

		// coefficients equivalent to ( 123/128 * max ) and ( 51/128 * min )
		return ((( max << 8 ) + ( max << 3 ) - ( max << 4 ) - ( max << 1 ) +
			( min << 7 ) - ( min << 5 ) + ( min << 3 ) - ( min << 1 )) >> 8 );
	}
	
	public static inline function acos(x:Float):Float {
	   return (-0.69813170079773212 * x * x - 0.87266462599716477) * x + 1.5707963267948966;
	}
	
	public function new() 
	{
		
	}
	
	
	
}
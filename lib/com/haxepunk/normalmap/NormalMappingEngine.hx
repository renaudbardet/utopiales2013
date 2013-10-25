package com.haxepunk.normalmap;
import flash.geom.Vector3D;
import tools.FastMath;

/**
 * Calculate lightning for a light and a NormalMappedBitmapData.
 * Data is provided using a LightBitmapDataInfo that contains links to both light and NormalMappedBitmapData data.
 * The current position of the NormalMappedBitmapData is required as well since the BitmapData itself doesn't know 
 * his display position.
 * @author Samuel Bouchet
 */
class NormalMappingEngine
{
	static private var pxIntensity:Float;
	static private var finalIntensity:Float;
	static private var angleDiff:Float;
	static private var pixelAngle:Vector3D = new Vector3D();
	static private var infos:LightBitmapDataInfo;
	
	static public function update(infos:LightBitmapDataInfo, bitmapPosition:Vector3D):Bool
	{
		var i:Int = infos.lightBuffer.length-1;
		var changed:Bool = false;
		for (pixelData in infos.pixelsData) {
			if (pixelData.sourcePixelColor.a > 0) {
				
				// remove the last changes, then apply the new ones
				pixelData.globalBufferPixel.r -= pixelData.lightBufferPixel.r;
				pixelData.globalBufferPixel.g -= pixelData.lightBufferPixel.g;
				pixelData.globalBufferPixel.b -= pixelData.lightBufferPixel.b;
				
				pixelData.lightBufferPixel.r = 0;
				pixelData.lightBufferPixel.g = 0;
				pixelData.lightBufferPixel.b = 0;
				
				// TODO : optimize here ( 15ms/93ms = 16%);
				pxIntensity = infos.light.getIntensityAt(pixelData.pxX + bitmapPosition.x, pixelData.pxY + bitmapPosition.y, bitmapPosition.z);
				
				if (pxIntensity > 0) {
					// accurate position of light for each pixel
					// TODO : optimize here ( 15ms/93ms = 16%);
					pixelAngle.x = -(bitmapPosition.x + pixelData.pxX - infos.light.position.x);
					pixelAngle.y = -(bitmapPosition.y + pixelData.pxY - infos.light.position.y);
					pixelAngle.z = -(bitmapPosition.z - infos.light.position.z);
					pixelAngle.normalize();
					
					// lower value means lower exposure and higher values means higher exposure
					angleDiff = pixelData.mapAngle.dotProduct(pixelAngle);
					
					finalIntensity = pxIntensity * angleDiff;
						
					if (finalIntensity > 0) {
						// calculate new color
						pixelData.lightBufferPixel.r = Math.min(1,(pixelData.sourcePixelColor.r * infos.light.colorAsRGB.r) * finalIntensity);
						pixelData.lightBufferPixel.g = Math.min(1,(pixelData.sourcePixelColor.g * infos.light.colorAsRGB.g) * finalIntensity);
						pixelData.lightBufferPixel.b = Math.min(1,(pixelData.sourcePixelColor.b * infos.light.colorAsRGB.b) * finalIntensity);
						
						pixelData.globalBufferPixel.r += pixelData.lightBufferPixel.r;
						pixelData.globalBufferPixel.g += pixelData.lightBufferPixel.g;
						pixelData.globalBufferPixel.b += pixelData.lightBufferPixel.b;
						pixelData.globalBufferPixel.userData.changed = true;
						changed = true;
					}
				}
			}
			// if there was a changed last time but not this time, change one time again (case there is no more light).
			if (pixelData.globalBufferPixel.userData.changed) {
				pixelData.globalBufferPixel.userData.changedLastTime = true;	
			} else if (pixelData.globalBufferPixel.userData.changedLastTime) {
				pixelData.globalBufferPixel.userData.changedLastTime = false;	
				pixelData.globalBufferPixel.userData.changed = true;	
			}
			
			i--;
		}
		// if there was a changed last time but not this time, change one time again (case there is no more light).
		if (changed) {
			infos.changedLastTime = true;	
		} else if (infos.changedLastTime) {
			infos.changedLastTime = false;
			changed = true;
		}
		return changed;
	}
}
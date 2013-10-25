package com.haxepunk.animation;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * A Sequence of BitmapFrame that can be used to display animations. Support MovieClip import.
 * Ported from alkemi-games framework "CachedAnimation".
 * @author Alkemi-games
 * @author Lythom
 */
class Sequence
{
	private var _name:String;
	private var _frames:Array<BitmapFrame>;
	private var _frameRate:Float;
	private var _loop:Bool;
	
	/**
	 * Create a new sequence of BitmapFrame. Use AnimatedSprite to display and drive Sequences.
	 * @param	name		name of this sequence
	 * @param	frameRate	framerate of the animation speed
	 * @param	loop		loop the animation or stop at the end
	 */
	public function new(name:String, frameRate:Float = 0, loop:Bool = true) 
	{
		this.name = name;
		this.frames = new Array<BitmapFrame>();
		this.frameRate = frameRate;
		this.loop = loop;
	}
	
	/**
	 * Duplicate a sequence using the same frames.
	 * @param	name	name of the new sequence.
	 * @return
	 */
	public function duplicate(name:String):Sequence {
		var s:Sequence = new Sequence(name, _frameRate, _loop);
		for (f in _frames) {
			s._frames.push(f);
		}
		return s;
	}
	
	/**
	 * Add several BitmapFrame to this sequence.
	 * @param	frames
	 * @param 	frameIds	list of frame ids to add, others are ignored. If null (default) every frames are added.
	 */
	public function addFrames(frames:Array<BitmapFrame>, frameIds:Array<Int> = null) {
		
		// add specific frames
		if (frameIds != null) {
			for (i in frameIds) {
				this.frames.push(frames[i]);
			}
			
		// add all
		} else {
			for (f in frames) {
				this.frames.push(f);
			}
		}
	}
	
	/**
	 * Build the sequance using the frames of a MovieClip.
	 * This MovieClip can be composed of child MovieClip
	 * @param	movieClip		MovieClip to transforme into a sequence of BitmapFrame
	 * @param	cycleChildren	if true, loop animation of children if it is shorter than the parent's animation.
	 */
	public function buildFromMovieClip(movieClip:Dynamic, padding:Int = 1, cycleChildren:Bool=true) 
	{
		if (movieClip == null) return;
		
		var mc:Dynamic = movieClip;
		var length:Int = mc.totalFrames;
		var rect:Rectangle ;
		var matrix:Matrix = new Matrix ();
		var decal:Point = new Point();
		var colorTransform:ColorTransform = mc.transform.colorTransform ;
		
		
		// for each frame, generate a BitmapFrame
		for (i in 1...length)
		{
			mc.gotoAndStop( i );
			
			matrix.identity();
			matrix.rotate( mc.rotation );
			
			// new bounds according to rotation
			var topLeft:Point = matrix.transformPoint(new Point(0, 0));
			var topRight:Point = matrix.transformPoint(new Point(mc.width, 0));
			var bottomLeft:Point = matrix.transformPoint(new Point(0, mc.height));
			var bottomRight:Point = matrix.transformPoint(new Point(mc.width, mc.height));
			var bmpX:Float = Math.min(topLeft.x, topRight.x);
			bmpX = Math.min(bmpX, bottomLeft.x);
			bmpX = Math.min(bmpX, bottomRight.x);
			var bmpY:Float = Math.min(topLeft.y, topRight.y);
			bmpY = Math.min(bmpY, bottomLeft.y);
			bmpY = Math.min(bmpY, bottomRight.y);
			var bmpWidth:Float = Math.max(topLeft.x, topRight.x);
			bmpWidth = Math.max(bmpWidth, bottomLeft.x);
			bmpWidth = Math.max(bmpWidth, bottomRight.x);
			bmpWidth = Math.abs(bmpWidth - bmpX);
			var bmpHeight:Float = Math.max(topLeft.y, topRight.y);
			bmpHeight = Math.max(bmpHeight, bottomLeft.y);
			bmpHeight = Math.max(bmpHeight, bottomRight.y);
			bmpHeight = Math.abs(bmpHeight - bmpY);
			
			// decal if needed (movieClip point of rotation is not necessary at 0,0)
			rect = mc.getBounds( mc );
			if ( mc.scaleX > 0 )
				decal.x = Math.ceil( -rect.x * mc.scaleX);
			else
				decal.x = Math.ceil( -(rect.width + rect.x) * mc.scaleX )  ;
			
			if ( mc.scaleY > 0 )
				decal.y = Math.ceil( -rect.y * mc.scaleY)  ;
			else
				decal.y = Math.ceil( -(rect.height + rect.y ) * mc.scaleY )  ;
			
			// transform the decal according to rotation
			decal = matrix.transformPoint(decal);
			decal.x -= bmpX - padding ;
			decal.y -= bmpY - padding;
			
			// scale and translate to print at the right place
			matrix.scale( mc.scaleX, mc.scaleY );	
			matrix.translate( decal.x, decal.y );
			
			var bitmapData:BitmapData = new BitmapData(
				Math.ceil(bmpWidth) + padding * 2,
				Math.ceil(bmpHeight) + padding * 2,
				true,
				0x00000000 );
			bitmapData.draw( mc, matrix, colorTransform );
			
			// Stores each frame of the MovieClip in a CachedFrame with visual and pivot informations
			frames.push(new BitmapFrame(bitmapData, new Point(decal.x, decal.y)));
			
			// Step forward recursively every child of the movie clip
			stepChildren(movieClip, cycleChildren);
			
		}
		
		mc = null ;
	}
	
	private function stepChildren(movieClip:Dynamic, cycleChildren:Bool) 
	{
		var nbChildren:Int = movieClip.numChildren;
		
		for (iChild in 0...nbChildren)
		{
			if (Std.is(movieClip.getChildAt(iChild), MovieClip)) {
				
				// le test de type est obligatoire car certains child sont des objets Bitmap et non des MC...
				var child:Dynamic = movieClip.getChildAt(iChild) ;
				
				if (child.currentFrame == child.totalFrames )
				{
					if ( cycleChildren ) {
						child.gotoAndStop ( 1 ) ;
					}
				} else {
					child.gotoAndStop(child.currentFrame+1) ;
				}
				
				// recursive call while there are children
				stepChildren(child, cycleChildren);
			}
		}
				
	}
	
	private function get_frames():Array<BitmapFrame> 
	{
		return _frames;
	}
	
	private function set_frames(value:Array<BitmapFrame>):Array<BitmapFrame> 
	{
		return _frames = value;
	}
	
	public var frames(get_frames, set_frames):Array<BitmapFrame>;
	
	private function get_frameRate():Float 
	{
		return _frameRate;
	}
	
	private function set_frameRate(value:Float):Float 
	{
		return _frameRate = value;
	}
	
	public var frameRate(get_frameRate, set_frameRate):Float;
	
	private function get_loop():Bool 
	{
		return _loop;
	}
	
	private function set_loop(value:Bool):Bool 
	{
		return _loop = value;
	}
	
	public var loop(get_loop, set_loop):Bool;
	
	private function get_name():String 
	{
		return _name;
	}
	
	private function set_name(value:String):String 
	{
		return _name = value;
	}
	
	public var name(get_name, set_name):String;
	
}
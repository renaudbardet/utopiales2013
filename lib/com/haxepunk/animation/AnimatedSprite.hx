package com.haxepunk.animation;

import com.haxepunk.animation.BitmapFrame;
import com.haxepunk.animation.Sequence;
import com.haxepunk.Graphic;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.SpreadMethod;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.HXP;

/**
 * Animated Sprite composed of one or multiple Senquence.
 * Animated Sprite works like a Spritemap. Listen to Event.COMPLETE to know when the animation is over.
 */
class AnimatedSprite extends Graphic implements IEventDispatcher
{
	/**
	 * If the animation has stopped.
	 */
	public var complete:Bool;

	/**
	 * Animation speed factor, alter this to speed up/slow down all animations.
	 */
	public var rate:Float;
	
	static private var zeroPoint:Point = new Point();
	static private var rect:Rectangle = new Rectangle();

	/**
	 * Constructor.
	 */
	public function new()
	{
		complete = true;
		rate = 1;
		_anims = new Map<String,Sequence>();
		_timer = 0;
		_frame = null;
		
		_eventDispatcher = new EventDispatcher();
		
		super();
		
		active = true;
	}
	
	/**
	 * Create a BitmapFrame list from a bitmapData source, setting defaultPivotPoint as Pivot point for thoses frames.
	 * @param	bmpData
	 * @param	defaultPivotPoint
	 * @return	Array<BitmapFrame>
	 */
	static public function createFramesFromBitmap(bmpData:BitmapData, frameWidth:Int, frameHeight:Int, defaultPivotPoint:Point=null):Array<BitmapFrame> {
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
				bmpD.copyPixels(bmpData, AnimatedSprite.rect, AnimatedSprite.zeroPoint);
				array.push(new BitmapFrame(bmpD, new Point(defaultPivotPoint.x, defaultPivotPoint.y)));
			}
		}
		return array;
	}

	/** @private Updates the animation. */
	override public function update() {
		
		if (_anim != null && !complete) {
			_timer += _anim.frameRate * HXP.elapsed * rate;
			
			while (_timer >= 1 && !complete){
				_timer --;
				_index ++;
				
				if (_index >= _anim.frames.length) {
					if (_anim.loop) {
						_index = 0;
						dispatchEvent(new Event(Event.COMPLETE));
						
					} else {
						_index = _anim.frames.length - 1;
						complete = true;
						dispatchEvent(new Event(Event.COMPLETE));
					}
				}
			}
			frame = _anim.frames[_index];
		}
	}
	
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		if (_frame != null) {
			_point.x = point.x - _frame.pivot.x + x - camera.x * scrollX;
			_point.y = point.y - _frame.pivot.y + y - camera.y * scrollY;
			target.copyPixels(_frame.bitmapData, _frame.bitmapData.rect, _point, null, null, true);
		}
		super.render(target, point, camera);
	}
	

	/**
	 * Add a Sequence.
	 * @param	sequence The sequence to add.
	 */
	public function add(sequence:Sequence)
	{
		if (_anims.get(sequence.name) != null) throw "Cannot have multiple sequences with the same name";
		_anims.set(sequence.name, sequence);
	}
	
	/**
	 * Get a Sequence.
	 * @param	sequence The sequence name to retreive.
	 */
	public function getSequence(sequenceName:String):Sequence
	{
		return _anims.get(sequenceName);
	}

	/**
	 * Plays an sequence.
	 * @param	name		Name of the sequence to play.
	 * @param	reset		If the sequence should force-restart if it is already playing.
	 * @return	Sequence object representing the played sequence.
	 */
	public function play(name:String = "", reset:Bool = false):Sequence
	{
		// keep the current sequence
		if (!reset && _anim != null && _anim.name == name) {
			return _anim;
		}
		// find and init sequence
		_anim = _anims.get(name);
		if (_anim != null) {
			complete = false;
			frame = _anim.frames[0];
		} else {
			// sequence not found, stop the animation
			complete = true;
			frame = null;
		}
		_index = 0;
		_timer = 0;
		
		return _anim;
	}

	/**
	 * Gets the current frame.
	 * @return	BitmapFrame.
	 */
	public function get_frame():BitmapFrame
	{
		return _frame;
	}
	/**
	 * Sets the current display frame. When you set the frame,
	 * any animations playing will be stopped to force the frame.
	 * @param	bitmapFrame		Frame to set.
	 */
	public function set_frame(bitmapFrame:BitmapFrame):BitmapFrame
	{
		if (_frame == bitmapFrame) return _frame;
		return _frame = bitmapFrame;
	}
	public var frame(get_frame, set_frame):BitmapFrame;

	/**
	 * Assigns the Spritemap to a random frame.
	 * @param	sequenceName	A random frame in this sequence.
	 */
	public function randFrame(sequenceName:String=null)
	{
		var seq:Sequence = _anims.get(sequenceName);
		if (seq != null) {
			frame = seq.frames[HXP.rand(seq.frames.length)];
		}
	}

	/**
	 * Sets the frame to the frame index of a sequence.
	 * @param	name	Sequence to draw the frame frame.
	 * @param	index	Index of the frame of the animation to set to.
	 */
	public function setAnimFrame(name:String, index:Int)
	{
		var seq:Sequence = _anims.get(name);
		if (seq != null && index >= 0 && index < seq.frames.length) {	
			this.index = index;
		}
	}

	/**
	 * Current index of the playing animation.
	 */
	public var index(get_index, set_index):Int;
	private function get_index():Int { return _anim != null ? _index : 0; }
	private function set_index(value:Int):Int
	{
		if (_anim == null) {
			return 0;
		}
		if (_anim != null && value >= 0 && value < _anim.frames.length) {
			_index = value;
			frame = _anim.frames[_index];
		}
		return _index;
	}

	/**
	 * The currently playing animation.
	 */
	public var currentAnim(get_currentAnim, null):String;
	private function get_currentAnim():String { return (_anim != null) ? _anim.name : ""; }

	/* INTERFACE flash.events.IEventDispatcher */
	public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void 
	{
		_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	public function dispatchEvent(event:Event):Bool 
	{
		return _eventDispatcher.dispatchEvent(event);
	}
	
	public function hasEventListener(type:String):Bool 
	{
		return _eventDispatcher.hasEventListener(type);
	}
	
	public function removeEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false):Void 
	{
		_eventDispatcher.removeEventListener(type, listener, useCapture);
	}
	
	public function willTrigger(type:String):Bool 
	{
		return _eventDispatcher.willTrigger(type);
	}
	
	// Spritemap information.
	private var _rect:Rectangle;
	private var _anims:Map<String,Sequence>;
	private var _anim:Sequence;
	private var _index:Int;
	private var _frame:BitmapFrame;
	private var _timer:Float;
	private var _eventDispatcher:EventDispatcher;
	
	#if cpp
	private var _baseID:Int;
	#end
}
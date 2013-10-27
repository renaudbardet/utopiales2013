package com.haxepunk.gui.tween;

import com.haxepunk.HXP;
import com.haxepunk.Tween;
import com.haxepunk.utils.Ease;

/**
 * Tweens from one radiant angle to another.
 */
class CarouselTween extends Tween
{
	/**
	 * The current value.
	 */
	public var angle:Float;
	static public inline var CLOCKWISE:String = "clockwise";
	static public inline var COUNTER_CLOCKWISE:String = "counter_clockwise";
	static public inline var AUTO:String = "auto";
	
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, type:TweenType) 
	{
		angle = 0;
		super(0, type, complete);
	}
	
	/**
	 * Tweens the value from one angle to another.
	 * @param	fromAngle		Start angle.
	 * @param	toAngle			End angle.
	 * @param   direction		CarouselTweener.CLOCKWISE or CarouselTweener.COUNTER_CLOCKWISE using trigonometric circle
	 * @param	duration		Duration of the tween.
	 * @param	ease			Optional easer function.
	 */
	public function tween(fromAngle:Float, toAngle:Float, direction:String, duration:Float, ease:EaseFunction = null)
	{
		_start = angle = fromAngle;
		var d:Float = toAngle - angle,
			a:Float = d % (Math.PI * 2);
		if (a < 0) a += (Math.PI*2);
		if (direction == CLOCKWISE) {
			_range = a;
		} else if (direction == COUNTER_CLOCKWISE) {
			_range = a - (Math.PI * 2);
		} else {
			_range = (Math.abs(a) < Math.abs(a - (Math.PI * 2)))? a : a - (Math.PI * 2);
		}
		_target = duration;
		_ease = ease;
		start();
	}
	
	/** @private Updates the Tween. */
	override public function update() 
	{
		super.update();
		angle = (_start + _range * _t);
		if (angle < 0) angle += (Math.PI*2);
	}
	
	// Tween information.
	private var _start:Float;
	private var _range:Float;
}
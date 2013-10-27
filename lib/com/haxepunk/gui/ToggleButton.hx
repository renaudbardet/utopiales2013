package com.haxepunk.gui;

import com.haxepunk.Graphic;
import com.haxepunk.gui.event.ControlEvent;
import com.haxepunk.gui.graphic.NineSlice;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import flash.events.Event;
import flash.geom.Rectangle;

class ToggleButton extends Button
{
	static public inline var ADDED_TO_CONTAINER:String = "added_to_container";
	static public inline var REMOVED_FROM_CONTAINER:String = "removed_from_container";
	static public inline var ADDED_TO_WORLD:String = "added_to_world";
	static public inline var REMOVED_FROM_WORLD:String = "removed_from_world";
	static public inline var HIDDEN:String = "hidden";
	static public inline var SHOWN:String = "shown";
	static public inline var CLICKED:String = "clicked";
	static public inline var MOUSE_HOVER:String = "mouseHover";
	static public inline var MOUSE_OUT:String = "mouseOut";
	static public inline var RESIZED:String = "resized";

	private var hoverDown:Graphic;
	private var inactiveDown:Graphic;

	/**
	 * Create a toggle button.
	 * @param	text		Label text
	 * @param	checked		initial state
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 */
	public function new(text:String = "Toggle", checked:Bool = false, x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0)
	{
		if (hoverDown == null) hoverDown = new NineSlice(width, height, new Rectangle(24, 24, 8, 8));
		if (inactiveDown == null) inactiveDown = new NineSlice(width, height, new Rectangle(48, 24, 8, 8));
		this.checked = checked;
		super(text, x, y, width, height);
	}

	override public function updateSize(?e:Event):Void
	{
		super.updateSize();
		cast(hoverDown,NineSlice).width = this.width;
		cast(hoverDown,NineSlice).height = this.height;
		cast(inactiveDown,NineSlice).width = this.width;
		cast(inactiveDown,NineSlice).height = this.height;
	}

	override public function update()
	{
		// Copy the Control update because we don't want parent's update but
		// we still want Control update
		// super.super.update() doesn't work. Any known way of doing it ?
		if (x != _lastX) _lastX = x;
		if (y != _lastY) _lastY = y;
		if ((_lastWidth != width) || (_lastHeight != height)) {
			if (_lastWidth != width) _lastWidth = width;
			if (_lastHeight != height) _lastHeight = height;
			dispatchEvent(new ControlEvent(this, RESIZED));
		}

		// within a container, move using local coordinates
		updateChildPosition();

		// really add new children
		doAddChildren();

		if (!_enabled)
		{
			if (checked) {
				graphic = inactiveDown;
			} else {
				graphic = inactive;
			}
		} else if (scene != null && isChild(scene.collidePoint(this.type, Input.mouseX+ HXP.camera.x, Input.mouseY + HXP.camera.y))) {
			if (Input.mousePressed)
			{
				checked = !checked;
			}
			else
			{
				if (_checked) {
					graphic = hoverDown;
				} else {
					graphic = hover;
				}
				if(!_overCalled) {
					dispatchEvent(new ControlEvent(this, MOUSE_HOVER));
					_overCalled = true;
					_outCalled = false;
				}
			}
		}
		else
		{
			if(!_outCalled) {
				dispatchEvent(new ControlEvent(this, MOUSE_OUT));
				_overCalled = false;
				_outCalled = true;
			}

			if (_checked) {
				graphic = down;
			} else {
				graphic = normal;
			}
		}
	}

	/**
	 * update or get the toggle button state.
	 */
	public var checked(get_checked, set_checked):Bool;
	private function get_checked():Bool { return _checked; }
	private function set_checked(value:Bool):Bool {
		_checked = value;
		return _checked;
	}

	private var _checked:Bool;

}
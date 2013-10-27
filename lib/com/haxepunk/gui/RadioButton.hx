package com.haxepunk.gui;

import com.haxepunk.gui.event.ControlEvent;
import com.haxepunk.gui.graphic.CheckedNineSlice;
import com.haxepunk.gui.graphic.NineSlice;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;

class RadioButton extends ToggleButton
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

	/**
	 * Fired when this RadioButton changes state
	 */
	static public inline var CHANGED:String = "changed";
	/**
	 * Fired when any RadioButton of the group is clicked. You only have to listen to this event on one of the RadioButton.
	 */
	static public inline var GROUP_CHANGED:String = "groupChanged";

	/**
	 * How big sould the selector picture be ? 12 is the default (bitmap native) size.
	 * Set '0' to autosize from label text size.
	 */
	static public var defaultBoxSize:Int = 12;

	private var _boxSize:Int;
	private var _fixedBox:Bool;
	private var _group:String;
	private var _value:String;

#if haxe3
	private static var _groups:Map<String,Array<RadioButton>> = new Map<String,Array<RadioButton>> ();
#else
	private static var _groups:Hash<Array<RadioButton>> = new Hash<Array<RadioButton>> ();
#end

	/**
	 * Create a RadioButton Control.
	 * @param	group		group that have an exclusive value among the RadioButton sharing it. Group is created with the first RadioButton added to Scene.
	 * @param	text		Label text
	 * @param 	value		value returned by the RadioButton.getValue(group) function if this RadioButton is selected
	 * @param	x			X coordinate
	 * @param	y			Y coordinate
	 */
	public function new(group:String, text:String = "Radio", value:String = null, x:Float = 0, y:Float = 0)
	{
		_group = group;
		_value = value;
		_boxSize = defaultBoxSize;
		_fixedBox = (_boxSize > 0);
		_align = TextFormatAlign.LEFT;

		_skin = Control.currentSkin;

		// 12x12 squares composed of 9 4x4 slices
		// at 36,48
		if (normal == null) normal = new NineSlice(12, 12, new Rectangle(36, 48, 4, 4));
		// + check at 36,60
		if (down == null) down = new CheckedNineSlice(12, 12, new Rectangle(36, 48, 4, 4), new Rectangle(36, 60, 12, 12));
		// at 48,48
		if (hover == null) hover = new NineSlice(12, 12, new Rectangle(48, 48, 4, 4));
		// + check at 48,60
		if (hoverDown == null) hoverDown = new CheckedNineSlice(12, 12, new Rectangle(48, 48, 4, 4), new Rectangle(48, 60, 12, 12));
		// at 60,48
		if (inactive == null) inactive = new NineSlice(12, 12, new Rectangle(60, 48, 4, 4));
		// + check at 60,60
		if (inactiveDown == null) inactiveDown = new CheckedNineSlice(12, 12, new Rectangle(60, 48, 4, 4), new Rectangle(60, 60, 12, 12));

		super(text, false, x, y, 0, 0);
		width = label.width + _boxSize;
		height = Math.floor(Math.max(label.height, _boxSize));
	}

	/**
	 * Return the selected button value among the specified group.
	 * @param group The group to retreive selected RadioButton from
	 */
	public static function getValue(group:String):String {
		var groupValue:String = null;

		if (_groups.exists(group)) {
			var itRadioButton:Iterator<RadioButton> = _groups.get(group).iterator();
			var trouve:Bool = false;
			var rb:RadioButton = null;
			while (itRadioButton.hasNext() && groupValue==null) {
				rb = itRadioButton.next();
				if (rb._checked) {
					groupValue = rb._value;
				}
			}
		}

		return groupValue;
	}

	override public function added()
	{
		addToGroup(_group);
		super.added();
	}

	override public function removed()
	{
		removeFromGroup();
		super.removed();
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

		// radio button specific behaviour
		if (!enabled) {
			if (checked) {
				graphic = inactiveDown;
			} else {
				graphic = inactive;
			}
		} else {
			if (scene != null && isChild(scene.collidePoint(this.type, Input.mouseX + HXP.camera.x, Input.mouseY + HXP.camera.y))) {
				if (Input.mousePressed) {
					select();
				} else {
					// update visual
					if (_checked) {
						graphic = hoverDown;
					} else {
						graphic = hover;
					}

					if (!_overCalled) {
						// trigger event
						dispatchEvent(new ControlEvent(this, MOUSE_HOVER));
						_overCalled = true;
						_outCalled = false;
					}
				}
			} else {
				// update visual
				if (_checked) {
					graphic = down;
				} else {
					graphic = normal;
				}
				if (!_outCalled) {
					// trigger event
					dispatchEvent(new ControlEvent(this, MOUSE_OUT));
					_overCalled = false;
					_outCalled = true;
				}
			}
		}
	}

	/**
	 * Select this radioButton in the group.
	 */
	public function select()
	{
		uncheckAll(this._group);
		_checked = true;
		dispatchEvent(new ControlEvent(this, CHANGED));
		for (rb in _groups.get(group)) {
			rb.dispatchEvent(new ControlEvent(this, GROUP_CHANGED));
		}
	}

	/**
	 * unselect every RadioButton in the group
	 * @param	group
	 */
	private function uncheckAll(group:String)
	{
		for (rb in _groups.get(group)) {
			rb._checked = false;
		}
	}

	override private function set_checked(value:Bool):Bool
	{
		if (value) {
			select();
		}
		return super.set_checked(value);
	}

	// Called automatically once by the Button contructor
	override public function updateSize(?e:Event):Void
	{
		// update label size
		label.updateBuffer();

		if ( !_fixedBox ) {
			_boxSize = label.size+4;
		}
			// update the graphics display
		if (cast(normal, NineSlice).width != this._boxSize) {
			cast(normal,NineSlice).width = this._boxSize;
			cast(normal,NineSlice).height = this._boxSize;
			cast(hover,NineSlice).width = this._boxSize;
			cast(hover,NineSlice).height = this._boxSize;
			cast(down,NineSlice).width = this._boxSize;
			cast(down, NineSlice).height = this._boxSize;
			cast(hoverDown,NineSlice).width = this._boxSize;
			cast(hoverDown,NineSlice).height = this._boxSize;
			cast(inactive,NineSlice).width = this._boxSize;
			cast(inactive, NineSlice).height = this._boxSize;
			cast(inactiveDown,NineSlice).width = this._boxSize;
			cast(inactiveDown, NineSlice).height = this._boxSize;
		}

		label.localX = this._boxSize + padding;
		label.localY = this._boxSize / 2 - label.halfHeight;
		width = label.width + _boxSize;
		height = Math.floor(Math.max(label.height, _boxSize));

		dispatchEvent(new ControlEvent(this, RESIZED));
		// no parent call
	}

	override public function toString():String
	{
		return this._class + "=" + this.value;
	}

	private inline function addToGroup(group:String)
	{
		// add the RadioButton to its group
		if (!_groups.exists(group)) {
			_groups.set(group, new Array<RadioButton>());
			_groups.get(group).push(this);
		} else {
			_groups.get(group).push(this);
		}
		// select the first item
		if (_groups.get(group).length == 1) {
			select();
		}
		_group = group;
	}

	private inline function removeFromGroup()
	{
		if (_groups.exists(_group)) {
			_groups.get(_group).remove(this);
		}
	}

	private function get_group():String
	{
		return _group;
	}
	private function set_group(value:String):String
	{
		if (value != _group) {
			removeFromGroup();
			addToGroup(value);
		}
		return _group = value;
	}
	/**
	 * get the group that this radioButton belongs to.
	 */
	public var group(get_group, set_group):String;
	private function get_value(): String
	{
		return _value;
	}
	private function set_value(value:String): String
	{
		return _value = value;
	}
	/**
	 * value returned when getValue() is called for the group is this radioButton is selected.
	 */
	public var value(get_value, set_value):String;

	private function get_boxSize():Int
	{
		return _boxSize;
	}

	private function set_boxSize(value:Int):Int
	{
		_boxSize = value;
		_fixedBox = (_boxSize > 0);
		return _boxSize;
	}

	public var boxSize(get_boxSize, set_boxSize):Int;

}
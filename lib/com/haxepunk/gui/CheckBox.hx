package com.haxepunk.gui;

import com.haxepunk.gui.event.ControlEvent;
import com.haxepunk.gui.graphic.CheckedNineSlice;
import com.haxepunk.gui.graphic.NineSlice;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;

class CheckBox extends ToggleButton
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
	 * How big sould the selector picture be ? 12 is the default (bitmap native) size.
	 * Set '0' to autosize from label text size.
	 */
	static public var defaultBoxSize:Int = 12;
	
	private var _boxSize:Int;
	private var _fixedBox:Bool;
	
	/**
	 * Create a checkbox Control.
	 * @param	text
	 * @param	checked
	 * @param	x
	 * @param	y
	 */
	public function new(text:String = "Checkbox", checked:Bool = false, x:Float = 0, y:Float = 0)
	{
		_align = TextFormatAlign.LEFT;
		_boxSize = defaultBoxSize;
		_fixedBox = (boxSize > 0);
		_skin = Control.currentSkin;
		
		// 12x12 squares composed of 9 4x4 slices
		if (normal == null) normal = new NineSlice(12, 12, new Rectangle(0, 48, 4, 4));
		if (down == null) down = new CheckedNineSlice(12, 12, new Rectangle(0, 48, 4, 4), new Rectangle(0, 60, 12, 12));
		if (hover == null) hover = new NineSlice(12, 12, new Rectangle(12, 48, 4, 4));
		if (hoverDown == null) hoverDown = new CheckedNineSlice(12, 12, new Rectangle(12, 48, 4, 4), new Rectangle(0, 60, 12, 12));
		if (inactive == null) inactive = new NineSlice(12, 12, new Rectangle(24, 48, 4, 4));
		if (inactiveDown == null) inactiveDown = new CheckedNineSlice(12, 12, new Rectangle(24, 48, 4, 4), new Rectangle(24, 60, 12, 12));
		
		super(text, checked, x, y, 0, 0);
		width = label.width + boxSize;
		height = Math.floor(Math.max(label.height, boxSize));
	}
	
	// Called automatically once by the Button contructor
	override public function updateSize(?e:Event):Void
	{
		// update label size
		label.updateBuffer();
		
		if (!_fixedBox) {
			this.boxSize = label.size+4;
		}
		
		// update the graphics display
		if (cast(normal, NineSlice).width != this.boxSize) {
			cast(normal,NineSlice).width = this.boxSize;
			cast(normal,NineSlice).height = this.boxSize;
			cast(hover,NineSlice).width = this.boxSize;
			cast(hover,NineSlice).height = this.boxSize;
			cast(down,NineSlice).width = this.boxSize;
			cast(down, NineSlice).height = this.boxSize;
			cast(hoverDown,NineSlice).width = this.boxSize;
			cast(hoverDown,NineSlice).height = this.boxSize;
			cast(inactive,NineSlice).width = this.boxSize;
			cast(inactive, NineSlice).height = this.boxSize;
			cast(inactiveDown,NineSlice).width = this.boxSize;
			cast(inactiveDown, NineSlice).height = this.boxSize;
		}
		
		label.localX = this.boxSize+padding;
		label.localY = this.boxSize / 2 - label.halfHeight;
		width = label.width + _boxSize;
		height = Math.floor(Math.max(label.height, _boxSize));
		
		dispatchEvent(new ControlEvent(this, RESIZED));
		// no parent call
	}

	private function get_boxSize():Int
	{
		return _boxSize;
	}
	
	private function set_boxSize(value:Int):Int
	{
		return _boxSize = value;
	}
	/**
	 * Size of the tickbox in px.
	 */
	public var boxSize(get_boxSize, set_boxSize):Int;

}
package com.haxepunk.gui;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.gui.Control;
import com.haxepunk.gui.event.ControlEvent;
import com.haxepunk.gui.graphic.NineSlice;
import com.haxepunk.utils.Input;
import flash.events.Event;
import flash.geom.Rectangle;

/**
 * Menu acting like a contextual menu or an app top menu.
 * Any control can be add as Item.
 * @author Lythom
 */
class MenuList extends Panel
{
	static public inline var ADDED_TO_CONTAINER:String = "added_to_container";
	static public inline var REMOVED_FROM_CONTAINER:String = "removed_from_container";
	static public inline var ADDED_TO_WORLD:String = "added_to_world";
	static public inline var REMOVED_FROM_WORLD:String = "removed_from_world";
	static public inline var HIDDEN:String = "hidden";
	static public inline var SHOWN:String = "shown";
	static public inline var RESIZED:String = "resized";
	static public inline var MOUSE_HOVER:String = "mouseHover";
	static public inline var MOUSE_OUT:String = "mouseOut";
	static public inline var CLICKED:String = "clicked";
	static public inline var SELECTION_CHANGED:String = "selectionChanged";

	/**
	 * Padding inside the Menu panel, around the list
	 */
	private static var defaultPadding:Int = 4;

	/**
	 * Padding inside the selector, around the selected item.
	 */
	private static var defaultSelectorPadding:Int = 0;

	private var _selectedId:Int;
	private var _padding:Int;
	private var _autoWidth:Bool;
	private var _selector:Graphiclist;
	private var _selectorEnabled:NineSlice;
	private var _selectorDisabled:NineSlice;
	private var _selectorPadding:Int;


	/**
	 * Create a MenuList component that display child in a list of selectable elements.
	 * @param	x		x/localX pos of the MenuList
	 * @param	y		y/localY pos of the MenuList
	 * @param	width	width of the MenuList
	 */
	public function new(x:Float = 0, y:Float = 0, width:Int=0)
	{
		_selectedId = -1;
		if (width == 0) {
			autoWidth = true;
		}

		super(x, y, width, 0);
		_padding = MenuList.defaultPadding;
		_selectorPadding = defaultSelectorPadding;

		_selectorEnabled = new NineSlice(24, 24, new Rectangle(96, 0, 8, 8));
		_selectorDisabled = new NineSlice(24, 24, new Rectangle(96, 24, 8, 8));

		// the selector is composed of his 2 states, enabled and disabled.
		// only the needed one is displayed.
		_selector = new Graphiclist();
		_selector.add(_selectorDisabled);
		_selector.add(_selectorEnabled);
		_selectorDisabled.width = this.width;
		_selectorDisabled.visible = false;
		_selectorEnabled.width = this.width;
		_selectorEnabled.visible = true;

		_overCalled = false;
		_outCalled = true;

		addGraphic(_selector);
	}

	override public function added()
	{
		super.added();
		updateChildPosition();
	}

	/**
	 * @private
	 */
	override public function update()
	{
		if (_enabled) {
			var frontControl:Entity = null;
			if (scene != null) {
				frontControl = scene.collidePoint(this.type, Input.mouseX + HXP.camera.x, Input.mouseY + HXP.camera.y);
			}
			if (scene != null && frontControl != null && frontControl != this && isChild(frontControl)) {
				// check each item
				for (c in children) {
					// change selection when mouse is hover
					if (c.isChild(frontControl)) {
						selectedId = Lambda.indexOf(children, c);
					}
				}
				// hover event
				if(!_overCalled){
					dispatchEvent(new ControlEvent(this, MOUSE_HOVER));
					_overCalled = true;
					_outCalled = false;
				}
				// click event
				if (Input.mousePressed) {
					dispatchEvent(new ControlEvent(this, CLICKED));
				}

			} else {
				// out event
				if (!_outCalled) {
					dispatchEvent(new ControlEvent(this, MOUSE_OUT));
					_overCalled = false;
					_outCalled = true;
				}
			}
		}
		super.update();
	}

	override private function updateChildPosition()
	{
		var i:Int = 0;
		for (i in 0...children.length){
			var c:Control = children[i];
			c.localX = padding;
			if (i > 0) {
				c.localY = children[i - 1].localY + children[i - 1].height;
			} else {
				c.localY = padding;
			}
		}
		super.updateChildPosition();
	}

	override public function addControl(child:Control, ?position:Int):Void
	{
		child.addEventListener(Control.ADDED_TO_CONTAINER, childAdded);
		super.addControl(child, position);
	}

	private function childAdded(e:ControlEvent):Void
	{
		e.control.removeEventListener(Control.ADDED_TO_CONTAINER, childAdded);
		resize();
		updateChildPosition();
		if (children.length == 1) {
			selectedId = 0;
		}
	}

	override public function removeControl(child:Control):Void
	{
		super.removeControl(child);
		resize();
	}

	/**
	 * Hide this control and its children
	 * @param	?e
	 */
	override public function hide(?e:Event):Void
	{
		_overCalled = false;
		_outCalled = true;
		super.hide(e);
	}

	/**
	 * Show this control and its children
	 * @param	?e
	 */
	override public function show(?e:Event):Void
	{
		super.show(e);
	}


	override private function set_enabled(value:Bool):Bool
	{
		_selectorEnabled.visible = value;
		_selectorDisabled.visible = !value;
		return super.set_enabled(value);
	}

	public function resize()
	{
		var w:Int = 0;
		var h:Int = padding;
		for (c in children) {
			w = Math.floor(Math.max(w, c.width));
			h += c.height;
		}
		if(autoWidth){
			this.width = w + padding * 2;
		}
		this.height = h + padding;
		_selectorEnabled.width = this.width;
		_selectorDisabled.width = this.width;
	}

	public var selectedItem(get_selectedItem, set_selectedItem):Control;
	private function get_selectedItem():Control
	{
		var c:Control = null;
		if (children.length > 0) {
			c = children[_selectedId];
		}
		return c;
	}

	private function set_selectedItem(value:Control):Control
	{
		selectedId = Lambda.indexOf(children, value);
		return value;
	}

	private function get_selectedId():Int
	{
		return _selectedId;
	}

	private function set_selectedId(value:Int):Int
	{
		if (value >= 0 && value < children.length) {
			if (value != _selectedId) {
				_selectedId = value;
				var c:Control = children[value];
				_selectorDisabled.height = c.height + selectorPadding * 2;
				_selectorEnabled.height = c.height + selectorPadding * 2;
				_selector.x = 0;
				_selector.y = c.localY - selectorPadding;
				dispatchEvent(new ControlEvent(this, SELECTION_CHANGED));
			}
		}

		return _selectedId ;
	}
	public var selectedId(get_selectedId, set_selectedId):Int;

	private function get_padding():Int
	{
		return _padding;
	}

	private function set_padding(value:Int):Int
	{
		return _padding = value;
	}

	public var padding(get_padding, set_padding):Int;

	private function get_autoWidth():Bool
	{
		return _autoWidth;
	}

	private function set_autoWidth(value:Bool):Bool
	{
		return _autoWidth = value;
	}

	public var autoWidth(get_autoWidth, set_autoWidth):Bool;

	private function get_selector():Graphiclist
	{
		return _selector;
	}

	private function set_selector(value:Graphiclist):Graphiclist
	{
		return _selector = value;
	}

	public var selector(get_selector, set_selector):Graphiclist;

	private function get_selectorPadding():Int
	{
		return _selectorPadding;
	}

	private function set_selectorPadding(value:Int):Int
	{
		return _selectorPadding = value;
	}

	public var selectorPadding(get_selectorPadding, set_selectorPadding):Int;

}
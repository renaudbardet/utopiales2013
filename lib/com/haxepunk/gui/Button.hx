package com.haxepunk.gui;

import com.haxepunk.Graphic;
import com.haxepunk.gui.event.ControlEvent;
import com.haxepunk.gui.graphic.NineSlice;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;

/**
 * Ui control: Button.
 * @author Rolpege
 * @author PigMess
 * @author Lythom
 */
class Button extends Control
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
	 * Use this to fit your button skin's borders, set the default padding of every new Button and ToggleButton.
	 * padding attribute can be changed on instances after creation.
	 */
	public static var defaultPadding:Int = 2;

	/**
	 * Graphic of the button when active and not pressed nor overed.
	 */
	public var normal:Graphic;
	/**
	 * Graphic of the button when the mouse overs it and it's active.
	 */
	public var hover:Graphic;
	/**
	 * Graphic of the button when the mouse is pressing it and it's active.
	 */
	public var down:Graphic;
	/**
	 * Graphic of the button when inactive.
	 */
	public var inactive:Graphic;

	/**
	 * The button's label
	 */
	public var label:Label;

	/**
	 * Create a Button with a Label.
	 * @param x			X coordinate of the button.
	 * @param y			Y coordinate of the button.
	 * @param text		Text of the button
	 * @param width		Width of the button's hitbox.
	 * @param height	Height of the button's hitbox.
	 * @param enabled	Whether the button is active or not.
	 * @param padding	Space in pixel between the borders of the Label and the borders of the Button.
	 */
	public function new(text:String = "Button", x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0)
	{
		_overCalled = false;
		_padding = Button.defaultPadding;
		_enabled = true;
		label = new Label(text, padding, padding, width, height);
		label.color = 0x000000;

		if (width != 0) {
			label.autoWidth = false;
			label.width = width - padding * 2;
			label.align = TextFormatAlign.CENTER;
		}
		if (height != 0) {
			label.autoHeight = false;
			label.height = height - padding * 2;
			label.align = TextFormatAlign.CENTER;
		}
		label.updateBuffer();

		// 24x24 squares composed of 9 8x8 slices
		if (normal == null) normal = new NineSlice(width, height, new Rectangle(0, 0, 8, 8));
		if (down == null) down = new NineSlice(width, height, new Rectangle(0, 24, 8, 8));
		if (hover == null) hover = new NineSlice(width, height, new Rectangle(24, 0, 8, 8));
		if (inactive == null) inactive = new NineSlice(width, height, new Rectangle(48, 0, 8, 8));

		super(x, y, width, height);
		setHitbox(width, height);

		// add Label
		addControl(label);

		// visual update
		updateSize();
		update();
	}

	/**
	 * Update the button to be displyed properly after it has been resized.
	 * Automatically called.
	 */
	public function updateSize(?e:Event):Void
	{

		// update button size according to the label
		if (label.autoWidth) {
			width = label.width + _padding * 2;
		} else {
			label.width = width - padding * 2;
		}
		if (label.autoHeight) {
			height = label.height + _padding * 2;
		} else {
			label.height = height - padding * 2;
		}

		// update the graphics display
		var ns:NineSlice;
		ns = cast(normal, NineSlice);
		ns.width = this.width;
		ns.height = this.height;
		ns = cast(hover, NineSlice);
		ns.width = this.width;
		ns.height = this.height;
		ns = cast(down, NineSlice);
		ns.width = this.width;
		ns.height = this.height;
		ns = cast(inactive, NineSlice);
		ns.width = this.width;
		ns.height = this.height;

		dispatchEvent(new ControlEvent(this, RESIZED));
	}

	/**
	 * @private
	 */
	override public function update()
	{
		super.update();

		if (_enabled) {
			if (scene != null && isChild(scene.collidePoint(this.type, Std.int(Input.mouseX + HXP.camera.x), Std.int(Input.mouseY + HXP.camera.y)))) {
				if (Input.mouseDown) {
					graphic = down;

				} else {
					graphic = hover;
				}
			} else {
				graphic = normal;
			}
		} else {
			graphic = inactive;
		}
	}

	/**
	 * Amount to pad between button edge and label
	 */
	public var padding(get_padding, set_padding):Int;
	private function get_padding():Int { return _padding; }
	private function set_padding(value:Int):Int {
		_padding = value;
		updateSize();
		return _padding;
	}

	// change graphic when turning to disabled
	override private function set_enabled(value:Bool):Bool
	{
		label.enabled = value;
		return super.set_enabled(value);
	}

	/**
	 * proxy to label text
	 */
	public var text(get_text, set_text):String;
	private function get_text():String { return label.text; }
	private function set_text(value:String):String {
		label.text = value;
		return value;
	}

	/**
	 * proxy to Label color
	 */
	public var color(get_color, set_color):Int;
	private function get_color():Int { return label.color; }
	private function set_color(value:Int):Int {
		label.color = value;
		return value;
	}

	/**
	 * proxy to Label Length
	 */
	public var length(get_length, never):Int;
	private function get_length():Int { return label.length; }

	/**
	 * proxy to Label Size
	 */
	public var size(get_size, set_size):Dynamic;
	private function get_size():Dynamic { return label.size; }
	private function set_size(value:Dynamic):Dynamic {
		label.size = value;
		return value;
	}

	/**
	 * proxy to Label font
	 */
	public var font(get_font, set_font):String;
	private function get_font():String { return label.font; }
	private function set_font(value:String):String {
		label.font = value;
		return value;
	}

	// mouseclick event
	private function onMouseUp(e:MouseEvent = null)
	{
		if(!this.active || !this._enabled || !Input.mouseReleased) return;
		if (isChild(scene.collidePoint(this.type, Input.mouseX + HXP.camera.x, Input.mouseY + HXP.camera.y))) {
			dispatchEvent(new ControlEvent(this, CLICKED));
		}
	}

	override public function added()
	{
		super.added();
		label.addEventListener(Label.RESIZED, updateSize);
		if (HXP.stage != null) HXP.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

	override public function removed()
	{
		super.removed();

		label.removeEventListener(Label.RESIZED, updateSize);
		if(HXP.stage != null) HXP.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

	override public function toString():String
	{
		return this._class + "=" + this.label.text;
	}

	/** @private */ private var _padding:Int;
	/** @private */ private var _align:FormatAlign;
}
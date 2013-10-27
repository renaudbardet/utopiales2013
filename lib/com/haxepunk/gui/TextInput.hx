package com.haxepunk.gui;

import com.haxepunk.Graphic;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.gui.graphic.NineSlice;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.TextFieldType;
import flash.text.TextFormatAlign;


/**
 * TextInput Control.
 * @author PigMess
 * @author Lythom
 */
class TextInput extends Label
{
	private var _background:NineSlice;
	private var _textStamp:Graphic;
	private var _hasFocus:Bool;
	private var _multiline:Bool;
	private var _padding:Int;
	private var _focusedBackground:NineSlice;
	private var _unfocusedBackground:NineSlice;
	private var _password:Bool;

	/**
	 * Create a TextInput Control.
	 * not implemented : caret display.
	 * @param	text		initial text
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 * @param	multiline	allow multiline
	 * @param	password	display **** instead of caracters
	 */
	public function new(text:String = "", x:Float = 0, y:Float = 0, width:Int = 1, height:Int = 1, multiline:Bool = false, password:Bool = false)
	{
		super(text, x, y, width, height, TextFormatAlign.LEFT);
		_padding = 4;
		_hasFocus = false;
		_multiline = multiline;
		_password = password;

		// Add a background so we can see the input area
		_unfocusedBackground = new NineSlice(this.width, this.height, new Rectangle(0, 48, 4, 4));
		_focusedBackground = new NineSlice(this.width, this.height, new Rectangle(12, 48, 4, 4));
		_background = _unfocusedBackground;
		_textStamp = graphic; // get textStamp graphic from parent
		graphic = new Graphiclist();
		cast(graphic, Graphiclist).add(_background);
		cast(graphic, Graphiclist).add(_textStamp);
		_textStamp.x = padding;
		_textStamp.y = padding;

		// use the textfield to read input without showing it. textField is not visible but printed into a buffer.
		_textField.visible = false;
		_textField.type = TextFieldType.INPUT;
		_textField.multiline = _multiline;
		_textField.wordWrap = _multiline;
		_textField.width = width - 2 * padding;
		_textField.height = height - 2 * padding;
		_textField.displayAsPassword = _password;

		toBeRedraw = true;
	}

	override public function added()
	{
		super.added();
		// use the textfield to read input without showing it. Must be placed on the stage with visible=false;
		HXP.stage.addChild(_textField);
		// change control
		_textField.addEventListener(Event.CHANGE, textChanged);
		addEventListener(Control.RESIZED, updateSize);

	}

	override public function removed():Void
	{
		// remove textfield from stage
		removeEventListener(Control.RESIZED, updateSize);
		_textField.removeEventListener(Event.CHANGE, textChanged);
		HXP.stage.removeChild(_textField);

		super.removed();
	}

	private function textChanged(e:Event):Void
	{
		if (_hasFocus) {
			// check width is respected
			while (_textField.textWidth + 2 > width - padding * 2) {
				text = text.substr(0, text.length - 1);
			}
			// check height is respected
			while (_textField.textHeight > height - padding * 2) {
				text = text.substr(0, text.length - 1);
			}
			updateBuffer();
		}
	}

	private function updateSize(e:Event):Void
	{
		_background.width = this.width;
		_background.height = this.height;
	}

	override public function updateBuffer()
	{
		super.updateBuffer();

		// overload parent behaviour of centering graphics
		graphic.x = 0;
		graphic.y = 0;
	}

	override public function update()
	{
		super.update();

		if (Input.mousePressed) {
			if (!hasFocus && scene != null && isChild(scene.collidePoint(this.type, scene.mouseX, scene.mouseY))) {

				// give focus to TextInput
				hasFocus = true;
				Input.keyString = "";
				HXP.stage.focus = _textField;
				// put caret at the end
				_textField.setSelection(_textField.length, _textField.length);
				// use focused graphics
				cast(graphic, Graphiclist).removeAll();
				cast(graphic, Graphiclist).add(_focusedBackground);
				cast(graphic, Graphiclist).add(_textStamp);

			} else if (hasFocus) {

				// remove TextInput focus
				hasFocus = false;
				// if it still have it, nullify the textField focus
				if (HXP.stage.focus == _textField) HXP.stage.focus = null;
				// use unfocused graphics
				cast(graphic, Graphiclist).removeAll();
				cast(graphic, Graphiclist).add(_unfocusedBackground);
				cast(graphic, Graphiclist).add(_textStamp);
			}
		}
	}

	override public function render()
	{
		super.render();
	}

	private function get_hasFocus():Bool
	{
		return _hasFocus;
	}

	private function set_hasFocus(value:Bool):Bool
	{
		return _hasFocus = value;
	}
	/**
	 * has focus and allow key input.
	 */
	public var hasFocus(get_hasFocus, set_hasFocus):Bool;

	private function get_padding():Int
	{
		return _padding;
	}

	private function set_padding(value:Int):Int
	{
		return _padding = value;
	}
	/**
	 * update or get the current padding between text and borders.
	 */
	public var padding(get_padding, set_padding):Int;

	private function get_password():Bool
	{
		return _password;
	}

	private function set_password(value:Bool):Bool
	{
		_textField.displayAsPassword = value;
		return _password = value;
	}
	/**
	 * Display *s instead of actual text.
	 */
	public var password(get_password, set_password):Bool;

	private function get_multiline():Bool
	{
		return _multiline;
	}

	private function set_multiline(value:Bool):Bool
	{
		_textField.multiline = value;
		_textField.wordWrap = value;
		return _multiline = value;
	}
	/**
	 * Allow multiline.
	 */
	public var multiline(get_multiline, set_multiline):Bool;
}
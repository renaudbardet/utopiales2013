package com.haxepunk.gui.graphic;

#if flash
	typedef CheckedNineSlice = com.haxepunk.gui.graphic.flash.CheckedNineSlice;
#else
	typedef CheckedNineSlice = com.haxepunk.gui.graphic.native.CheckedNineSlice;
#end

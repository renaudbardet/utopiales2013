package com.haxepunk.gui.graphic;

#if flash
	typedef NineSlice = com.haxepunk.gui.graphic.flash.NineSlice;
#else
	typedef NineSlice = com.haxepunk.gui.graphic.native.NineSlice;
#end

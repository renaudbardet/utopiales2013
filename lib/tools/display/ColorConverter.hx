package tools.display;

class ColorConverter 
{

    public static inline function toRGB(int:Int) : RGB
    {
        return new RGB( {
			a: ((int >> 24) & 255) / 255,
            r: ((int >> 16) & 255) / 255,
            g: ((int >> 8) & 255) / 255,
            b: (int & 255) / 255,
        });
    }
	
	public static inline function setRGB(int:Int, result:RGB)
    {
		result.a = ((int >> 24) & 255) / 255;
		result.r = ((int >> 16) & 255) / 255;
		result.g = ((int >> 8) & 255) / 255;
		result.b = (int & 255) / 255;
    }
	
	static private var rgb1:RGB = new RGB();
	static private var rgb2:RGB = new RGB();
	public static inline function add(color1:Int, color2:Int):Int
    {
		setRGB(color1, rgb1);
		setRGB(color2, rgb2);
		rgb1.a = Math.min(rgb1.a + rgb2.a,1);
		rgb1.r = Math.min(rgb1.r + rgb2.r,1);
		rgb1.g = Math.min(rgb1.g + rgb2.g,1);
		rgb1.b = Math.min(rgb1.b + rgb2.b,1);
		
		return ColorConverter.toInt(rgb1);
    }
    
    public static function toInt(rgb:RGB) : Int
    {
		rgb1.copyFrom(rgb);
		rgb1.normalize();
        return (Std.int(rgb1.a * 255) << 24) | (Std.int(rgb1.r * 255) << 16) | (Std.int(rgb1.g * 255) << 8) | Std.int(rgb1.b * 255);
    }
    
    public static function rgb2hsl(rgb:RGB) : HSL
    {
        var max:Float = maxRGB(rgb);
        var min:Float = minRGB(rgb);
        var add:Float = max + min;
        var sub:Float = max - min;
        
        var h:Float = 0;
		if (max == min)
        {
            h = 0;
        } else if (max == rgb.r)
        {
            h = (60 * (rgb.g - rgb.b) / sub + 360) % 360;
        } else if (max == rgb.g)
        {
            h = 60 * (rgb.b - rgb.r) / sub + 120;
        } else if (max == rgb.b)
        {
            h = 60 * (rgb.r - rgb.g) / sub + 240;
        }
        
        var l:Float = add / 2;
        
        var s:Float = 0;
		if (max == min)
        {
            s = 0;
        } else if (l <= 1 / 2)
        {
            s = sub / add;
        } else
        {
            s = sub / (2 - add);
        }
        
        return new HSL({
            h: h,
            s: s,
            l: l,
        });
        
    }
    
    public static function hsl2rgb(hsl:HSL) : RGB
    {
        var q:Float = if (hsl.l < 1 / 2)
        {
            hsl.l * (1 + hsl.s);
        } else
        {
            hsl.l + hsl.s - (hsl.l * hsl.s);
        }
        
        var p:Float = 2 * hsl.l - q;
        
        var hk:Float = (hsl.h % 360) / 360;
        
        var tr:Float = hk + 1 / 3;
        var tg:Float = hk;
        var tb:Float = hk - 1 / 3;
        
        var tc:Array<Float> = [tr,tg,tb];
        for (n in 0...tc.length)
        {
            var t:Float = tc[n];
            if (t < 0) t += 1;
            if (t > 1) t -= 1;
            tc[n] = if (t < 1 / 6)
            {
                p + ((q - p) * 6 * t);
            } else if (t < 1 / 2)
            {
                q;
            } else if (t < 2 / 3)
            {
                p + ((q - p) * 6 * (2 / 3 - t));
            } else
            {
                p;
            }
        }
        
        return new RGB({
            r: tc[0],
            g: tc[1],
            b: tc[2],
        });
    }
    
    public static function rgb2hsv(rgb:RGB) : HSV
    {
        var max:Float = maxRGB(rgb);
        var min:Float = minRGB(rgb);
        var add:Float = max + min;
        var sub:Float = max - min;
        
        var h:Float = 0;
		if (max == min)
        {
            h = 0;
        } else if (max == rgb.r)
        {
            h = (60 * (rgb.g - rgb.b) / sub + 360) % 360;
        } else if (max == rgb.g)
        {
            h = 60 * (rgb.b - rgb.r) / sub + 120;
        } else if (max == rgb.b)
        {
            h = 60 * (rgb.r - rgb.g) / sub + 240;
        }
        
        var s:Float = 0;
		if (max == 0)
        {
            s = 0;
        } else
        {
            s = 1 - min / max;
        }
        
        var v:Float = max;
        
        return new HSV({
            h: h,
            s: s,
            v: v,
        });
    }
    
    public static function hsv2rgb(hsv:HSV) : RGB
    {
        var d:Float = (hsv.h%360) / 60;
        if (d < 0) d += 6;
        var hf:Int = Std.int(d);
        var hi:Int = hf % 6;
        var f:Float = d - hf;
        
        var v:Float = hsv.v;
        var p:Float = hsv.v * (1 - hsv.s);
        var q:Float = hsv.v * (1 - f * hsv.s);
        var t:Float = hsv.v * (1 - (1 - f) * hsv.s);
        
		var col:RGB = null;
        switch(hi)
        {
            case 0: col = new RGB({ r:v, g:t, b:p });
            case 1: col = new RGB({ r:q, g:v, b:p });
            case 2: col = new RGB({ r:p, g:v, b:t });
            case 3: col = new RGB({ r:p, g:q, b:v });
            case 4: col = new RGB({ r:t, g:p, b:v });
            case 5: col = new RGB({ r:v, g:p, b:q });
        }
		return col;
    }
    
    public static function hsl2hsv(hsl:HSL) : HSV
    {
        return rgb2hsv(hsl2rgb(hsl));
    }
    
    public static function hsv2hsl(hsv:HSV) : HSL
    {
        return rgb2hsl(hsv2rgb(hsv));
    }
    
    public static inline function maxRGB(rgb:RGB) : Float
    {
        return Math.max(rgb.r, Math.max(rgb.g, rgb.b));
    }
    
    public static inline function minRGB(rgb:RGB) : Float
    {
        return Math.min(rgb.r, Math.min(rgb.g, rgb.b));
    }
}

class HSL {
	public function new(hsl:Dynamic) {
		this.h = hsl.h;
		this.s = hsl.s;
		this.l = hsl.l;
	}
    public var h:Float;
    public var s:Float;
    public var l:Float;
}

class HSV {
	public function new(hsv:Dynamic) {
		this.h = hsv.h;
		this.s = hsv.s;
		this.v = hsv.v;
	}
    public var h:Float;
    public var s:Float;
    public var v:Float;
}
package tools.display;

class RGB {
	public function new(?rgb:Dynamic) {
		if (rgb != null) {
			this.a = rgb.a;
			this.r = rgb.r;
			this.g = rgb.g;
			this.b = rgb.b;
		} else {
			this.a = 1;
			this.r = 0;
			this.g = 0;
			this.b = 0;
		}
		userData = { };
	}
	
	public function equals(other:RGB):Bool {
		return r == other.r && b == other.b && g == other.g && a == other.a;
	}
	
	public function copyFrom(other:RGB) {
		a = other.a;
		r = other.r;
		g = other.g;
		b = other.b;
		
	}
	
	public function add(other:RGB, normalize:Bool = true) 
	{
		r = r + other.r;
		g = g + other.g;
		b = b + other.b;
		if (normalize) {
			this.normalize();
		}
	}
	
	public function remove(other:RGB, normalize:Bool = true) 
	{
		r = r - other.r;
		g = g - other.g;
		b = b - other.b;
		if (normalize) {
			this.normalize();
		}
	}
	
	public function normalize() 
	{
		a = Math.min(Math.max(a, 0), 1);
		r = Math.min(Math.max(r, 0), 1);
		g = Math.min(Math.max(g, 0), 1);
		b = Math.min(Math.max(b, 0), 1);
	}
	
	public var a:Float;
    public var r:Float;
    public var g:Float;
    public var b:Float;
	public var userData:Dynamic;
}
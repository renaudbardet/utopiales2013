package world;
import com.haxepunk.HXP;
import com.haxepunk.nape.DebugGraphic;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Scene;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.BitmapDebug;

/**
 * ...
 * @author Samuel Bouchet
 */

class NapeTestWorld2 extends Scene
{
	private var space:Space;
	private var debug:BitmapDebug;
	public static var instance:Scene ;

	public function new() 
	{
		super();
		
		initNape();
		trace("init ok");
		
		instance = this;
	}
	
	private function initNape() 
	{
		// space
		var gravity:Vec2 = new Vec2(0, 10); // units are pixels/second/second
		space = new Space(gravity);
		space.worldAngularDrag = 0;
		space.worldLinearDrag = 0;
		
		// floor
		var floorBody:Body = new Body(BodyType.STATIC);
		var floorShape:Polygon = new Polygon(Polygon.rect(0, 300, 480, 1));
		floorShape.body = floorBody;
		floorBody.space = space;
		
		// boxes 
		for (i in 0...5) {
            var box = new Body(BodyType.DYNAMIC);
            box.shapes.add(new Polygon(Polygon.box(32, 32)));
            box.position.setxy(50 + 50 * i, 50);
			box.mass = i * 10 + 1;
			box.inertia = 50;
			box.space = space;
        }
		
		// debug rendering
		//debug = new ShapeDebug(Std.int(HXP.stage.width), Std.int(HXP.stage.height));
		debug = new BitmapDebug(480, 320, 0x333333, true);
		addGraphic(new DebugGraphic(debug, space));
	}

	override public function update() 
	{
		space.step(1 / 60);
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
		
		super.update();
	}
	
	override public function render()
	{
		// Clear the debug display.
		debug.clear();
		// Draw our Space.
		debug.draw(space);
		// Flush draw calls, until this is called nothing will actually be displayed.
		debug.flush();
		
		super.render();
	}
	
	override public function begin()
	{
		super.begin();
	}
	
	override public function end()
	{
		super.end();
	}
	
}
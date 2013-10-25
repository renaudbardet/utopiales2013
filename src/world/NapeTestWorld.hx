package world;
import com.haxepunk.HXP;
import com.haxepunk.nape.DebugGraphic;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Scene;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.BitmapDebug;
import nape.util.Debug;
import nape.util.ShapeDebug;

/**
 * ...
 * @author Samuel Bouchet
 */

class NapeTestWorld extends Scene
{
	private var space:Space;
	private var debug:BitmapDebug;
	private var joint:PivotJoint;
	private var sword:Body;
	private var swords:Array<Body>;
	private var holders:Array<Body>;
	private var holder:Body;
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
		var gravity:Vec2 = new Vec2(0, 100); // units are pixels/second/second
		space = new Space(gravity);
		space.worldAngularDrag = 0;
		space.worldLinearDrag = 0;
		
		// floor
		var floorBody:Body = new Body(BodyType.STATIC);
		var floorShape:Polygon = new Polygon(Polygon.rect(0, 320-20, 480, 1));
		floorShape.body = floorBody;
		
		floorShape = new Polygon(Polygon.rect(0, 0, 1, 300));
		floorShape.body = floorBody;
		
		floorShape = new Polygon(Polygon.rect(479, 0, 1, 300));
		floorShape.body = floorBody;
		
		floorBody.space = space;
		
		// circles
		swords = new Array();
		holders = new Array();
		for (i in 0...5) {
            holder = new Body(BodyType.DYNAMIC);
            holder.shapes.add(new Polygon(Polygon.box(32, 32),null, new InteractionFilter(1, 0)));
            holder.position.setxy(80 + 70 * i, (300 - 45));
			holder.align();
			holder.mass = 10;
			
			
			sword = new Body();
			var shape = new Polygon(Polygon.box(5, 5));
			shape.material = Material.steel();
			sword.shapes.add(shape);
			sword.position.setxy(80 + 70 * i + 20, (300 - 45));
			//sword.align();
			sword.mass = 10 * i + 2;
			//sword.inertia = 50;
			sword.space = space;
			
			holder.force.setxy(0, space.gravity.mul( -holder.gravMass, true).y);
			//sword.force.setxy(0, space.gravity.mul( -sword.gravMass, true).y);
            //holder.space = space;
			
			var mousePoint = Vec2.weak(mouseX, mouseY);
			var hjoint = new PivotJoint(space.world, sword, Vec2.weak(0, 0), Vec2.weak(-20, 0));
			//var hjoint = new PivotJoint(holder, sword, Vec2.weak(0, 0), Vec2.weak(-5, 0));
			hjoint.space = space;
			hjoint.stiff = true;

			//sword.applyImpulse(Vec2.weak(1, -1), Vec2.weak( -1, -1));
			//sword.applyAngularImpulse(50);
			
			var punchingBox:Body = new Body();
            punchingBox.shapes.add(new Polygon(Polygon.box(20, 20),null, new InteractionFilter(1, 1)));
            punchingBox.position.setxy(65 + 70 * i, (300 - 10));
			punchingBox.align();
			punchingBox.mass = 3;
            //punchingBox.space = space;
			
			sword.userData.holder = holder;
			sword.userData.joint = hjoint;
			
			swords.push(sword);
			holders.push(holder);
        }
		
		joint = new PivotJoint(space.world, null, Vec2.weak(0, 0), Vec2.weak(0, 0));
		joint.space = space;
		joint.active = false;
		joint.stiff = false;
		
		// debug rendering
		//debug = new ShapeDebug(Std.int(HXP.stage.width), Std.int(HXP.stage.height));
		debug = new BitmapDebug(480, 320, 0x333333, true);
		debug.drawConstraints = true;
		addGraphic(new DebugGraphic(debug, space));
	}

	var i:Int = 0;
	var vel:Float = 50;
	override public function update()
	{
		/*if (joint.active) {
			joint.anchor1.setxy(mouseX, mouseY);
		}
		
		if (joint != null && Input.mousePressed) {
			// Allocate a Vec2 from object pool.
			var mousePoint = Vec2.get(mouseX, mouseY);
			joint.body2 = sword;
			joint.anchor2.set(sword.worldPointToLocal(mousePoint, true));
			joint.active = true;
			
			mousePoint.dispose();
		}
		if (joint != null && Input.mouseReleased) {
			joint.active = false;
		}*/
		
		holder.position.setxy(Input.mouseX, Input.mouseY);
		//holder.applyImpulse(Vec2.weak((Input.mouseX - holder.position.x), (Input.mouseY-holder.position.y)));
		
		
		if (Input.mousePressed) {
			vel *= -1;
		}
		for (sword in swords) {
			var j:PivotJoint = cast(sword.userData.joint, PivotJoint);
			var h:Body = cast(sword.userData.holder, Body);
			var pos:Vec2 = h.position;
			j.anchor1.set(pos);
			if (true) {
				//sword.angularVel = vel;
				//sword.applyImpulse(Vec2.weak(0, 5));
			}
		}
		i++;
		
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
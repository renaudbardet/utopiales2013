package world;
import com.gigglingcorpse.utils.Profiler;
import com.haxepunk.animation.BitmapFrame;
import com.haxepunk.animation.Sequence;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.HXP;
import com.haxepunk.normalmap.graphic.NormalMappedAnimatedSprite;
import com.haxepunk.normalmap.graphic.NormalMappedSpritemap;
import com.haxepunk.normalmap.Light;
import com.haxepunk.normalmap.NormalMappedBitmapData;
import com.haxepunk.normalmap.graphic.NormalMappedImage;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Scene;
import flash.events.Event;
import flash.geom.Vector3D;
import tools.display.ColorConverter;
import tools.display.RGB;

/**
 * ...
 * @author Samuel Bouchet
 */

class NormalMappingTestWorld extends Scene
{
	private var coneGraph:NormalMappedImage;
	private var lights:Array<Light>;
	private var coneGraph2:NormalMappedImage;
	private var cone:Entity;
	private var plantImage:NormalMappedImage;
	private var plantAnimation:NormalMappedAnimatedSprite;
	private var plant:Entity;
	private var testImage:NormalMappedImage;
	private var test2Image:NormalMappedImage;
	private var test3Image:NormalMappedImage;
	private var testBmpData:NormalMappedBitmapData;
	
	private	var pos:Vector3D;
	private var test:Entity;
	private var test2:Entity;
	private var test3:Entity;
	private var profiler:Profiler;
	
	public static var instance:Scene ;

	public function new() 
	{
		super();
		pos = new Vector3D();
		//initHaxepunkGui();
		
		lights = new Array<Light>();
		lights.push(new Light(0, 0, 0xFFFFFF, 200, 2));
		lights.push(new Light(200, 50, 0xE10005, 800, 0.8, 20));
		lights.push(new Light(400, 50, 0x2FDC10, 800, 0.8, 20));
		lights.push(new Light(400, 0, 0xA52CED, 800, 0.8, 20));
		
		cone = new Entity();
		coneGraph = new NormalMappedImage(new NormalMappedBitmapData(HXP.getBitmap("gfx/normalMapping/cone.png"), HXP.getBitmap("gfx/normalMapping/cone_map.png")));
		coneGraph2 = new NormalMappedImage(new NormalMappedBitmapData(HXP.getBitmap("gfx/normalMapping/cone.png"), HXP.getBitmap("gfx/normalMapping/cone_map2.png")));
		
		cone.graphic = coneGraph;
		cone.x = 50;
		cone.y = 50;
		add(cone);
		
		lights[0].position.z = 30;

		plant = new Entity();
		//plantImage = new NormalMappedImage(new NormalMappedBitmapData(HXP.getBitmap("gfx/normalMapping/planteBasique.png"), HXP.getBitmap("gfx/normalMapping/planteBasique_map.png")));
		plantAnimation = new NormalMappedAnimatedSprite();
		var frames:Array<BitmapFrame> = NormalMappedAnimatedSprite.createFramesFromBitmap(new NormalMappedBitmapData("gfx/normalMapping/planteBasique.png", "gfx/normalMapping/planteBasique_map.png"), 32, 48);
		var smallSeq:Sequence = new Sequence("small", 4);
		smallSeq.addFrames(frames, [0, 1, 2, 1]);
		var bigSeq:Sequence = new Sequence("big", 4);
		bigSeq.addFrames(frames, [3, 4, 5, 4]);
		plantAnimation.add(smallSeq);
		plantAnimation.add(bigSeq);
		
		plant.graphic = plantAnimation;
		plant.x = 50;
		plant.y = 150;
		add(plant);
		plantAnimation.play("big");
		
		test = new Entity();
		testBmpData = new NormalMappedBitmapData(HXP.getBitmap("gfx/normalMapping/test.png"), HXP.getBitmap("gfx/normalMapping/test_Normal.png"));
		testImage = new NormalMappedImage(testBmpData);
		test.graphic = testImage;
		test.x = 300;
		test.y = 50;
		add(test);
		
		test2 = new Entity();
		test2Image = new NormalMappedImage(new NormalMappedBitmapData(HXP.getBitmap("gfx/normalMapping/chapeau.png"), HXP.getBitmap("gfx/normalMapping/chapeau_map.png")));
		test2.graphic = test2Image;
		test2.x = 300;
		test2.y = 150;
		add(test2);
		
		test3 = new Entity();
		test3Image = new NormalMappedImage(new NormalMappedBitmapData(HXP.getBitmap("gfx/normalMapping/chapeau.png"), HXP.getBitmap("gfx/normalMapping/chapeau_Normal2.png")));
		test3.graphic = test3Image;
		test3.x = 300;
		test3.y = 200;
		add(test3);

		instance = this;
	}
	
	private function swfLoaded(e:Event):Void 
	{
	}
	
	override public function render()
	{
		if (i % 2 == 0) {
			
			/*pos.x = plant.x + plantImage.x;
			pos.y = plant.y + plantImage.y;
			pos.z = 10;
			plantImage.updateLightning(pos, lights);*/
			
			pos.x = plant.x + plantAnimation.x;
			pos.y = plant.y + plantAnimation.y;
			pos.z = 10;
			plantAnimation.updateLightning(pos, lights);
			
			pos.x = test2.x + test2Image.x;
			pos.y = test2.y + test2Image.y;
			pos.z = 10;
			test2Image.updateLightning(pos, lights);
			
			pos.x = test3.x + test3Image.x;
			pos.y = test3.y + test3Image.y;
			pos.z = 10;
			test3Image.updateLightning(pos, lights);
			
			pos.x = test.x;
			pos.y = test.y;
			pos.z = 10;
			testImage.updateLightning(pos, lights);
		
			pos.x = cone.x;
			pos.y = cone.y;
			pos.z = 10;
			if (cone.graphic == coneGraph) {
				coneGraph.updateLightning(pos, lights);
			} else if (cone.graphic == coneGraph2) {
				coneGraph2.updateLightning(pos, lights);
			}
		}
		i++;
		super.render();
	}

	var i = 0;
	override public function update() 
	{
		lights[0].position.x = Input.mouseX;
		lights[0].position.y = Input.mouseY;
			
		if (Input.pressed(Key.NUMPAD_1)) {
			cone.graphic = coneGraph;
		} else if (Input.pressed(Key.NUMPAD_2)) {
			cone.graphic = coneGraph2;
		}
		if (Input.pressed(Key.NUMPAD_4)) {
			plantAnimation.play("small");
		} else if (Input.pressed(Key.NUMPAD_5)) {
			plantAnimation.play("big");
		}
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
		
		if (Input.pressed(Key.NUMPAD_ADD)) {
			lights.push(new Light(Math.floor(Math.random()*480), Math.floor(Math.random()*320), Math.floor(Math.random()*0xFFFFFF), 300, 1, 20));
		} else if (Input.pressed(Key.NUMPAD_SUBTRACT)) {
			if (lights.length > 1) {
				lights.splice(lights.length-1, 1);
			}
		}
		
		super.update();
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
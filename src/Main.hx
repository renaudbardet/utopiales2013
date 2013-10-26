
import com.haxepunk.Engine;

import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

import world.WelcomeWorld;

class Main extends Engine
{

	public static inline var kScreenWidth:Int = 960;
	public static inline var kScreenHeight:Int = 640;
	public static inline var kFrameRate:Int = 60;
	public static inline var kClearColor:Int = 0x333333;
	public static inline var kProjectName:String = "UtopialesGameJam2013";

	public function new()
	{
		super(kScreenWidth, kScreenHeight, kFrameRate, true);
		HXP.frameRate = kFrameRate;
	}

	override public function init()
	{
#if debug
	#if flash
		if (flash.system.Capabilities.isDebugger)
	#end
		{
			HXP.console.enable();
			HXP.console.toggleKey = Key.P;
		}
#end
		
		HXP.screen.color = kClearColor;
		HXP.screen.scale = 2;
		HXP.resize(HXP.stage.stageWidth, HXP.stage.stageHeight);
		HXP.scene = new WelcomeWorld();
		
		Input.define("up", [Key.Z, Key.W, Key.UP]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("down", [Key.S, Key.DOWN]);
		Input.define("left", [Key.Q, Key.A, Key.LEFT]);
		Input.define("action1", [Key.E, Key.ENTER]);
	}

	public static function main()
	{
		new Main();
	}
	
	override public function update()
	{
		super.update();
	}

}
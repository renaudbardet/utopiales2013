package world;
import com.haxepunk.gui.Label;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Scene;
import flash.events.Event;
import openfl.Assets;
import flash.events.ProgressEvent;
import flash.Lib;
import plateformer.RpgHero;
import flash.net.Socket;

/**
 * ...
 * @author Samuel Bouchet
 */

class RpgWorld extends Scene
{
	private var hero:RpgHero;
	private var connectedLbl:Label;
	private var socket:flash.net.Socket;
	public var compteur:Int;
	public static var instance:Scene ;
	static public inline var MSG_END:Int = 46;

	public function new()
	{
		super();
		connectedLbl = new Label("Connected", 100, 0);
		connectedLbl.color = 0x37E363;
		compteur = 0;
		
		instance = this;
	}

	override public function update()
	{
		super.update();
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
		if (Input.pressed(Key.A)) {
			HXP.scene = WelcomeWorld.instance;
		}
		
		if (socket.connected) {
			socket.writeShort( compteur++ ); 
			socket.writeByte( MSG_END ); 
			socket.flush(); 
			if (compteur >= 50) {
				compteur = 0;
				socket.close();
				closeHandler();
			}
		}
		
	}
	
	override public function begin()
	{
		initNetwork();
		hero = new RpgHero();
		add(hero);
		
		super.begin();
	}
	
	private function initNetwork()
	{
		/*var URL = "http://localhost:2000/remoting.n";
		var cnx = haxe.remoting.HttpAsyncConnection.urlConnect(URL);
		cnx.setErrorHandler( function(err) { trace("Error : "+Std.string(err)); } );
		cnx.Server.foo.call([1,2],display);
		*/
		/*var s = new neko.net.Socket();
        s.connect(new neko.net.Host("localhost"),2000);
        while( true ) {
            var l = s.input.readLine();
            trace(l);
            if( l == "exit" ) {
                s.close();
                break;
            }
        }*/
		socket = new flash.net.Socket();
		socket.addEventListener(Event.CONNECT, connectHandler); 
		socket.addEventListener(Event.CLOSE, closeHandler); 
		socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler); 
		socket.connect("localhost", 2000);
	}
	
	private function socketDataHandler(e:ProgressEvent):Void 
	{
		//Read the message from the socket 
		var message:String = socket.readUTFBytes( socket.bytesAvailable ); 
		trace( "Received: " + message); 
		if (message == "Roger") {
			connectedLbl.text += " (confirmé)";
		}
	}
	
	private function closeHandler(e:Event=null):Void 
	{
		connectedLbl.text = "Connected";
		remove(connectedLbl);
	}
	
	private function connectHandler(e:Event=null):Void 
	{
		add(connectedLbl);
	}

	override public function end()
	{
		super.end();
	}
	
}
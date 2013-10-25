package ;
import neko.Lib;
import neko.net.Socket;
import neko.net.ThreadServer;
import haxe.io.Bytes;

/**
 * ...
 * @author Samuel Bouchet
 */
typedef Client = {
  var id : Int;
}

typedef Message = {
  var str : String;
}

class GameServer extends ThreadServer<Client, Message>
{
	function new() { super(); }
	
	static var clientNumber:Int = 0;
	
	// create a Client
	override function clientConnected( s : Socket ) : Client
	{
		var num = clientNumber++;
		Lib.println("client " + num + " is " + s.peer());
		s.output.writeString("Roger");
		s.output.flush();
		return { id: num };
	}

	override function clientDisconnected( c : Client )
	{
		Lib.println("client " + Std.string(c.id) + " disconnected");
	}

	override function readClientMessage(c:Client, buf:Bytes, pos:Int, len:Int)
	{
		// find out if there's a full message, and if so, how long it is.
		var complete = false;
		var cpos = pos;
		while (cpos < (pos+len) && !complete)
		{
		  complete = (buf.get(cpos) == 46);
		  cpos++;
		}

		// no full message
		if( !complete ) return null;

		// got a full message, return it
		var msg:String = buf.readString(pos, cpos-pos);
		return {msg: {str: msg}, bytes: cpos-pos};
	}

	override function clientMessage( c : Client, msg : Message )
	{
		Lib.println(c.id + " sent "+msg.str.length+" bytes  (" + msg.str+")");
	}

	static function main() {
		
		var server = new GameServer();
		trace("Starting server...");
		server.run("localhost", 2000);
		
	}
	
}
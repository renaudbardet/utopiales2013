package com.haxepunk.plateformer;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import flash.geom.Point;

/**
 * Entity moving using forces and manual acceleration.
 */
class BasicPhysicsEntity extends Entity 
{
	private var _velocity:Point;
	private var _acceleration:Point;
	private var _friction:Point;
	private var _maxVelocity:Point;
	private var _orientation:Point;
	private var _forces:Array<Point>;
	private var _precision:Int;
	
	private var _onGround:Bool;
	private var _onWall:Bool;
	
	// function preallocated resources
	var normalizedVelocity:Point;
	
	/**
	 * Collision type to evaluate.
	 */
	public var solid:String = "solid";

	public function new(x:Int, y:Int)
	{
		super(x, y);

		_velocity = new Point(0, 0);
		_acceleration = new Point(0, 0);
		_friction = new Point(0.2, 0);
		_maxVelocity = new Point(200, 1000);
		_orientation = new Point(1, 0);
		_forces = new Array<Point>();

		normalizedVelocity = new Point(0, 0);
	}

	public override function update():Void
	{
		// apply acceleration if maxVelocity is not reach
		applyAcceleration();
		applyForces();
		applyVelocityAndDetectCollisions();
		velocity.x = applyFriction(
		  _onGround,
		  velocity.x,
		  friction.x
		);
		
		velocity.y = applyFriction(
		  _onWall,
		  velocity.y,
		  friction.y
		);
		super.update();
	}
	
	
	/**
	 * Change velocity according to acceleration if maxVelocity is not reached.
	 */
	private function applyAcceleration():Void 
	{
		// accelerate while velocity < maxVelocity
		if (Math.abs(velocity.x + acceleration.x * HXP.elapsed) <= _maxVelocity.x || _maxVelocity.x <= 0) {
			velocity.x += acceleration.x * HXP.elapsed;
		// cap to maxVelocity
		} else if(Math.abs(velocity.x) > _maxVelocity.x){
			velocity.x = _maxVelocity.x * HXP.sign(velocity.x);
		}
		
		// accelarate while velocity < maxVelocity
		if (Math.abs(velocity.y + acceleration.y * HXP.elapsed) <= _maxVelocity.y || maxVelocity.y <= 0) {
			velocity.y += acceleration.y * HXP.elapsed;
		// cap to maxVelocity
		} else if(Math.abs(velocity.y) > _maxVelocity.y){
			velocity.y = _maxVelocity.y * HXP.sign(velocity.y);
		}
	}

	/**
	 * Change velocity according to forces applied on the entity.
	 */
	public function applyForces():Void
	{
		for (f in _forces) {
			velocity.x += f.x * HXP.elapsed;
			velocity.y += f.y * HXP.elapsed;
		}
	}

	/**
	* Change velocity according to friction
	*/
	public function applyFriction(attached:Bool, vel:Float, fric:Float):Float
	{
		if (attached && fric != 0.0) {
			var amount = (vel * fric);
			trace(amount);
			vel = vel - amount;
			if (Math.abs(vel) < 0.9) {
				vel = 0;
			}
		}
		return vel;
	}

	/**
	 * apply velocity to coordinates when possible, stop with collisions. 
	 */
	public function applyVelocityAndDetectCollisions():Void
	{
		_onGround = false;
		_onWall = false;
		var collided:Entity = null;

		// check X collisions
		collided =  collide(solid, x + velocity.x * HXP.elapsed , y);
		if (collided != null) {
			
			// place at nearest position before collision
			var moveX:Float = velocity.x * HXP.elapsed;
			while (collide(solid, x + moveX , y) != null) {
				moveX -= HXP.sign(velocity.x);
			}
			x += moveX;
			
			_onWall = true;
			velocity.x = 0;
		}

		// check Y collisions
		collided =  collide(solid, x , y + velocity.y * HXP.elapsed);
		if (collided != null) {
			
			// place at nearest position before collision
			var moveY:Float = velocity.y * HXP.elapsed;
			while (collide(solid, x , y + moveY) != null) {
				moveY -= HXP.sign(velocity.y);
			}
			y += moveY;
			
			_onGround = true;
			velocity.y = 0;
		}
		
		x += velocity.x * HXP.elapsed;
		y += velocity.y * HXP.elapsed;
	}
	
	private function get_velocity():Point 
	{
			return _velocity;
	}
	
	private function set_velocity(value:Point):Point 
	{
			return _velocity = value;
	}
	/**
	 * Current per update moving speed of the Entity.
	 */
	public var velocity(get_velocity, set_velocity):Point;
	
	private function get_acceleration():Point 
	{
			return _acceleration;
	}
	
	private function set_acceleration(value:Point):Point 
	{
			return _acceleration = value;
	}
	/**
	 * Current per update speed acceleration of the Entity.
	 */
	public var acceleration(get_acceleration, set_acceleration):Point;

	private function get_maxVelocity():Point 
	{
			return _maxVelocity;
	}
	
	private function set_maxVelocity(value:Point):Point 
	{
			return _maxVelocity = value;
	}
	/**
	 * max speed of the Entity.
	 */
	public var maxVelocity(get_maxVelocity, set_maxVelocity):Point;
	
	private function get_orientation():Point 
	{
			return _orientation;
	}
	private function set_orientation(value:Point):Point 
	{
			return _orientation = value;
	}
	/**
	 * Direction the Entity is facing as a 2D vector (Point)
	 */
	public var orientation(get_orientation, set_orientation):Point;
	
	private function get_orientationInRadian():Float 
	{
			return Math.atan2(_orientation.y, _orientation.x);
	}
	/**
	 * Direction the Entity is facing in Radian
	 */
	public var orientationInRadian(get_orientationInRadian, null):Float;
	
	private function get_forces():Array<Point> 
	{
			return _forces;
	}
	
	private function set_forces(value:Array<Point>):Array<Point> 
	{
			return _forces = value;
	}
	/**
	 * List of forces applied to Entity. Gravity should be added here.
	 */
	public var forces(get_forces, set_forces):Array<Point>;

	private function get_onGround():Bool 
	{
			return _onGround;
	}
	
	private function set_onGround(value:Bool):Bool 
	{
			return _onGround = value;
	}
	
	public var onGround(get_onGround, set_onGround):Bool;
	
	private function get_onWall():Bool 
	{
			return _onWall;
	}
	
	private function set_onWall(value:Bool):Bool 
	{
			return _onWall = value;
	}
	
	public var onWall(get_onWall, set_onWall):Bool;
	
	private function get_friction():Point 
	{
			return _friction;
	}
	
	private function set_friction(value:Point):Point 
	{
			return _friction = value;
	}
	
	public var friction(get_friction, set_friction):Point;
}
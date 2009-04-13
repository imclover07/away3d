package away3d.core.base;

import away3d.core.utils.ValueObject;
import flash.events.EventDispatcher;
import away3d.core.draw.ScreenVertex;
import away3d.core.math.Number3D;
import away3d.core.math.Matrix3D;



// use namespace arcane;

/**
 * A vertex coordinate value object.
 * Properties x, y and z represent a 3d point in space.
 */
class Vertex extends ValueObject {
	public var x(getX, setX) : Float;
	public var y(getY, setY) : Float;
	public var z(getZ, setZ) : Float;
	public var position(getPosition, null) : Number3D;
	
	/** @private */
	public var _x:Float;
	/** @private */
	public var _y:Float;
	/** @private */
	public var _z:Float;
	private var _position:Number3D;
	private var _persp:Float;
	private var _element:Element;
	public var positionDirty:Bool;
	public var parents:Array<Dynamic>;
	public var geometry:Geometry;
	/**
	 * An object that contains user defined properties. Defaults to  null.
	 */
	public var extra:Dynamic;
	
	private function updatePosition():Void {
		
		positionDirty = false;
		for (__i in 0...parents.length) {
			_element = parents[__i];

			if (_element != null) {
				_element.vertexDirty = true;
			}
		}

		_position.x = _x;
		_position.y = _y;
		_position.z = _z;
	}

	/**
	 * Defines the x coordinate of the vertex relative to the local coordinates of the parent mesh object.
	 */
	public function getX():Float {
		
		if (positionDirty) {
			updatePosition();
		}
		return _x;
	}

	public function setX(val:Float):Float {
		if (_x == val) {
			return val;
		}
		_x = val;
		positionDirty = true;
		return val;
	}

	/**
	 * Represents the y coordinate of the vertex relative to the local coordinates of the parent mesh object.
	 */
	public function getY():Float {
		
		if (positionDirty) {
			updatePosition();
		}
		return _y;
	}

	public function setY(val:Float):Float {
		
		if (_y == val) {
			return val;
		}
		_y = val;
		positionDirty = true;
		return val;
	}

	/**
	 * Represents the z coordinate of the vertex relative to the local coordinates of the parent mesh object.
	 */
	public function getZ():Float {
		
		if (positionDirty) {
			updatePosition();
		}
		return _z;
	}

	public function setZ(val:Float):Float {
		
		if (_z == val) {
			return val;
		}
		_z = val;
		positionDirty = true;
		return val;
	}

	/**
	 * Represents the vertex position vector
	 */
	public function getPosition():Number3D {
		
		if (positionDirty) {
			updatePosition();
		}
		return _position;
	}

	/**
	 * Creates a new <code>Vertex</code> object.
	 *
	 * @param	x	[optional]	The local x position of the vertex. Defaults to 0.
	 * @param	y	[optional]	The local y position of the vertex. Defaults to 0.
	 * @param	z	[optional]	The local z position of the vertex. Defaults to 0.
	 */
	public function new(?x:Float=0, ?y:Float=0, ?z:Float=0) {
		// autogenerated
		super();
		this._position = new Number3D();
		this.parents = new Array();

		_x = x;
		_y = y;
		_z = z;
		positionDirty = true;
	}

	/**
	 * Duplicates the vertex properties to another <code>Vertex</code> object
	 * 
	 * @return	The new vertex instance with duplicated properties applied
	 */
	public function clone():Vertex {
		
		return new Vertex(_x, _y, _z);
	}

	/**
	 * Reset the position of the vertex object by Number3D.
	 */
	public function reset():Void {
		
		_x = 0;
		_y = 0;
		_z = 0;
		positionDirty = true;
	}

	public function transform(m:Matrix3D):Void {
		
		setValue(_x * m.sxx + _y * m.sxy + _z * m.sxz + m.tx, _x * m.syx + _y * m.syy + _z * m.syz + m.ty, _x * m.szx + _y * m.szy + _z * m.szz + m.tz);
	}

	/**
	 * Adjusts the position of the vertex object by Number3D.
	 *
	 * @param	value	Amount to add in Number3D format.
	 */
	public function add(value:Number3D):Void {
		
		_x += value.x;
		_y += value.y;
		_z += value.z;
		positionDirty = true;
	}

	/**
	 * Adjusts the position of the vertex object incrementally.
	 *
	 * @param	x	The x position used for adjustment.
	 * @param	y	The x position used for adjustment.
	 * @param	z	The x position used for adjustment.
	 * @param	k	The fraction by which to adjust the vertex values.
	 */
	public function adjust(x:Float, y:Float, z:Float, ?k:Float=1):Void {
		setValue(_x * (1 - k) + x * k, _y * (1 - k) + y * k, _z * (1 - k) + z * k);
	}

	/**
	 * Applies perspective distortion
	 */
	public function perspective(focus:Float):ScreenVertex {
		
		_persp = 1 / (1 + _z / focus);
		return new ScreenVertex(_x * _persp, _y * _persp, _z);
	}

	/**
	 * Sets the vertex coordinates
	 */
	public function setValue(x:Float, y:Float, z:Float):Void {
		
		_x = x;
		_y = y;
		_z = z;
		positionDirty = true;
	}

	/**
	 * private Returns the middle-point of two vertices
	 */
	public static function median(a:Vertex, b:Vertex):Vertex {
		
		return new Vertex((a._x + b._x) / 2, (a._y + b._y) / 2, (a._z + b._z) / 2);
	}

	/**
	 * Get the middle-point of two vertices
	 */
	public static function distanceSqr(a:Vertex, b:Vertex):Float {
		
		return (a._x + b._x) * (a._x + b._x) + (a._y + b._y) * (a._y + b._y) + (a._z + b._z) * (a._z + b._z);
	}

	/**
	 * Get the weighted average of two vertices
	 */
	public static function weighted(a:Vertex, b:Vertex, aw:Float, bw:Float):Vertex {
		
		var d:Float = aw + bw;
		var ak:Float = aw / d;
		var bk:Float = bw / d;
		return new Vertex(a._x * ak + b._x * bk, a._y * ak + b._y * bk, a._z * ak + b._z * bk);
	}

	/**
	 * Used to trace the values of a vertex object.
	 * 
	 * @return A string representation of the vertex object.
	 */
	public override function toString():String {
		
		return "new Vertex(" + _x + ", " + _y + ", " + z + ")";
	}

}


package away3d.materials.shaders;

import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import away3d.core.base.Face;
import flash.geom.Point;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import away3d.core.utils.Init;
import away3d.core.utils.FaceVO;
import away3d.core.utils.FaceMaterialVO;
import flash.display.Sprite;
import away3d.materials.IUVMaterial;
import away3d.core.math.Number3D;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import away3d.core.math.Matrix3D;
import flash.display.Shape;
import flash.display.Graphics;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Diffuse Dot3 shader class for directional lighting.
 * 
 * @see away3d.lights.DirectionalLight3D
 */
class DiffuseDot3Shader extends AbstractShader, implements IUVMaterial {
	public var bitmap(getBitmap, setBitmap) : BitmapData;
	public var width(getWidth, null) : Float;
	public var height(getHeight, null) : Float;
	
	private var _zeroPoint:Point;
	private var _bitmap:BitmapData;
	private var _sourceDictionary:Dictionary;
	private var _sourceBitmap:BitmapData;
	private var _normalDictionary:Dictionary;
	private var _normalBitmap:BitmapData;
	private var _diffuseTransform:Matrix3D;
	private var _szx:Float;
	private var _szy:Float;
	private var _szz:Float;
	private var _normal0z:Float;
	private var _normal1z:Float;
	private var _normal2z:Float;
	private var _normalFx:Float;
	private var _normalFy:Float;
	private var _normalFz:Float;
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	private var _texturemapping:Matrix;
	//TODO: implement tangent space option
	/**
	 * Determines if the DOT3 mapping is rendered in tangent space (true) or object space (false).
	 */
	public var tangentSpace:Bool;
	

	/**
	 * Calculates the mapping matrix required to draw the triangle texture to screen.
	 * 
	 * @param	tri		The data object holding all information about the triangle to be drawn.
	 * @return			The required matrix object.
	 */
	private function getMapping(tri:DrawTriangle):Matrix {
		
		if (tri.generated) {
			_texturemapping = tri.transformUV(this).clone();
			_texturemapping.invert();
			return _texturemapping;
		}
		_faceMaterialVO = getFaceMaterialVO(tri.faceVO, tri.source, tri.view);
		if (!_faceMaterialVO.invalidated) {
			return _faceMaterialVO.texturemapping;
		}
		_texturemapping = tri.transformUV(this).clone();
		_texturemapping.invert();
		return _faceMaterialVO.texturemapping = _texturemapping;
	}

	/**
	 * @inheritDoc
	 */
	public function clearFaces(?source:Object3D=null, ?view:View3D=null):Void {
		
		notifyMaterialUpdate();
		var __keys:Iterator<Dynamic> = untyped (__keys__(_faceDictionary)).iterator();
		for (__key in __keys) {
			_faceMaterialVO = _faceDictionary[untyped __key];

			if (_faceMaterialVO != null) {
				if (source == _faceMaterialVO.source) {
					if (!_faceMaterialVO.cleared) {
						_faceMaterialVO.clear();
					}
				}
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public function invalidateFaces(?source:Object3D=null, ?view:View3D=null):Void {
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(_faceDictionary)).iterator();
		for (__key in __keys) {
			_faceMaterialVO = _faceDictionary[untyped __key];

			if (_faceMaterialVO != null) {
				_faceMaterialVO.invalidated = true;
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	private override function renderShader(tri:DrawTriangle):Void {
		//check to see if sourceDictionary exists
		
		_sourceBitmap = _sourceDictionary[untyped tri];
		if (_sourceBitmap == null || _faceMaterialVO.resized) {
			_sourceBitmap = _sourceDictionary[untyped tri] = _parentFaceMaterialVO.bitmap.clone();
			_sourceBitmap.lock();
		}
		//check to see if normalDictionary exists
		_normalBitmap = _normalDictionary[untyped tri];
		if (_normalBitmap == null || _faceMaterialVO.resized) {
			_normalBitmap = _normalDictionary[untyped tri] = _parentFaceMaterialVO.bitmap.clone();
			_normalBitmap.lock();
		}
		_n0 = _source.geometry.getVertexNormal(_face.v0);
		_n1 = _source.geometry.getVertexNormal(_face.v1);
		_n2 = _source.geometry.getVertexNormal(_face.v2);
		for (__i in 0..._source.lightarray.directionals.length) {
			directional = _source.lightarray.directionals[__i];

			if (directional != null) {
				_diffuseTransform = directional.diffuseTransform[untyped _source];
				_szx = _diffuseTransform.szx;
				_szy = _diffuseTransform.szy;
				_szz = _diffuseTransform.szz;
				_normal0z = _n0.x * _szx + _n0.y * _szy + _n0.z * _szz;
				_normal1z = _n1.x * _szx + _n1.y * _szy + _n1.z * _szz;
				_normal2z = _n2.x * _szx + _n2.y * _szy + _n2.z * _szz;
				//check to see if the uv triangle lies inside the bitmap area
				if (_normal0z > -0.2 || _normal1z > -0.2 || _normal2z > -0.2) {
					if (_faceMaterialVO.cleared && !_parentFaceMaterialVO.updated) {
						_faceMaterialVO.bitmap = _parentFaceMaterialVO.bitmap.clone();
						_faceMaterialVO.bitmap.lock();
					}
					//update booleans
					_faceMaterialVO.cleared = false;
					_faceMaterialVO.updated = true;
					//resolve normal map
					_sourceBitmap.applyFilter(_bitmap, _faceVO.bitmapRect, _zeroPoint, directional.normalMatrixTransform[untyped _source]);
					//normalise bitmap
					_normalBitmap.applyFilter(_sourceBitmap, _sourceBitmap.rect, _zeroPoint, directional.colorMatrixTransform[untyped _source]);
					//draw into faceBitmap
					_faceMaterialVO.bitmap.draw(_normalBitmap, null, directional.diffuseColorTransform, blendMode);
				}
			}
		}

	}

	/**
	 * Returns the width of the bitmapData being used as the shader DOT3 map.
	 */
	public function getWidth():Float {
		
		return _bitmap.width;
	}

	/**
	 * Returns the height of the bitmapData being used as the shader DOT3 map.
	 */
	public function getHeight():Float {
		
		return _bitmap.height;
	}

	/**
	 * Returns the bitmapData object being used as the shader DOT3 map.
	 */
	public function getBitmap():BitmapData {
		
		return _bitmap;
	}

	public function setBitmap(value:BitmapData):BitmapData {
		_bitmap = value;
		return value;
	}
	 

	/**
	 * Returns the argb value of the bitmapData pixel at the given u v coordinate.
	 * 
	 * @param	u	The u (horizontal) texture coordinate.
	 * @param	v	The v (verical) texture coordinate.
	 * @return		The argb pixel value.
	 */
	public function getPixel32(u:Float, v:Float):Int {
		
		return _bitmap.getPixel32(Std.int(u * _bitmap.width), Std.int((1 - v) * _bitmap.height));
	}

	/**
	 * Creates a new <code>DiffuseDot3Shader</code> object.
	 * 
	 * @param	bitmap			The bitmapData object to be used as the material's DOT3 map.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(bitmap:BitmapData, ?init:Dynamic=null) {
		this._zeroPoint = new Point(0, 0);
		this._sourceDictionary = new Dictionary(true);
		this._normalDictionary = new Dictionary(true);
		
		
		super(init);
		_bitmap = bitmap;
		tangentSpace = ini.getBoolean("tangentSpace", false);
	}

	/**
	 * @inheritDoc
	 */
	public override function updateMaterial(source:Object3D, view:View3D):Void {
		
		clearLightingShapeDictionary();
		for (__i in 0...source.lightarray.directionals.length) {
			directional = source.lightarray.directionals[__i];

			if (directional != null) {
				if (!directional.diffuseTransform[untyped source] || view.scene.updatedObjects[untyped source]) {
					directional.setDiffuseTransform(source);
					directional.setNormalMatrixTransform(source);
					directional.setColorMatrixTransform(source);
					clearFaces(source, view);
				}
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void {
		
		super.renderLayer(tri, layer, level);
		for (__i in 0..._lights.directionals.length) {
			directional = _lights.directionals[__i];

			if (directional != null) {
				if (_lights.numLights > 1) {
					_shape = getLightingShape(layer, directional);
					_shape.filters = [directional.normalMatrixTransform[untyped _source], directional.colorMatrixTransform[untyped _source]];
					_shape.blendMode = blendMode;
					_shape.transform.colorTransform = directional.ambientDiffuseColorTransform;
					_graphics = _shape.graphics;
				} else {
					layer.filters = [directional.normalMatrixTransform[untyped _source], directional.colorMatrixTransform[untyped _source]];
					layer.transform.colorTransform = directional.ambientDiffuseColorTransform;
					_graphics = layer.graphics;
				}
				_mapping = getMapping(tri);
				_source.session.renderTriangleBitmap(_bitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, false, _graphics);
			}
		}

		if (debug) {
			_source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
		}
	}

}


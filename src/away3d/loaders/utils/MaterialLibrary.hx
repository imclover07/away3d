package away3d.loaders.utils;

import away3d.core.utils.Debug;
import flash.display.BitmapData;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import away3d.loaders.data.MaterialData;
import away3d.core.base.Face;
import flash.display.Loader;
import away3d.materials.BitmapMaterial;


/**
 * Store for all materials associated with an externally loaded file.
 */
class MaterialLibrary extends Hash<MaterialData>  {
	
	private var _materialData:MaterialData;
	private var _image:TextureLoader;
	private var _face:Face;
	private var length:Int;
	/**
	 * The root directory path to the texture files.
	 */
	public var texturePath:String;
	/**
	 * Determines whether textures should be loaded automatically.
	 */
	public var autoLoadTextures:Bool;
	/**
	 * Flag to determine if any of the contained textures require a file load.
	 */
	public var loadRequired:Bool;
	

	/**
	 * Adds a material name reference to the library.
	 */
	public function addMaterial(name:String):MaterialData {
		//return if material already exists
		
		if ((this.get(name) != null)) {
			return this.get(name);
		}
		length++;
		var materialData:MaterialData = new MaterialData();
		materialData.name = name;
		this.set(name, materialData);
		return materialData;
	}

	/**
	 * Returns a material data object for the given name reference in the library.
	 */
	public function getMaterial(name:String):MaterialData {
		//return if material exists
		
		if ((this.get(name) != null)) {
			return this.get(name);
		}
		Debug.warning("Material '" + name + "' does not exist");
		return null;
	}

	/**
	 * Called after all textures have been loaded from the <code>TextureLoader</code> class.
	 * 
	 * @see away3d.loaders.utils.TextureLoader
	 */
	public function texturesLoaded(loadQueue:TextureLoadQueue):Void {
		
		loadRequired = false;
		var images:Array<TextureLoader> = loadQueue.images;
		for (_materialData in this.iterator()) {
			if (_materialData != null) {
				for (__i in 0...images.length) {
					_image = images[__i];

					if (_image != null) {
						if (texturePath + _materialData.textureFileName == _image.filename) {
							_materialData.textureBitmap = new BitmapData(Std.int(_image.width), Std.int(_image.height), true, 0x00FFFFFF);
							_materialData.textureBitmap.draw(_image);
							_materialData.material = new BitmapMaterial(_materialData.textureBitmap);
						}
					}
				}

			}
		}

	}

	// autogenerated
	public function new () {
		super();
		this.length = 0;
		
	}

	

}


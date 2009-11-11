﻿package away3d.loaders{    import away3d.arcane;    import away3d.containers.*;    import away3d.core.base.*;    import away3d.core.utils.*;    import away3d.loaders.data.*;        import flash.events.*;    import flash.net.*;		use namespace arcane;	    /**    * File loader for the OBJ file format.<br/>    * <br/>	* note: Multiple objects support and autoload mtls are supported since Away v 2.1.<br/>	* Class tested with the following 3D apps:<br/>	* - Strata CX mac 5.5<br/>	* - Biturn ver 0.87b4 PC<br/>	* - LightWave 3D OBJ Export v2.1 PC<br/>	* - Max2Obj Version 4.0 PC<br/>	* - AC3D 6.2.025 mac<br/>	* - Carrara (file provided)<br/>	* - Hexagon (file provided)<br/>	* - LD3T (file provided)<br/>	* - geometry supported tags: f,v,vt, g<br/>	* - geometry unsupported tags:vn,ka, kd r g b, kd, ks r g b,ks,ke r g b,ke,d alpha,d,tr alpha,tr,ns s,ns,illum n,illum,map_Ka,map_Bump<br/>	* - mtl unsupported tags: kd,ka,ks,ns,tr<br/> 	* <br/>	* export from apps as polygon group or mesh as .obj file.<br/>	* added support for 3dmax negative vertexes references    */    public class Obj extends AbstractParser    {    	/** @private */        arcane override function prepareData(data:*):void        {        	obj = Cast.string(data);        				var lines:Array = obj.split('\n');			if(lines.length == 1) lines = obj.split(String.fromCharCode(13));			var trunk:Array;			var isNew:Boolean = true;						var isNeg:Boolean;			var myPattern:RegExp = new RegExp("-","g");			var face0:Array;			var face1:Array;			var face2:Array;			var face3:Array;			             for each (var line:String in lines)            {                trunk = line.replace("  "," ").replace("  "," ").replace("  "," ").split(" ");				                 switch (trunk[0])                {					case "g":						createMesh(trunk[1]);						                        break;											case "usemtl":						if (!_meshData)							createMesh();												_materialData = _materialLibrary.addMaterial(trunk[1]);												_geometryData.materials.push(_meshMaterialData = new MeshMaterialData());						_meshMaterialData.symbol = trunk[1];						_symbolLibrary[_materialData.name] = _materialData;						break;						                    case "v":                    	if (!_meshData)							createMesh();						                         _geometryData.vertices.push(new Vertex(-parseFloat(trunk[1]) * scaling, parseFloat(trunk[2]) * scaling, -parseFloat(trunk[3]) * scaling));						                        break;						                    case "vt":                    	if (!_meshData)							createMesh();						                        _geometryData.uvs.push(new UV(parseFloat(trunk[1]), parseFloat(trunk[2])));                                                break;						                    case "f":												if(trunk[1].indexOf("-") == -1) {														face0 = trysplit(trunk[1], "/");							face1 = trysplit(trunk[2], "/");							face2 = trysplit(trunk[3], "/");														if (trunk[4] != null){								face3 = trysplit(trunk[4], "/");							}else{								face3 = null;							}														isNeg = false;													} else {														face0 = trysplit(trunk[1].replace(myPattern, "") , "/");							face1 = trysplit(trunk[2].replace(myPattern, "") , "/");							face2 = trysplit(trunk[3].replace(myPattern, "") , "/");														if (trunk[4] != null){								face3 = trysplit(trunk[4].replace(myPattern, "") , "/");							} else{								face3 = null;							}														isNeg = true;						}																		//try{														if (face3 != null && face3.length > 0 && !isNaN(parseInt(face3[0])) ){																if(isNeg){									_faceData = new FaceData();									_faceData.v0 = _geometryData.vertices.length - parseInt(face1[0]) - 1;									_faceData.v1 = _geometryData.vertices.length - parseInt(face0[0]) - 1;									_faceData.v2 = _geometryData.vertices.length - parseInt(face3[0]) - 1;									_faceData.uv0 = _geometryData.uvs.length - parseInt(face1[1]) - 1;									_faceData.uv1 = _geometryData.uvs.length - parseInt(face0[1]) - 1;									_faceData.uv2 = _geometryData.uvs.length - parseInt(face3[1]) - 1;																		if (_meshMaterialData)										_meshMaterialData.faceList.push(_geometryData.faces.length);																		_geometryData.faces.push(_faceData);																		_faceData = new FaceData();									_faceData.v0 = _geometryData.vertices.length - parseInt(face2[0]) - 1;									_faceData.v1 = _geometryData.vertices.length - parseInt(face1[0]) - 1;									_faceData.v2 = _geometryData.vertices.length - parseInt(face3[0]) - 1;									_faceData.uv0 = _geometryData.uvs.length - parseInt(face2[1]) - 1;									_faceData.uv1 = _geometryData.uvs.length - parseInt(face1[1]) - 1;									_faceData.uv2 = _geometryData.uvs.length - parseInt(face3[1]) - 1;																		if (_meshMaterialData)										_meshMaterialData.faceList.push(_geometryData.faces.length);																		_geometryData.faces.push(_faceData);																	} else {									_faceData = new FaceData();									_faceData.v0 = parseInt(face1[0]) - 1;									_faceData.v1 = parseInt(face0[0]) - 1;									_faceData.v2 = parseInt(face3[0]) - 1;									_faceData.uv0 = parseInt(face1[1]) - 1;									_faceData.uv1 = parseInt(face0[1]) - 1;									_faceData.uv2 = parseInt(face3[1]) - 1;																		if (_meshMaterialData)										_meshMaterialData.faceList.push(_geometryData.faces.length);																		_geometryData.faces.push(_faceData);																		_faceData = new FaceData();									_faceData.v0 = parseInt(face2[0]) - 1;									_faceData.v1 = parseInt(face1[0]) - 1;									_faceData.v2 = parseInt(face3[0]) - 1;									_faceData.uv0 = parseInt(face2[1]) - 1;									_faceData.uv1 = parseInt(face1[1]) - 1;									_faceData.uv2 = parseInt(face3[1]) - 1;																		if (_meshMaterialData)										_meshMaterialData.faceList.push(_geometryData.faces.length);																		_geometryData.faces.push(_faceData);								}															} else {																if(isNeg){																		_faceData = new FaceData();									_faceData.v0 = _geometryData.vertices.length - parseInt(face2[0]) - 1;									_faceData.v1 = _geometryData.vertices.length - parseInt(face1[0]) - 1;									_faceData.v2 = _geometryData.vertices.length - parseInt(face0[0]) - 1;									_faceData.uv0 = _geometryData.uvs.length - parseInt(face2[1]) - 1;									_faceData.uv1 = _geometryData.uvs.length - parseInt(face1[1]) - 1;									_faceData.uv2 = _geometryData.uvs.length - parseInt(face0[1]) - 1;																		if (_meshMaterialData)										_meshMaterialData.faceList.push(_geometryData.faces.length);																		_geometryData.faces.push(_faceData);								} else {									 									_faceData = new FaceData();									_faceData.v0 = parseInt(face2[0]) - 1;									_faceData.v1 = parseInt(face1[0]) - 1;									_faceData.v2 = parseInt(face0[0]) - 1;									_faceData.uv0 = parseInt(face2[1]) - 1;									_faceData.uv1 = parseInt(face1[1]) - 1;									_faceData.uv2 = parseInt(face0[1]) - 1;																		if (_meshMaterialData)										_meshMaterialData.faceList.push(_geometryData.faces.length);																		_geometryData.faces.push(_faceData);								}															}																				//}catch(e:Error){						//	trace("Error while parsing obj file: invalid face f "+face0+","+face1+","+face2+","+face3);						//}						                        break;					                 }            }            			var index:int = obj.indexOf("mtllib");			//check materials			if (useMtl && index != -1) {				_materialLibrary.mtlLoadRequired = true;				_materialLibrary.mtlFileName = obj.substring(index + 7,obj.indexOf(".mtl") + 4);			} else {				//build materials				buildMaterials();								//built the container				if (_meshDataList.length > 1)					_container = new ObjectContainer3D();								//build the meshes				for each (_meshData in _meshDataList)					buildMesh(_meshData, _container as ObjectContainer3D);			}        }    	/** @private */        arcane function parseMtl(data:*):void        {			var lines:Array = data.split('\n');						if(lines.length == 1)				lines = data.split(String.fromCharCode(13));						var trunk:Array;			var line:String;			            for each (line in lines) {				trunk = line.split(" ");								switch (trunk[0]) {									case "newmtl":						_materialData = _materialLibrary.getMaterial(trunk[1]);						break;					case "map_Kd":						_materialData.materialType = MaterialData.TEXTURE_MATERIAL;						_materialData.textureFileName = parseMapKdString(trunk);						break;				}			}						//build materials			buildMaterials();						//built the container			if (_meshDataList.length > 1)				_container = new ObjectContainer3D();						//build the meshes			for each (_meshData in _meshDataList)				buildMesh(_meshData, _container as ObjectContainer3D);        }            	private var obj:String;        private var _mesh:Mesh;        private var _meshDataList:Array = [];        private var _meshData:MeshData;        private var _geometryData:GeometryData;        private var _faceData:FaceData;                private var _meshMaterialData:MeshMaterialData;        private var _materialData:MaterialData;      	      	private function createMesh(name:String = null):void      	{			_meshData = new MeshData();			_meshData.name = name;			_geometryData = _meshData.geometry = new GeometryData();			_meshDataList.push(_meshData);      	}		        private static function trysplit(source:String, by:String):Array        {            if (source == null)                return null;            if (source.indexOf(by) == -1)                return [source];				            return source.split(by);        }				private function parseMapKdString(trunk:Array):String		{			var url:String = "";			var i:int;			var breakflag:Boolean;						for(i = 1; i < trunk.length;) {				switch(trunk[i]) {					case "-blendu" :					case "-blendv" :					case "-cc" :					case "-clamp" :					case "-texres" :						i += 2;		//Skip ahead 1 attribute						break;					case "-mm" :						i += 3;		//Skip ahead 2 attributes						break;					case "-o" :					case "-s" :					case "-t" :						i += 4;		//Skip ahead 3 attributes						continue;					default :						breakflag = true;						break;				}								if(breakflag)					break;			}							//Reconstruct URL/filename			for(i; i < trunk.length; i++) {				url += trunk[i];				url += " ";			}						//Remove the extraneous space and/or newline from the right side			url = url.replace(/\s+$/,"");						return url;		}				/** @private */        protected override function getFileType():String        {        	return "Obj";        }            	/**    	 * A scaling factor for all geometry in the model. Defaults to 1.    	 */        public var scaling:Number;				/**		 * Determines whether to use the mtl file for defining material types		 */		public var useMtl:Boolean;				/**		 * Creates a new <code>Obj</code> object.		 * 		 * @param	init	[optional]	An initialisation object for specifying default instance properties.		 * note: Property "useMaterial" true by default added for A 2.4/3.4 and higher.		 * @see away3d.loaders.Obj#parse()		 * @see away3d.loaders.Obj#load()		 */		public function Obj(init:Object = null)        {				super(init);						scaling = ini.getNumber("scaling", 1);			useMtl = ini.getBoolean("useMtl", true);						binary = false;        }		/**		 * Creates a 3d mesh object from the raw ascii data of a obj file.		 * 		 * @param	data				The ascii data of a loaded file.		 * @param	init				[optional]	An initialisation object for specifying default instance properties.		 * 		 * @return						A 3d mesh object representation of the obj file.		 */        public static function parse(data:*, init:Object = null):Object3D        {            return Loader3D.parse(data, Obj, init).handle;        }    	    	/**    	 * Loads and parses a obj file into a 3d mesh object.    	 *     	 * @param	url					The url location of the file to load.    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.    	 *     	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.    	 */        public static function load(url:String, init:Object = null):Loader3D        {            return Loader3D.load(url, Obj, init);        }    }}
package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.containers.*;
	import away3dlite.materials.*;
	import away3dlite.materials.shaders.IShader;
	
	import flash.display.*;
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * @author robbateman
	 */
	public class Mesh extends Object3D
	{
		/** @private */
		arcane var _vertexId:int;
		/** @private */
		arcane var _screenVertices:Vector.<Number>;
		/** @private */
		arcane var _uvtData:Vector.<Number>;
		/** @private */
		arcane var _indices:Vector.<int>;
		/** @private */
		arcane var _triangles:GraphicsTrianglePath = new GraphicsTrianglePath();
		/** @private */
		arcane var _faces:Vector.<Face> = new Vector.<Face>();
		/** @private */
		arcane var _sort:Vector.<int> = new Vector.<int>();
		/** @private */
		arcane var _vertices:Vector.<Number> = new Vector.<Number>();
		/** @private */
		arcane var _faceMaterials:Vector.<Material> = new Vector.<Material>();
		/** @private */
		arcane override function updateScene(val:Scene3D):void
		{
			if (scene == val)
				return;
			
			_scene = val;
		}
		
		protected var _vertexNormals:Vector.<Number>;
		
		private var _material:Material;
		private var _bothsides:Boolean;
		private var _sortType:String;
		
		private function updateSortType():void
		{
			
			var face:Face;
			switch (_sortType) {
				case MeshSortType.CENTER:
					for each (face in _faces)
						face.calculateScreenZ = face.calculateAverageZ;
					break;
				case MeshSortType.FRONT:
					for each (face in _faces)
						face.calculateScreenZ = face.calculateNearestZ;
					break;
				case MeshSortType.BACK:
					for each (face in _faces)
						face.calculateScreenZ = face.calculateFurthestZ;
					break;
				default:
			}
		}
		
		public var sortFaces:Boolean = true;
		
		/**
		 * 
		 */
		public function get vertices():Vector.<Number>
		{
			return _vertices;
		}
		
		/**
		 * 
		 */
		public function get faces():Vector.<Face>
		{
			return _faces;
		}
		
		/**
		 * 
		 */
		public function buildFaces():void
		{
			_faceMaterials.fixed = false;
			_faces.length = _sort.length = 0;
			var i:int = _faces.length = _faceMaterials.length = _indices.length/3;
			
			while (i--)
				_faces[i] = new Face(this, i);
			
			// speed up
			_vertices.fixed = true;
			_uvtData.fixed = true;
			_indices.fixed = true;
			_faceMaterials.fixed = true;
			
			// calculate normals for the shaders
			if (_material is IShader)
 				IShader(_material).calculateNormals(_vertices, _indices, _uvtData, _vertexNormals);
 			
 			if (_scene)
 				_scene._dirtyFaces = true;
 			
 			updateSortType();
		}
		
		/**
		 * 
		 */
		public function get material():Material
		{
			return _material;
		}
		public function set material(val:Material):void
		{
			if (_material == val)
				return;
			
			_material = val;
			
			//update property in faces
			var i:int = _faces.length;
			while (i--)
				_faces[i].material = _faceMaterials[i] || _material;
				
			// calculate normals for the shaders
			if (_material is IShader)
 				IShader(_material).calculateNormals(_vertices, _indices, _uvtData, _vertexNormals);
		}
		
		/**
		 * 
		 */
		public function get bothsides():Boolean
		{
			return _bothsides;
		}
		public function set bothsides(val:Boolean):void
		{
			_bothsides = val;
			
			if (_bothsides) {
				_triangles.culling = TriangleCulling.NONE;
			} else {
				_triangles.culling = TriangleCulling.POSITIVE;
			}
		}
		
		public function set sortType(val:String):void
		{
			if (_sortType == val)
				return;
			
			_sortType = val;
			
			updateSortType();
		}
		
		public function get sortType():String
		{
			return _sortType;
		}
		
		override protected function updateDirty(matrix3D:Matrix3D):void
		{
			super.updateDirty(matrix3D);
			
			if(scene.dirty)return;
			
			// bitmap dirty
			if(material is BitmapMaterial)
			{
				scene.dirty = BitmapMaterial(material).dirty;
				BitmapMaterial(material).dirty = false;
			} 
		}
		
		/**
		 * 
		 */
		public function Mesh()
		{
			super();
			
			//default value for matrix3d
			transform.matrix3D = new Matrix3D();
			
			// private use
			_screenVertices = _triangles.vertices = new Vector.<Number>();
			_uvtData = _triangles.uvtData = new Vector.<Number>();
			_indices = _triangles.indices = new Vector.<int>();
			
			bothsides = false;
			material = new WireColorMaterial();
			sortType = MeshSortType.CENTER;
		}
		
		/**
		 * 
		 */
		public override function project(viewMatrix3D:Matrix3D, parentMatrix3D:Matrix3D = null):void
		{
			super.project(viewMatrix3D, parentMatrix3D);
			
			if(!dirty)return;
			
			// project the normals
			if (material is IShader)
				_triangles.uvtData = IShader(material).getUVData(transform.matrix3D.clone());
			
			//DO NOT CHANGE vertices getter!!!!!!!
			Utils3D.projectVectors(_viewTransform, vertices, _screenVertices, _uvtData);
		}
		        
		/**
		 * Duplicates the mesh properties to another <code>Mesh</code> object.
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied. The default is <code>Mesh</code>.
		 * @return						The new object instance with duplicated properties applied.
		 */
        public override function clone(object:Object3D = null):Object3D
        {
            var mesh:Mesh = (object as Mesh) || new Mesh();
            super.clone(mesh);
            mesh.type = type;
            mesh.material = material;
            mesh.sortType = sortType;
            mesh.bothsides = bothsides;
			mesh._vertices = vertices;
			mesh._uvtData = mesh._triangles.uvtData = _uvtData.concat();
			mesh._faceMaterials = _faceMaterials;
			mesh._indices = _indices.concat();
			mesh.buildFaces();
			
			return mesh;
        }
	}
}
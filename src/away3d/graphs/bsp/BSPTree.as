package away3d.graphs.bsp
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.geom.Frustum;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.MatrixAway3D;
	import away3d.core.math.Number3D;
	import away3d.core.render.BSPRenderer;
	import away3d.core.traverse.PrimitiveTraverser;
	import away3d.core.traverse.ProjectionTraverser;
	import away3d.core.traverse.Traverser;
	import away3d.core.utils.CameraVarsStore;
	import away3d.events.Object3DEvent;

	import flash.utils.Dictionary;

	use namespace arcane;
	
	/**
	 * BSPTree is a scene graph structure that allows static scenes to be rendered without z-sorting or z-conflicts,
	 * and performs early culling to remove big parts of the geometry that don't need to be rendered. It also speeds up various tasks such as
	 * collision detection.
	 */

	// TO DO: Move all build functionality to a wrapper!
	public class BSPTree extends ObjectContainer3D
	{
		public static const TEST_METHOD_POINT : int = 0;
		public static const TEST_METHOD_AABB : int = 1;
		public static const TEST_METHOD_ELLIPSOID : int = 2;

		public static const EPSILON : Number = 0.07;
		public static const COLLISION_EPSILON : Number = 0.1;
		
		// indicates whether or not to use the potentially visible set for culling
		public var usePVS : Boolean = true;
		
		// the root node in the tree
		arcane var _rootNode : BSPNode;
		
		// a list of all leafs in the tree, for fast access
		arcane var _leaves : Vector.<BSPNode>;
		
		// the leaf which currently contains the camera
		private var _activeLeaf : BSPNode;
		
		private var _transformPt : Number3D = new Number3D();
		private var _viewToLocal : MatrixAway3D = new MatrixAway3D();
		
		// used for correct rendering and pre-culling
		private var _cameraVarsStore : CameraVarsStore;
		private var _dynamics : Vector.<Object3D>;		
		private var _renderMark : int;		
		private var _obbCollisionTree : BSPTree;
		private var _meshManagers : Dictionary;

		private var _complete : Boolean;

		// traversal 
		private static const TRAVERSE_PRE : int = 0;
		private static const TRAVERSE_IN : int = 1;
		private static const TRAVERSE_POST : int = 2;
		private var _state : int;


		/**
		 * Creates a new BSPTree object.
		 */
		public function BSPTree(buildDynamicCollisionTree : Boolean = true)
		{
			super();
			_leaves = new Vector.<BSPNode>();
			_dynamics = new Vector.<Object3D>();
			_preCulled = true;
			_rootNode = new BSPNode(null);
			_rootNode.name = "root";
			if (buildDynamicCollisionTree) buildCollisionTree();
		}

		public function get rootNode() : BSPNode
		{
			return _rootNode;
		}

		private function buildCollisionTree() : void
		{
			var i : int;
			var node : BSPNode;
			_obbCollisionTree = new BSPTree(false);
			node = _obbCollisionTree._rootNode = new BSPNode(null);

			do {
				node._partitionPlane = new Plane3D();
				node._positiveNode = new BSPNode(node);
				node._positiveNode._isLeaf = true;
				if (i < 5) {
					node._negativeNode = new BSPNode(node);
					node = node._negativeNode;
				}
			} while (++i < 6);
		}

		/**
		 * The leaf containing the camera. Returns null if the camera is in "solid" space.
		 */
		public function get activeLeaf() : BSPNode
		{
			return _activeLeaf;
		}

		/**
		 * All the leaves in the current tree
		 */
		arcane function get leaves() : Vector.<BSPNode>
		{
			return _leaves;
		}

		/**
		 * @inheritDoc
		 * Ensure correct renderer is set when it's added
		 */
		override public function set parent(value:ObjectContainer3D):void
		{
			super.parent = value;
			ownCanvas = true;
			renderer = new BSPRenderer();
		}
		
		/**
		 * Finds the leaf that contains a given point
		 * 
		 * @param point The point to be traced. The point is expressed in local space.
		 * @param quitOnCulled Indicates whether leaf finding should stop when a culled node is encountered.
		 * @return The leaf containing the point
		 */
		public function getLeafContaining(point : Number3D, quitOnCulled : Boolean = false) : BSPNode
		{
			var node : BSPNode = _rootNode;
			var dot : Number;
			var plane : Plane3D;
			
			while (node && !node._isLeaf)
			{
				if (quitOnCulled && node._culled) return null;
				plane = node._partitionPlane;
				dot = point.x*plane.a+point.y*plane.b+point.z*plane.c;
				node = dot > -plane.d? node._positiveNode : node._negativeNode;
			} 
			
			return node;
		}
		
		/**
		 * Updates the tree's state. This method is called before the first traversal.
		 * Performs early culling and ordering of nodes.
		 * 
		 * @private
		 */
		arcane function update(camera : Camera3D, frustum : Frustum, cameraVarsStore : CameraVarsStore) : void
		{
			if (!(camera.lens is PerspectiveLens))
				throw new Error("Lens is of incorrect type! BSP needs a PerspectiveLens instance assigned to Camera3D.lens");
			
			if (!_complete) return;
			
			// force transform updates
			var i : int = _dynamics.length;
			while (--i >= 0) {
				_dynamics[i].sceneTransform;
			}
			
			var invSceneTransform : MatrixAway3D = inverseSceneTransform;
			
			// get frustum for local coordinate system
			_viewToLocal.multiply(invSceneTransform, camera.transform);
			
			// transform camera into local coordinate system
			_transformPt.transform(camera.position, invSceneTransform);
			
			// figure out leaf containing the point
			_activeLeaf = getLeafContaining(_transformPt);
			
//			if (!freezeCulling)
			doCulling(_activeLeaf, frustum);
			
			++_renderMark;
			
			_cameraVarsStore = cameraVarsStore;
		}

		private function assignDynamic(child : Object3D) : void
		{
			var leaf : BSPNode;
			var mark : int;
			
			mark = child._sceneGraphMark;
			leaf = getLeafContaining(child.position);
		
			// still in same leaf, no need to check anything
			if (leaf && leaf.leafId == mark) return;
			
			if (mark != -1)
				_leaves[mark].removeChild(child);

			if (leaf)
				leaf.addChild(child);
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addChild(child : Object3D) : void
		{
			super.addChild(child);
			_dynamics.push(child);
			
			if (child is Mesh) {
				if (!_meshManagers) _meshManagers = new Dictionary(true);
				_meshManagers[child] = new BSPMeshManager(Mesh(child), this);
			}
			else {
				child._sceneGraphMark = -1;
	//			if (child._collider) child._sceneGraphCollisionMarks = [];
				assignDynamic(child);
				child.addEventListener(Object3DEvent.TRANSFORM_CHANGED, onDynamicUpdate);
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function removeChild(child : Object3D)  :void
		{
			var index : int = _dynamics.indexOf(child);
			if (index >= 0) _dynamics.splice(index, 1);
			super.removeChild(child);
			child._sceneGraphMark = -1;
//			child._sceneGraphCollisionMarks = null;
			if (child is Mesh) {
				_meshManagers[child].destroy();
				_meshManagers[child] = null;
			}
			else {
				child.removeEventListener(Object3DEvent.TRANSFORM_CHANGED, onDynamicUpdate);
			}
		}
		
		private function onDynamicUpdate(event : Object3DEvent) : void 
		{
			assignDynamic(Object3D(event.target));
		}

		/**
		 * @inheritDoc
		 */
		public override function traverse(traverser:Traverser):void
        {
        	// act normal
        	if (!(traverser is ProjectionTraverser || traverser is PrimitiveTraverser)) {
        		super.traverse(traverser);
        		return;
        	}
        	
        	// matching PrimitiveTraverser on a BSPTree
        	// will cause update(_camera) to be called
        	if (_complete && traverser.match(this)) {
        		// after apply, visList will be processed
        		// and most nodes won't need to be traversed
       			traverser.enter(this);
       			traverser.apply(this);
       			// send down for geom
       			doTraverse(traverser);
       			traverser.leave(this);
        	}
        }
		        
        /**
         * Moves a Traverser object through the tree in the correct order to preserve z-sorting
         */
        private function doTraverse(traverser:Traverser) : void
        {
        	var mesh : Mesh;
        	var first : BSPNode;
        	var second : BSPNode;
        	var isLeaf : Boolean;
        	var changed : Boolean = true;
        	var loopNode : BSPNode = _rootNode;
			var dictionary : Dictionary = _cameraVarsStore.frustumDictionary;
			var frustum : Frustum = dictionary[this];
			var partitionPlane : Plane3D;
			
			_state = TRAVERSE_PRE;
        	
        	if (loopNode._culled) return;
        	
        	do {
        		if (changed) {
        			isLeaf = loopNode._isLeaf;
        			
        			if (isLeaf) {
						mesh = loopNode._mesh;
						dictionary[mesh] = frustum;
						
						if (traverser.match(mesh))
	            		{
		                	traverser.enter(mesh);
		                	traverser.apply(mesh);
		                	traverser.leave(mesh);
	            		}
	            		
						if (loopNode._hasChildren) {
	            			loopNode.traverseChildren(traverser);
						}
	            		
	            		// temp
//						if (	showPortals && loopNode &&
//	       						loopNode._tempMesh && 
//	       						loopNode._tempMesh.extra && 
//	       						loopNode._tempMesh.extra.created
//	       					) loopNode._tempMesh.traverse(traverser);
	            		_state = TRAVERSE_POST;
					}
					else {
						if (loopNode.renderMark != _renderMark) {
	        				partitionPlane = loopNode._partitionPlane;
						
							if (partitionPlane._alignment == Plane3D.X_AXIS)
								loopNode._lastIterationPositive = partitionPlane.a*_transformPt.x > -partitionPlane.d;
							else if (partitionPlane._alignment == Plane3D.Y_AXIS)
								loopNode._lastIterationPositive = partitionPlane.b*_transformPt.y > -partitionPlane.d;
							else if (partitionPlane._alignment == Plane3D.Z_AXIS)
								loopNode._lastIterationPositive = partitionPlane.c*_transformPt.z > -partitionPlane.d;
							else
								loopNode._lastIterationPositive = 	partitionPlane.a*_transformPt.x +
																	partitionPlane.b*_transformPt.y +
																	partitionPlane.c*_transformPt.z
																	 > -partitionPlane.d;
	        			}
						if (loopNode._lastIterationPositive) {
							first = loopNode._negativeNode;
							second = loopNode._positiveNode;
						}
						else {
							first = loopNode._positiveNode;
							second = loopNode._negativeNode;
						}
					}
        		}
        		
				if (_state == TRAVERSE_PRE) {
						if (first && !first._culled) {
							loopNode = first;
							changed = true;
						}
						else {
							_state = TRAVERSE_IN;
							changed = false;
						}
				}
				else if(_state == TRAVERSE_IN) {
					if (second && !second._culled) {
						loopNode = second;
						_state = TRAVERSE_PRE;
						changed = true;
					}
					else {
						_state = TRAVERSE_POST;
						changed = false;
					}
				}
				else if (_state == TRAVERSE_POST) {
					if ((loopNode._parent._lastIterationPositive && loopNode == loopNode._parent._negativeNode) ||
						(!loopNode._parent._lastIterationPositive && loopNode == loopNode._parent._positiveNode))
						_state = TRAVERSE_IN;
					loopNode = loopNode._parent;
					changed = true;
				}
			} while (loopNode != _rootNode || _state != TRAVERSE_POST);
        }
        
		/**
		 * Performs early culling by processing the PVS and/or testing nodes against the frustum
		 */ 
        private function doCulling(activeNode : BSPNode, frustum : Frustum) : void
        {
        	var len : int = _leaves.length;
        	var vislist : Vector.<int> = activeNode? activeNode._visList : null;
        	var i : int, j : int;
        	var leaf : BSPNode;
        	var vislen : int = vislist? vislist.length : 0;
        	
        	_rootNode._culled = false;
        	
        	// process PVS
			if (!usePVS || vislen == 0) {
        		for (i = 0; i < len; ++i)
   					_leaves[i]._culled = false;
        	}
        	else {
	        	for (i = 0; i < len; ++i) {
	        		if (j < vislen && i == vislist[j]) {
	        			leaf = _leaves[i];
	        			leaf._culled = false;
	        			leaf._mesh._preCullClassification = Frustum.IN;
	        			++j;
	        		}
	        		else {
	        			leaf = _leaves[i];
	        			leaf._culled = true;
	        		}
	        	}
	        }
	        if (activeNode) activeNode._culled = false;
			
			propagateCulled();
			cullToFrustum(frustum);
        }
        
        /**
         * Bubbles up culled state to limit deep traversal
         */
        private function propagateCulled() : void
        {
			var pos : BSPNode;
			var neg : BSPNode;
			var loopNode : BSPNode = _rootNode;
			_state = TRAVERSE_PRE;
			
			if (loopNode._culled) return;
			
			do {
				pos = loopNode._positiveNode;
				neg = loopNode._negativeNode;
				
				if (_state == TRAVERSE_PRE) {
					if (pos && !pos._isLeaf) {
						loopNode = pos;
					}
					else {
						_state = TRAVERSE_IN;
					}
				}
				else if (_state == TRAVERSE_IN) {
					if (neg && !neg._isLeaf) {
						loopNode = neg;
						_state = TRAVERSE_PRE;
					}
					else {
						_state = TRAVERSE_POST;
					}
				}
				else if (_state == TRAVERSE_POST) {
					if (loopNode._parent) {
						if (loopNode == loopNode._parent._positiveNode)
							_state = TRAVERSE_IN;
						loopNode = loopNode._parent;
					}
				}

				if (_state == TRAVERSE_POST && !loopNode._isLeaf) {
					pos = loopNode._positiveNode;
					neg = loopNode._negativeNode;
					loopNode._culled = (!pos || pos._culled) && (!neg || neg._culled);
				}
				
			} while (loopNode != _rootNode || _state != TRAVERSE_POST);
        }
        
        /**
         * Iterates the tree and tests nodes against the frustum
         */
        private function cullToFrustum(frustum : Frustum) : void
        {
			var pos : BSPNode;
			var neg : BSPNode;
			var classification : int;
			var needCheck : Boolean = true;
			var loopNode : BSPNode = _rootNode;
			
			_state = TRAVERSE_PRE;
			
			if (loopNode._culled) return;
			
			do {
				if (needCheck) {
					classification = frustum.classifyAABB(loopNode._bounds);
					loopNode._culled = (classification == Frustum.OUT);
					
        			if (loopNode._isLeaf) {
						loopNode._mesh._preCullClassification = classification;
//						if (!classification) loopNode._mesh.updateObject();
						_state = TRAVERSE_POST;
					}
					// no further descension is needed if whole bounding box completely inside or outside frustum
					else if (classification != Frustum.INTERSECT)
						_state = TRAVERSE_POST;
				}
				
				pos = loopNode._positiveNode;
				neg = loopNode._negativeNode;
				
				if(_state == TRAVERSE_PRE) {
					if (pos && !pos._culled) {
						loopNode = pos;
						needCheck = true;
					}
					else {
						_state = TRAVERSE_IN;
						needCheck = false;
					}
				}
				else if (_state == TRAVERSE_IN) {
					if (neg && !neg._culled) {
						loopNode = neg;
						_state = TRAVERSE_PRE;
						needCheck = true;
					}
					else {
						_state = TRAVERSE_POST;
						needCheck = false;
					}
				}
				else if (_state == TRAVERSE_POST) {
					if (loopNode._parent) {
						if (loopNode == loopNode._parent._positiveNode)
							_state = TRAVERSE_IN;
						loopNode = loopNode._parent;
					}
					needCheck = false;
				}
			} while (loopNode != _rootNode || _state != TRAVERSE_POST);
			
			_preCullClassification = Frustum.INTERSECT;
		}
        
		/**
		 * Finalizes the tree. Must be called by build() or by custom parser
		 *
		 * @private
		 */

		// Not liking the fact this this HAS to be called... Is an invalidation routine possible? - D
        arcane function init() : void
       	{
       		var l : int = _leaves.length;
       		for (var i : int = 0; i < l; ++i)
       		{
       			if (_leaves[i] && _leaves[i].mesh)
       				super.addChild(_leaves[i].mesh);
       		}
       		_rootNode.propagateBounds();
			_maxX = _rootNode._maxX;
			_maxY = _rootNode._maxY;
			_maxZ = _rootNode._maxZ;
			_minX = _rootNode._minX;
			_minY = _rootNode._minY;
			_minZ = _rootNode._minZ;
			_dimensionsDirty = true;
			_complete = true;
       	}
       	
       	private var _collisionDir : Number3D = new Number3D();
       	arcane var _collisionPlane : Plane3D;
       	arcane var _collisionRatio : Number;
       	arcane var _collidedObject : Object3D;
        private var _planeStack : Vector.<Plane3D> = new Vector.<Plane3D>();
        private var _tMaxStack : Vector.<Number> = new Vector.<Number>();
        private var _tMinStack : Vector.<Number> = new Vector.<Number>();
        private var _nodeStack : Vector.<BSPNode> = new Vector.<BSPNode>();
        private var _bevelStack : Vector.<Vector.<Plane3D>> = new Vector.<Vector.<Plane3D>>();
        private var _bevelNode : BSPNode = new BSPNode(null);
        private var _posNode : BSPNode = new BSPNode(_bevelNode);
        
       	/**
		 * Finds the closest colliding Face between start and end position
		 * 
		 * @param start The starting position of the object (ie the object's current position)
		 * @param end The position the object is trying to reach
		 * @param radii The radii of the object's bounding eclipse
		 * 
		 * @return The closest Face colliding with the object. Null if no collision was found.
		 */
        public function traceCollision(start : Number3D, end : Number3D, testMethod : int = TEST_METHOD_POINT, halfExtents : Number3D = null) : Boolean
        {
        	_collisionDir.x = end.x-start.x;
			_collisionDir.y = end.y-start.y;
			_collisionDir.z = end.z-start.z;
        	
        	if (testMethod == TEST_METHOD_POINT) {
        		return findCollision(start, _collisionDir, testMethod);
        	}
        	else {
	       		return findCollision(start, _collisionDir, testMethod, halfExtents);
        	}
        }
        
        /**
         * The ratio [0, 1] on the movement line where the previous collision occurred
         */
        public function get collisionRatio() : Number
        {
			return _collisionRatio;
		}
        
        /**
         * The plane against which was collided during the last call to traceCollision
         */
        public function get collisionPlane() : Plane3D
        {
			return _collisionPlane;
		}
		
		/**
		 * 
		 */
        public function get collidedObject() : Object3D
        {
        	return _collidedObject;
        }
        
        // TO Do: need initial check to see if bounding box is not already colliding with geometry in start pos
 		private function findCollision(start : Number3D, dir : Number3D, testMethod : int, halfExtents : Number3D = null, tMin : Number = 0, tMax : Number = 1) : Boolean
        {
        	var plane : Plane3D;
        	var node : BSPNode = _rootNode;
        	var dirDot : Number;
        	var dist : Number;
        	var t : Number;
        	var align : int;
        	var a : Number, b : Number, c : Number, d : Number;
        	var first : BSPNode, second : BSPNode;
        	var stackLen : int;
        	var splitPlane : Plane3D;
        	var offset : Number = 0;
        	var ox : Number, oy : Number, oz : Number;
        	var queue : Boolean;
        	var oldMax : Number;
        	var bevels : Vector.<Plane3D>;
        	var bevelIndex : int;
        	var colliders : Array;
        	
        	_bevelNode._positiveNode = _posNode;
        	_posNode._isLeaf = true;
        	
        	_planeStack.length = 0;
        	_tMinStack.length = 0;
			_tMaxStack.length = 0;
			_nodeStack.length = 0;
			_bevelStack.length = 0;
        	_collidedObject = null;
        	
        	while (true) {
        		// in a solid leaf, collision if colliding with bevel planes
				if (!node) {
					// dynamically insert bevel nodes if there are any, otherwise, reached a solid node
					if (testMethod == BSPTree.TEST_METHOD_POINT || !bevels || bevelIndex == bevels.length) {
						_collisionPlane = splitPlane;
						_collisionRatio = tMin;
						return true;
					}
					
					_bevelNode._partitionPlane = bevels[bevelIndex++];
					node = _bevelNode;
				}
				// after all bevel checks, still in solid node
				if (!node) {
					_collisionPlane = splitPlane;
					_collisionRatio = tMin;
					return true;
				}
				
        		// "empty" leaf
        		if (node._isLeaf) {
        			colliders = node._colliders;
        			if (colliders && colliders.length > 0 &&
        				traceColliders(start, dir, tMin, tMax, testMethod, halfExtents, colliders))
							return true;
        			
        			if (stackLen == 0) {
						_collisionPlane = null;
						_collisionRatio = 1;
						return false;
					}
					--stackLen;
					node = _nodeStack[stackLen];
					tMin = _tMinStack[stackLen];
					tMax = _tMaxStack[stackLen];
					splitPlane = _planeStack[stackLen];
					bevels = _bevelStack[stackLen];
				}
				else {
					if (node != _bevelNode) {
						bevels = node._bevelPlanes;
						bevelIndex = 0;
					}
					plane = node._partitionPlane;
	        		align = plane._alignment;
					d = plane.d;
	        		if (align == Plane3D.X_AXIS) {
						a = plane.a;
						dirDot = a*dir.x;
						dist = a*start.x + d;
						if (testMethod != TEST_METHOD_POINT)
							offset = halfExtents.x;
					}
					else if (align == Plane3D.Y_AXIS) {
						b = plane.b;
						dirDot = b*dir.y;
						dist = b*start.y + d;
						if (testMethod != TEST_METHOD_POINT)
							offset = halfExtents.y;
					}
					else if (align == Plane3D.Z_AXIS) {
						c = plane.c;
						dirDot = c*dir.z;
						dist = c*start.z + d;
						if (testMethod != TEST_METHOD_POINT)
							offset = halfExtents.z;
					}
					else {
						a = plane.a;
						b = plane.b;
						c = plane.c;
						dirDot = a*dir.x + b*dir.y + c*dir.z;
						dist = a*start.x + b*start.y + c*start.z + d;
						if (testMethod == TEST_METHOD_AABB)
							offset = 	(a > 0? a*halfExtents.x : -a*halfExtents.x) +
										(b > 0? b*halfExtents.y : -b*halfExtents.y) +
										(c > 0? c*halfExtents.z : -c*halfExtents.z);
						else if (testMethod == TEST_METHOD_ELLIPSOID) {
							ox = a*halfExtents.x;
							oy = b*halfExtents.y;
							oz = c*halfExtents.z;
							offset = Math.sqrt(ox*ox + oy*oy + oz*oz);
						}
					}

					dist -= offset;
					// there has to be a way to use offset/dirDot to use bounds
					if (dirDot != 0) {
						if (dirDot < 0) {
							first = node._positiveNode;
							second = node._negativeNode;
						}
						else {
							first = node._negativeNode;
							second= node._positiveNode;
						}
						// plane is between start point and segment end
						t = -dist/dirDot;
						
						oldMax = tMax;
						
						// shift plane up
						if (t >= tMin) {
							if (t < tMax) tMax = t;
							queue = true;
						}
						else queue = false;
						
						// shift plane down
						if (t <= oldMax) {
							if (queue) {
								// splitting segment
								_nodeStack[stackLen] = second;
								_tMinStack[stackLen] = t > tMin ? t : tMin;
								_tMaxStack[stackLen] = oldMax;
								_planeStack[stackLen] = plane;
								_bevelStack[stackLen] = bevels;
								++stackLen;
							}
							else {
								first = second;
							}
						}
						node = first;
					}
					else {
						if (dist >= 0) node = node._positiveNode;
						else node = node._negativeNode;
					}
				}
			}
        	
        	// this is never reached, but prevents compile error
			_collisionPlane = null;
			return false;
		}

		private function traceColliders(start : Number3D, dir : Number3D, tMin : Number, tMax : Number, testMethod : int, halfExtents : Number3D, colliders : Array) : Boolean 
		{
			var i : int = colliders.length;
			var collider : Object3D;
			
			while (--i >= 0) {
				collider = colliders[i];
				updateCollisionTree(collider);
				if (_obbCollisionTree.findCollision(start, dir, testMethod, halfExtents, tMin, tMax)) {
					_collisionPlane = _obbCollisionTree._collisionPlane;
					_collisionRatio = _obbCollisionTree._collisionRatio;
					_collidedObject = collider;
					return true;
				}
			}
			return false;
		}
		
		// transform all bounding box planes to bsp coordinate system
		// this can be improved by providing a transformation matrix in findCollision and do transforms at that point
		// we just need to reset things here to object space
		// or even better, assign a collisionTree instance to the collider (in dictionary)
		// and only update on transformChange
		private function updateCollisionTree(collider : Object3D) : void
		{
			var plane : Plane3D;
			var node : BSPNode = _obbCollisionTree._rootNode;
			var tr : MatrixAway3D = new MatrixAway3D();
			tr.inverse4x4(collider.transform);
			
			// front plane
			plane = node._partitionPlane;
			plane.a = plane.b = 0;
			plane.c = -1;
			plane.d = collider._minZ;
			plane.transform(tr);
			node = node._negativeNode;
			// back plane
			plane = node._partitionPlane;
			plane.a = plane.b = 0;
			plane.c = 1;
			plane.d = -collider._maxZ;
			plane.transform(tr);
			node = node._negativeNode;
			// left plane
			plane = node._partitionPlane;
			plane.a = -1;
			plane.b = plane.c = 0;
			plane.d = collider._minX;
			plane.transform(tr);
			node = node._negativeNode;
			// right plane
			plane = node._partitionPlane;
			plane.a = 1;
			plane.b = plane.c = 0;
			plane.d = -collider._maxX;
			plane.transform(tr);
			node = node._negativeNode;
			// top plane
			plane = node._partitionPlane;
			plane.a = plane.c = 0;
			plane.b = 1;
			plane.d = -collider._maxY;
			plane.transform(tr);
			node = node._negativeNode;
			// bottom plane
			plane = node._partitionPlane;
			plane.a = plane.c = 0;
			plane.b = -1;
			plane.d = collider._minY;
			plane.transform(tr);
		}

 		// bsp build

		arcane function addTemporaryChild(mesh : Mesh) : void
		{
			super.addChild(mesh);
		}

		arcane function removeTemporaryChild(mesh : Mesh) : void
		{
			super.removeChild(mesh);
		}
	}
}
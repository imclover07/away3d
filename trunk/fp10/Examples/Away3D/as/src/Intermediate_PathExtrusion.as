﻿/*PathExtrusion example in Away3dDemonstrates:How to use PathExtrusion to create a railtrack.How to use PathAnimator to animate a 3d object along a path.Code by Rob Batemanrob@infiniteturtles.co.ukhttp://www.infiniteturtles.co.ukModel & textures by Fabrice Closierfabrice3d@gmail.comhttp://www.closier.nlThis code is distributed under the MIT LicenseCopyright (c)  Permission is hereby granted, free of charge, to any person obtaining a copyof this software and associated documentation files (the “Software”), to dealin the Software without restriction, including without limitation the rightsto use, copy, modify, merge, publish, distribute, sublicense, and/or sellcopies of the Software, and to permit persons to whom the Software isfurnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included inall copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS ORIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THEAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHERLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS INTHE SOFTWARE.*/package{	import away3d.animators.*;	import away3d.cameras.*;	import away3d.containers.*;	import away3d.core.base.*;	import away3d.core.geom.*;	import away3d.core.utils.*;	import away3d.extrusions.*;	import away3d.loaders.*;	import away3d.materials.*;	import away3d.primitives.*;		import flash.display.*;	import flash.events.*;	import flash.geom.*;		[SWF(backgroundColor="#000000", frameRate="60", quality="LOW", width="800", height="600")]		public class Intermediate_PathExtrusion extends Sprite	{		[Embed(source="assets/frontwood.jpg")]		public static var FrontWood:Class;				[Embed(source="assets/leftwood.jpg")]		public static var LeftWood:Class;				[Embed(source="assets/rail.jpg")]		public static var Rail:Class;				[Embed(source="assets/topwood.jpg")]		public static var TopWood:Class;				//signature swf		[Embed(source="assets/signature_fab.swf", symbol="Signature")]		private var SignatureSwf:Class;				//engine variables		private var scene:Scene3D;		private var camera:Camera3D;		private var view:View3D;				//signature variables		private var Signature:Sprite;		private var SignatureBitmap:Bitmap;				//material objects		private var topWoodMaterial:BitmapMaterial;		private var frontWoodMaterial:BitmapMaterial;		private var sideWoodMaterial:BitmapMaterial;		private var materialObject:Object;		private var railMaterial:BitmapMaterial;				//scene objects		private var loader:Loader3D;		private var speedWagon:Object3D;		private var speedWagonContainer:ObjectContainer3D;		private var trackPath:Path;		private var rotationPoints:Array;		private var sleeperDuplicator:PathDuplicator;		private var rightRailExtrude:PathExtrusion;		private var leftRailExtrude:PathExtrusion;				//animation objects		private var speedWagonAnimator:PathAnimator;				//navigation variables		private var time:Number = 0;				/**		 * Constructor		 */				public function Intermediate_PathExtrusion()		{			init();		}				/**		 * Global initialise function		 */		private function init():void		{			initEngine();			initMaterials();			initObjects();			initListeners();		}				/**		 * Initialise the engine		 */		private function initEngine():void		{			scene = new Scene3D();						//camera = new Camera3D({zoom:10, focus:100, x:1000, y:2000, z:-2000, loookat:"center"});			camera = new Camera3D();			camera.zoom = 10;			camera.focus = 100;			camera.x = 1000;			camera.y = 2000;			camera.z = -2000;			camera.lookAt(scene.position);						//view = new View3D({scene:scene, camera:camera});			view = new View3D();			view.scene = scene;			view.camera = camera;						view.addSourceURL("srcview/index.html");			addChild(view);						//add signature			Signature = Sprite(new SignatureSwf());			SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));			stage.quality = StageQuality.HIGH;			SignatureBitmap.bitmapData.draw(Signature);			stage.quality = StageQuality.LOW;			addChild(SignatureBitmap);		}				/**		 * Initialise the materials		 */		private function initMaterials():void		{			topWoodMaterial = new BitmapMaterial(Cast.bitmap(TopWood));			frontWoodMaterial = new BitmapMaterial(Cast.bitmap(FrontWood));			sideWoodMaterial = new BitmapMaterial(Cast.bitmap(LeftWood));						materialObject = {left:sideWoodMaterial, right:sideWoodMaterial, top:topWoodMaterial, front:frontWoodMaterial, back:frontWoodMaterial};						railMaterial = new BitmapMaterial(Cast.bitmap(Rail));		}				/**		 * Initialise the scene objects		 */		private function initObjects():void		{			//load the speedwagon			loader = Obj.load("assets/speedwagon.obj");			loader.addOnSuccess(onLoadSuccess);						//create a serise of rotations (used for all extrusions)			rotationPoints = new Array();			rotationPoints.push(new Vector3D(0, 0, 0));			rotationPoints.push(new Vector3D(-20, 0, 0));			rotationPoints.push(new Vector3D(20, 0, 0));						//create a sleeper			var sleeperPoints:Array = 	[ new Vector3D(-300, 0, 0), new Vector3D(-240, 0, 0), new Vector3D(0, 0, 0), new Vector3D(240, 0, 0), new Vector3D(300, 0, 0) ];			var sleeper:LinearExtrusion = new LinearExtrusion(sleeperPoints, {omit:"bottom", coverall:true, materials:materialObject, thickness:80, offset:40, subdivision:1, thickness_subdivision:1, recenter:true, scaling:1});			sleeper.movePivot(0,20, 0);						//create the array of points along which to extrude the sleepers			var sleeperPath:Array = new Array();			sleeperPath.push(new Vector3D(-2000, 200, 0), new Vector3D(0, 400, 600), new Vector3D(2000, 200, 0));			sleeperPath.push(new Vector3D(2000, 200, 0), new Vector3D(4000, 0, -600), new Vector3D(6000, 1500, 0));						//create the path object to be used again for the path animator			trackPath = new Path(sleeperPath);						//create the duplicator for the sleepers			sleeperDuplicator = new PathDuplicator(trackPath, sleeper, null, rotationPoints, {scaling:1, aligntopath:true, closepath:false, recenter:true, material:null, subdivision:9, pushback:true});			scene.addChild(sleeperDuplicator);						//create the array of points used for the right rail cross-section			var rightRailPoints:Array = new Array();			rightRailPoints.push(new Vector3D(170,0, 0));			rightRailPoints.push(new Vector3D(185, 40, 0));			rightRailPoints.push(new Vector3D(175, 50, 0));			rightRailPoints.push(new Vector3D(175, 70, 0));			rightRailPoints.push(new Vector3D(185, 80, 0));			rightRailPoints.push(new Vector3D(215, 80, 0));			rightRailPoints.push(new Vector3D(225, 70, 0));			rightRailPoints.push(new Vector3D(225, 50, 0));			rightRailPoints.push(new Vector3D(215, 40, 0));			rightRailPoints.push(new Vector3D(230, 0, 0));						//create teh extrusion for the right rail			rightRailExtrude = new PathExtrusion(trackPath, rightRailPoints, null, rotationPoints,{flip:true, alignToPath:true, coverAll:false, scaling:1, recenter:true, material:railMaterial, subdivision:18});			scene.addChild(rightRailExtrude);						var leftRailPoints:Array = new Array();			leftRailPoints.push(new Vector3D(-230,0, 0));			leftRailPoints.push(new Vector3D(-215, 40, 0));			leftRailPoints.push(new Vector3D(-225, 50, 0));			leftRailPoints.push(new Vector3D(-225, 70, 0));			leftRailPoints.push(new Vector3D(-215, 80, 0));			leftRailPoints.push(new Vector3D(-185, 80, 0));			leftRailPoints.push(new Vector3D(-175, 70, 0));			leftRailPoints.push(new Vector3D(-175, 50, 0));			leftRailPoints.push(new Vector3D(-185, 40, 0));			leftRailPoints.push(new Vector3D(-170, 0, 0));						leftRailExtrude = new PathExtrusion(trackPath, leftRailPoints, null, rotationPoints,{flip:true, alignToPath:true, coverAll:false, scaling:1, recenter:true, material:railMaterial, subdivision:18});			scene.addChild(leftRailExtrude);						scene.addChild(new Trident(250, true));		}				/**		 * Initialise the animations		 */		private function initAnimations():void		{			speedWagonAnimator = new PathAnimator(trackPath, speedWagonContainer, {rotations:rotationPoints, alignToPath:true, offset:new Vector3D(0,100,0), fps:2});		}				/**		 * Initialise the listeners		 */		private function initListeners():void		{			addEventListener( Event.ENTER_FRAME, onEnterFrame);			stage.addEventListener(Event.RESIZE, onResize);			onResize();		}				/**		 * Listener function for loading complete event on loader		 */		public function onLoadSuccess(event:Event):void		{			speedWagon = loader.handle;			speedWagon.rotationX = 90;			speedWagon.rotationY = 180;			speedWagon.scale(0.6);			speedWagon.y = 10;			speedWagonContainer = new ObjectContainer3D(speedWagon);			scene.addChild(speedWagonContainer);						initAnimations();		}				/**		 * Navigation and render loop		 */		private function onEnterFrame(event:Event):void		{			//update animator			if (speedWagonAnimator) {				time += 0.02;				speedWagonAnimator.update(time);								//look at speedwagon				camera.lookAt(speedWagonContainer.position);								//sit on speedwagon				//camera.transform.clone(speedWagonContainer.transform);				//camera.moveUp(300);				//camera.moveBackward(0);								//render the view				view.render();			}					}				/**		 * stage listener for resize events		 */		private function onResize(event:Event = null):void		{			view.x = stage.stageWidth / 2;			view.y = stage.stageHeight / 2;			SignatureBitmap.y = stage.stageHeight - Signature.height;		}	}}
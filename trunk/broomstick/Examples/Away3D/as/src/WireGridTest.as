﻿package {		import away3d.entities.*;	import away3d.containers.View3D;	import away3d.cameras.lenses.PerspectiveLens;	import away3d.cameras.Camera3D;	import away3d.materials.*;	import away3d.primitives.*;	import away3d.debug.AwayStats;	import flash.display.*;	import flash.geom.Vector3D;	import flash.events.*;	[SWF(width="1168", height="700", frameRate="60")]	public class WireGridTest extends MovieClip	{		private var _testCube:Cube;		private var _view : View3D;		private var camera:Camera3D;		private var origin:Vector3D = new Vector3D(0,0,0);				private var wave:Number = 0;				public function WireGridTest()		{			addEventListener(Event.ADDED_TO_STAGE, init);		}		 		private function init(e:Event):void		{			removeEventListener(Event.ADDED_TO_STAGE, init);			initView();			populate();			 			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);		}		 		private function initView():void		{			_view = new View3D();			_view.antiAlias = 2;			_view.backgroundColor = 0x333333;			camera= _view.camera;			camera.lens = new PerspectiveLens();			 			camera.x = 500;			camera.y = 1;			camera.z = 500;			addChild(_view);			addChild(new AwayStats(_view));						camera.lookAt(new Vector3D(0,0,0));			camera.lens.near = 10;			camera.lens.far = 3000;		}				private function populate() : void		{			//UNCOMMENT TO SEE THE VARIATIONS			//displays the 3 world planes			var wireFrameGrid:WireGrid = new WireGrid(_view , 50, 500, 1, 0xffffff, null, true);						//displays default 			//var wireFrameGrid:WireFrameGrid = new WireFrameGrid(_view , 20, 500, 1, 0x985555);						//displaying a specific plane: PLANE_ZY, PLANE_XZ or PLANE_XY			//var wireFrameGrid:WireFrameGrid = new WireFrameGrid(_view , 10, 500, 1, 0xFFFFFF, WireFrameGrid.PLANE_XY);						_view.scene.addChild(wireFrameGrid);			 			var mat:BitmapMaterial = new BitmapMaterial(new BitmapData(128,128,false, 0xFFFF99));			_testCube = new Cube(mat, 100, 100, 100, 4, 4, 4);						_testCube.x = 0;			_testCube.y = 0;			_testCube.z = 0;			_view.scene.addChild(_testCube);		}		 		private function handleEnterFrame(e : Event) : void		{			 			wave += .02;			_testCube.y = 200*Math.sin(wave);			 			_view.camera.position = origin;			_view.camera.rotationY += .5;			_view.camera.moveBackward(500);			_view.camera.y = 50*Math.sin(wave);						_view.render();		}		 	}}
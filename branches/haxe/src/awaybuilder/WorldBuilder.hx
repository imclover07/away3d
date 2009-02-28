package awaybuilder;

import away3d.containers.View3D;
import awaybuilder.abstracts.AbstractBuilder;
import awaybuilder.abstracts.AbstractCameraController;
import awaybuilder.abstracts.AbstractGeometryController;
import awaybuilder.abstracts.AbstractParser;
import awaybuilder.camera.AnimationControl;
import awaybuilder.camera.CameraController;
import awaybuilder.camera.CameraFocus;
import awaybuilder.camera.CameraZoom;
import awaybuilder.collada.ColladaParser;
import awaybuilder.events.CameraEvent;
import awaybuilder.events.GeometryEvent;
import awaybuilder.events.SceneEvent;
import awaybuilder.geometry.GeometryController;
import awaybuilder.interfaces.IAssetContainer;
import awaybuilder.interfaces.ICameraController;
import awaybuilder.interfaces.ISceneContainer;
import awaybuilder.parsers.SceneXMLParser;
import awaybuilder.utils.CoordinateCopy;
import awaybuilder.vo.SceneCameraVO;
import awaybuilder.vo.SceneGeometryVO;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;


class WorldBuilder extends Sprite, implements IAssetContainer, implements ISceneContainer, implements ICameraController {
	public var worldView(getWorldView, null) : View3D;
	
	public var source:String;
	public var data:Dynamic;
	public var precision:Int;
	public var startCamera:String;
	public var update:String;
	public var cameraZoom:Float;
	public var animationControl:String;
	private var view:View3D;
	private var parser:AbstractParser;
	private var builder:AbstractBuilder;
	private var cameraController:AbstractCameraController;
	private var geometryController:AbstractGeometryController;
	

	public function new() {
		// autogenerated
		super();
		this.source = SceneSource.MAYA;
		this.precision = ScenePrecision.PERFECT;
		this.update = SceneUpdate.CONTINUOUS;
		this.cameraZoom = CameraZoom.MAYA_W720_H502;
		this.animationControl = AnimationControl.INTERNAL;
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		this.builder = new SceneBuilder();
		this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToDisplayList);
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function build():Void {
		
		this.createView();
		this.createParser();
	}

	public function addBitmapDataAsset(id:String, data:BitmapData):Void {
		
		this.builder.addBitmapDataAsset(id, data);
	}

	public function addDisplayObjectAsset(id:String, data:DisplayObject):Void {
		
		this.builder.addDisplayObjectAsset(id, data);
	}

	public function addColladaAsset(id:String, data:Xml):Void {
		
		this.builder.addColladaAsset(id, data);
	}

	public function getCameras():Array<Dynamic> {
		
		return this.builder.getCameras();
	}

	public function getGeometry():Array<Dynamic> {
		
		return this.builder.getGeometry();
	}

	public function getSections():Array<Dynamic> {
		
		return this.builder.getSections();
	}

	public function getCameraById(id:String):SceneCameraVO {
		
		return this.builder.getCameraById(id);
	}

	public function getGeometryById(id:String):SceneGeometryVO {
		
		return this.builder.getGeometryById(id);
	}

	public function navigateTo(vo:SceneCameraVO):Void {
		
		this.cameraController.navigateTo(vo);
	}

	public function teleportTo(vo:SceneCameraVO):Void {
		
		this.cameraController.teleportTo(vo);
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Protected Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	private function createView():Void {
		
		this.view = new View3D();
		this.addChild(this.view);
	}

	private function createParser():Void {
		
		switch (this.source) {
			case SceneSource.MAYA :
				this.parser = new ColladaParser();
				break;
			case SceneSource.NATIVE :
				this.parser = new SceneXMLParser();
				break;
			

		}
		this.parser.addEventListener(Event.COMPLETE, this.onParsingComplete);
		this.parser.parse(this.data);
	}

	private function setupCamera():Void {
		
		switch (this.source) {
			case SceneSource.MAYA :
				this.view.camera.focus = CameraFocus.MAYA;
				(this.cameraZoom > 0) ? this.view.camera.zoom = CameraZoom.MAYA_W720_H502 : this.view.camera.zoom = this.cameraZoom;
				break;
			case SceneSource.NATIVE :
				this.view.camera.focus = CameraFocus.DEFAULT;
				(this.cameraZoom > 0) ? this.view.camera.zoom = CameraZoom.DEFAULT : this.view.camera.zoom = this.cameraZoom;
				break;
			

		}
		if ((this.startCamera != null)) {
			var vo:SceneCameraVO = this.builder.getCameraById(this.startCamera);
			CoordinateCopy.position(vo.camera, this.view.camera);
			CoordinateCopy.rotation(vo.camera, this.view.camera);
		}
	}

	private function setupBuilder():Void {
		
		var builder:SceneBuilder = cast(this.builder, SceneBuilder);
		var sections:Array<Dynamic> = this.parser.sections;
		switch (this.source) {
			case SceneSource.MAYA :
				builder.coordinateSystem = CoordinateSystem.MAYA;
				break;
			case SceneSource.NATIVE :
				builder.coordinateSystem = CoordinateSystem.NATIVE;
				break;
			

		}
		builder.precision = this.precision;
		builder.addEventListener(SceneEvent.RENDER, this.render);
		builder.addEventListener(Event.COMPLETE, this.onBuildingComplete);
		builder.build(this.view, sections);
	}

	private function createCameraController():Void {
		
		this.cameraController = new CameraController(this.view.camera);
		this.cameraController.update = this.update;
		this.cameraController.animationControl = this.animationControl;
		if ((this.startCamera != null)) {
			var startCamera:SceneCameraVO = this.builder.getCameraById(this.startCamera);
			this.cameraController.startCamera = startCamera;
			this.cameraController.teleportTo(startCamera);
		}
		this.cameraController.addEventListener(SceneEvent.RENDER, this.render);
		this.cameraController.addEventListener(CameraEvent.ANIMATION_START, this.onCameraEvent);
		this.cameraController.addEventListener(CameraEvent.ANIMATION_COMPLETE, this.onCameraEvent);
	}

	private function createGeometryController():Void {
		
		this.geometryController = new GeometryController(this.builder.getGeometry());
		this.geometryController.addEventListener(GeometryEvent.DOWN, this.onGeometryEvent);
		this.geometryController.addEventListener(GeometryEvent.MOVE, this.onGeometryEvent);
		this.geometryController.addEventListener(GeometryEvent.OUT, this.onGeometryEvent);
		this.geometryController.addEventListener(GeometryEvent.OVER, this.onGeometryEvent);
		this.geometryController.addEventListener(GeometryEvent.UP, this.onGeometryEvent);
		this.geometryController.enableInteraction();
	}

	private function setupSceneUpdate():Void {
		
		switch (this.update) {
			case SceneUpdate.CONTINUOUS :
				this.addEventListener(Event.ENTER_FRAME, this.render);
				break;
			

		}
	}

	private function render(?event:Event=null):Void {
		
		switch (this.update) {
			case SceneUpdate.CONTINUOUS :
			case SceneUpdate.ON_CAMERA_UPDATE :
				this.view.render();
				break;
			

		}
		this.dispatchEvent(new SceneEvent(SceneEvent.RENDER));
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Event Handlers
	//
	////////////////////////////////////////////////////////////////////////////////
	private function onAddedToDisplayList(event:Event):Void {
		
		this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToDisplayList);
		this.visible = false;
	}

	private function onParsingComplete(event:Event):Void {
		
		this.setupBuilder();
	}

	private function onBuildingComplete(event:Event):Void {
		
		this.setupCamera();
		this.createCameraController();
		this.createGeometryController();
		this.setupSceneUpdate();
		this.render();
		this.visible = true;
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function onGeometryEvent(event:GeometryEvent):Void {
		
		var type:String = event.type;
		var geometry:SceneGeometryVO = event.geometry;
		var geometryEvent:GeometryEvent = new GeometryEvent(type);
		switch (type) {
			case GeometryEvent.UP :
				if ((geometry.targetCamera != null)) {
					var camera:SceneCameraVO = this.builder.getCameraById(geometry.targetCamera);
					this.cameraController.navigateTo(camera);
				}
				break;
			

		}
		geometryEvent.geometry = geometry;
		this.dispatchEvent(geometryEvent);
	}

	private function onCameraEvent(event:CameraEvent):Void {
		
		var cameraEvent:CameraEvent = new CameraEvent(event.type);
		cameraEvent.targetCamera = event.targetCamera;
		this.dispatchEvent(cameraEvent);
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Getters and Setters
	//
	////////////////////////////////////////////////////////////////////////////////
	public function getWorldView():View3D {
		
		return this.view;
	}

}


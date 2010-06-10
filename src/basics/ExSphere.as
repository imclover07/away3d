package basics
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;

	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]

	/**
	 * Sphere stress test
	 */
	public class ExSphere extends BasicTemplate
	{
		/**
		 * @inheritDoc
		 */
		override protected function onInit():void
		{
			/*
			   Test with quality MEDIUM, at 30/30FPS steady
			   --------------------------------------------
			   [Single Core]
			   BasicRenderer = 59x59 segments = 3,481 Quad faces
			   FastRenderer  = 60x60 segments = 3,600 Quad faces

			   [Quad Core]
			   BasicRenderer = 100x100 segments = 10,000 Quad faces
			   FastRenderer  = 101x101 segments = 10,201 Quad faces
			 */
			var segments:uint = 60;

			title += " : Sphere stress test " + segments + "x" + segments + " segments";

			var sphere:Sphere = new Sphere(new BitmapFileMaterial("../src/basics/assets/earth.jpg"), 100, segments, segments);
			scene.addChild(sphere);
		}

		/**
		 * @inheritDoc
		 */
		override protected function onPreRender():void
		{
			scene.rotationY += 0.2;
		}
	}
}
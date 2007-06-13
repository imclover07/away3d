﻿package away3d.core.material{    import away3d.core.*;    import away3d.core.math.*;    import away3d.core.proto.*;    import away3d.core.draw.*;    import away3d.core.render.*;    import flash.display.*;    import flash.geom.*;		import away3d.core.material.BitmapCleaner;     public class FillBitmapMaterial implements ITriangleMaterial, IUVMaterial    {        public var source_bmd:BitmapData;		public var dest_bmd:BitmapData;		public var offsetX:Number;		public var offsetY:Number;        public var debug:Boolean;		private var cleaner:Object;		public var color:Number;		public var linecolor:Number;                public function get width():Number        {            return this.source_bmd.width;        }        public function get height():Number        {            return this.source_bmd.height;        }                public function FillBitmapMaterial(source_bmd:BitmapData, dest_bmd:BitmapData, offsetX:Number, offsetY:Number, clear:Boolean= true, color:Number= 0xCCCCCCCC, linecolor:Number = -1, init:Object = null)        {            this.source_bmd = source_bmd;			this.dest_bmd = dest_bmd;			this.offsetX=offsetX;			this.offsetY=offsetY;			this.cleaner = new BitmapCleaner(this.dest_bmd, 0x00);			this.color = color;			this.linecolor = linecolor;                        init = Init.parse(init);            debug = init.getBoolean("debug", false);        }        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void        {			             var mapping:Matrix = tri.texturemapping || tri.transformUV(this);			 			var a2:Number = (tri.v1.x+this.offsetX) - (tri.v0.x+this.offsetX);            var b2:Number = (tri.v1.y+this.offsetY) - (tri.v0.y+this.offsetY);            var c2:Number = (tri.v2.x+this.offsetX) - (tri.v0.x+this.offsetX);            var d2:Number = (tri.v2.y+this.offsetY) - (tri.v0.y+this.offsetY);           	var matrix:Matrix = new Matrix(mapping.a*a2 + mapping.b*c2,                                            mapping.a*b2 + mapping.b*d2,                                            mapping.c*a2 + mapping.d*c2,                                            mapping.c*b2 + mapping.d*d2,                                           mapping.tx*a2 + mapping.ty*c2 + (tri.v0.x+this.offsetX) ,                                           mapping.tx*b2 + mapping.ty*d2 + (tri.v0.y+this.offsetY) );			var x0 = tri.v0.x+this.offsetX;			var y0 = tri.v0.y+this.offsetY;			var x1 = tri.v1.x+this.offsetX;			var y1 = tri.v1.y+this.offsetY;			var x2 = tri.v2.x+this.offsetX;			var y2 = tri.v2.y+this.offsetY;						this.cleaner.update(x0, y0, x1, y1, x2, y2)			BitmapGraphics.renderFilledTriangle(this.dest_bmd, x0, y0, x1, y1,x2, y2, this.color);						if (this.linecolor != -1){				 BitmapGraphics.drawLine(this.dest_bmd, x0, y0, x1, y1, this.linecolor);				 BitmapGraphics.drawLine(this.dest_bmd, x1, y1, x2, y2, this.linecolor);				 BitmapGraphics.drawLine(this.dest_bmd, x2, y2, x0, y0, this.linecolor);			}			        }        public function get visible():Boolean        {            return true;        }     }}
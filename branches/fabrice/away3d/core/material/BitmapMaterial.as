﻿package away3d.core.material{		import away3d.core.*;    import away3d.core.math.*;    import away3d.core.scene.*;    import away3d.core.draw.*;    import away3d.core.render.*;    import away3d.core.utils.*;		    import flash.display.*;    import flash.geom.*;	import away3d.core.material.*;    public class BitmapMaterial implements ITriangleMaterial, IUVMaterial    {        public var bitmap:BitmapData;		public var fxbitmap:BitmapData;		public var rect:Rectangle;        public var smooth:Boolean;        public var debug:Boolean;        public var repeat:Boolean;		public var light:String;		public var aFX:Array;                public function get width():Number        {            return bitmap.width;        }        public function get height():Number        {            return bitmap.height;        }                public function BitmapMaterial(bitmap:BitmapData, init:Object = null, afx:Array = null)        {            this.bitmap = bitmap;            init = Init.parse(init);            smooth = init.getBoolean("smooth", false);            debug = init.getBoolean("debug", false);            repeat = init.getBoolean("repeat", false);			light = init.getString("light", "");			if(afx != null){				this.fxbitmap = bitmap.clone();				this.rect = new Rectangle(0,0,1,1);				this.aFX = new Array();				this.aFX = afx.concat();			}        }        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void        {			var mapping:Matrix = tri.texturemapping || tri.transformUV(this);			var v0:ScreenVertex = tri.v0;			var v1:ScreenVertex = tri.v1;			var v2:ScreenVertex = tri.v2;						var sprite:Sprite;			var graphics:Graphics;						var normal:Object = null;			var source:BitmapData = this.bitmap; 			var ambient:Number;			var flatlightcolor:Number;			var a:Number;			var r:Number;			var g:Number;			var b:Number;			//fx			if(this.aFX != null){				sprite = session.sprite;				graphics = sprite.graphics;				source = this.fxbitmap;				var i:int = 0;				normal = AmbientLight.getNormal([v0, v1, v2]);				var CT:ColorTransform;				if(tri.uvrect == null){					tri.transformUV(this);				}				for(;i<this.aFX.length;i++){					//added sprite					//source					this.aFX[i].apply(i,this.bitmap, source, tri.uvrect, normal, CT); 				}			}			// ambient light			if(light == "flat"){				sprite = session.sprite;				graphics = sprite.graphics;				try{					flatlightcolor = AmbientLight.getPolygonColor([v0, v1, v2], AmbientLight.lightcolor, normal);					ambient = AmbientLight.ambientvalue;					a = -255 + ((flatlightcolor >> 24 & 0xFF)*2)+ambient;					r = -255 + ((flatlightcolor >> 16 & 0xFF)*2)+ambient;					g = -255 + ((flatlightcolor >> 8 & 0xFF)*2)+ambient;					b = -255 + ((flatlightcolor & 0xFF)*2)+ambient;					sprite.transform.colorTransform = new ColorTransform(1,1,1,1,r,g,b,1); 				} catch(er:Error){					trace("bitmapMaterial Flat color error: "+er.message);				}			}						session.renderTriangleBitmap(source, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, repeat);						if (debug){                session.renderTriangleLine(2, 0x0000FF, 1, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);			}        }        public function get visible():Boolean        {            return true;        }     }}
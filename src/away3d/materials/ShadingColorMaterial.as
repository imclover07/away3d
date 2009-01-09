package away3d.materials
{
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.Number3D;
    import away3d.core.render.*;
    import away3d.core.utils.*;
	
	/**
	 * Color material with flat shading.
	 */
    public class ShadingColorMaterial extends CenterLightingMaterial
    {
		private var fr:int;
		private var fg:int;
		private var fb:int;
		private var sfr:int;
		private var sfg:int;
		private var sfb:int;
		
		/**
		 * Defines a color value for ambient light.
		 */
        public var ambient:uint;
		
		/**
		 * Defines a color value for diffuse light.
		 */
        public var diffuse:uint;
		
		/**
		 * Defines a color value for specular light.
		 */
        public var specular:uint;
        
        /**
        * Defines an alpha value for the texture.
        */
        public var alpha:Number;
        
        /**
        * Defines whether the resulting shaded color of the surface should be cached.
        */
        public var cache:Boolean;
    	
		/**
		 * Creates a new <code>ShadingColorMaterial</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function ShadingColorMaterial(color:* = null, init:Object = null)
        {
        	if (color == null)
                color = "random";

            color = Cast.trycolor(color);
            
            super(init);
			
            ambient = ini.getColor("ambient", color);
            diffuse = ini.getColor("diffuse", color);
            specular = ini.getColor("specular", color);
            alpha = ini.getNumber("alpha", 1);
            cache = ini.getBoolean("cache", false);
        }
        
		/**
		 * @inheritDoc
		 */
        protected override function renderTri(tri:DrawTriangle, session:AbstractRenderSession, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {

        	calculateResultingColor(kar, kag, kab, kdr, kdg, kdb, ksr, ksg, ksb);

            session.renderTriangleColor(fr << 16 | fg << 8 | fb, alpha, tri.v0, tri.v1, tri.v2);

            if (cache)
                if (tri.face != null)
                {
                    sfr = int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr) >> 16);
                    sfg = int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg) >> 8);
                    sfb = int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb));

                    if (sfr > 0xFF)
                        sfr = 0xFF;
                    if (sfg > 0xFF)
                        sfg = 0xFF;
                    if (sfb > 0xFF)
                        sfb = 0xFF;

                    tri.face.material = new ColorMaterial(sfr << 16 | sfg << 8 | sfb);
                }
        }
        
        /**
		 * @inheritDoc
		 */
        protected override function renderShp(shp:DrawShape, session:AbstractRenderSession, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
        	if(alpha <= 0)
            	return;
        	
        	calculateResultingColor(kar, kag, kab, kdr, kdg, kdb, ksr, ksg, ksb);
			
			shp.source.session.renderShape(1, 0, 0, fr << 16 | fg << 8 | fb, alpha, shp);
        }
        
		/**
    	 * Indicates whether the material is visible
    	 */
        public override function get visible():Boolean
        {
            return true;
        }
 
 		private function calculateResultingColor(kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
 		{
 			fr = int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr + (specular & 0xFF0000) * ksr) >> 16);
            fg = int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg + (specular & 0x00FF00) * ksg) >> 8);
            fb = int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb + (specular & 0x0000FF) * ksb));
            
            if(fr > 0xFF)
            	fr = 0xFF;
            if(fg > 0xFF)
            	fg = 0xFF;
            if(fb > 0xFF)
            	fb = 0xFF;
 		}
    }
}

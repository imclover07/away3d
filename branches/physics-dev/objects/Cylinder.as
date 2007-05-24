package away3d.objects
{
import away3d.core.*;
import away3d.core.proto.*;
import away3d.core.geom.*;
import away3d.core.material.*;
import flash.display.BitmapData;

/**
* The Cylinder class lets you create and display Cylinders.
* <p/>
* The Cylinder is divided in vertical and horizontal segment, the smallest combination is two vertical and three horizontal segments.
*/
public class Cylinder extends Mesh3D
{
	/**
	* Number of segments horizontally. Defaults to 8.
	*/
	public var segmentsW :Number;

	/**
	* Number of segments vertically. Defaults to 6.
	*/
	public var segmentsH :Number;

	/**
	* Default radius of Cylinder if not defined.
	*/
	static public var DEFAULT_RADIUS :Number = 100;

	/**
	* Default height if not defined.
	*/
	static public var DEFAULT_HEIGHT :Number = 100;

	/**
	* Default scale of Cylinder texture if not defined.
	*/
	static public var DEFAULT_SCALE :Number = 1;

	/**
	* Default value of gridX if not defined.
	*/
	static public var DEFAULT_SEGMENTSW :Number = 8;

	/**
	* Default value of gridY if not defined.
	*/
	static public var DEFAULT_SEGMENTSH :Number = 6;

	/**
	* Minimum value of gridX.
	*/
	static public var MIN_SEGMENTSW :Number = 2;

	/**
	* Minimum value of gridY.
	*/
	static public var MIN_SEGMENTSH :Number = 1;


	// ___________________________________________________________________________________________________
	//                                                                                               N E W
	// NN  NN EEEEEE WW    WW
	// NNN NN EE     WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE     WWW  WWW
	// NN  NN EEEEEE WW    WW

	/**
	* Create a new Cylinder object.
	* <p/>
	* @param	material	A MaterialObject3D object that contains the material properties of the object.
	* <p/>
	* @param	radius		[optional] - Desired radius.
	* <p/>
	* @param	segmentsW	[optional] - Number of segments horizontally. Defaults to 8.
	* <p/>
	* @param	segmentsH	[optional] - Number of segments vertically. Defaults to 6.
	* <p/>
	* @param	topRadius	[optional] - An optional parameter for con- or diverging cylinders
	* <p/>
	* @param	initObject	[optional] - An object that contains user defined properties with which to populate the newly created GeometryObject3D.
	* <p/>
	* It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
	* <p/>
	* If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
	*/
	public function Cylinder( material:IMaterial=null, radius:Number=100, height:Number=100, segmentsW:int=8, segmentsH:int=6, topRadius:Number=0, initObject:Object=null )
	{
		super( material, initObject );

		this.segmentsW = Math.max( MIN_SEGMENTSW, segmentsW || DEFAULT_SEGMENTSW); // Defaults to 8
		this.segmentsH = Math.max( MIN_SEGMENTSH, segmentsH || DEFAULT_SEGMENTSH); // Defaults to 6
		if (radius==0) radius = DEFAULT_RADIUS; // Defaults to 100
		if (height==0) height = DEFAULT_HEIGHT; // Defaults to 100
		// if (typeOf(initObject)=="object") for each (prop in initObject) this[prop] = initObject[prop];
		if (topRadius==0) topRadius = radius;

		var scale :Number = DEFAULT_SCALE;

		buildCylinder( radius, height, topRadius );
	}

	private function buildCylinder( fRadius:Number, fHeight:Number,  fTopRadius:Number ):void
	{
		var i:Number, j:Number, k:Number;

		var iHor:Number = this.segmentsW;
		var iVer:Number = this.segmentsH;
		var aVtc:Array = new Array();
		for (j=0;j<=iVer;j++) { // vertical
			var fRad1:Number = Number(j/iVer);
			var fZ:Number = fHeight*(j/(iVer+0))-fHeight/2;//-fRadius*Math.cos(fRad1*Math.PI);
			var fRds:Number = fTopRadius+(fRadius-fTopRadius)*(1-j/(iVer));//*Math.sin(fRad1*Math.PI);
			var aRow:Array = new Array();
			var oVtx:Vertex3D;
			for (i=0;i<=iHor;i++) { // horizontal
				var fRad2:Number = Number(2*i/iHor);
				var fX:Number = fRds*Math.sin(fRad2*Math.PI);
				var fY:Number = fRds*Math.cos(fRad2*Math.PI);
				//if (!((j==0||j==iVer)&&i>0)) { // top||bottom = 1 vertex
				oVtx = new Vertex3D(fX,fY,fZ);
				vertices.push(oVtx);
				//}
				aRow.push(oVtx);
			}
			aVtc.push(aRow);
		}
		var iVerNum:int = aVtc.length;

		var aP4uv:NumberUV, aP1uv:NumberUV, aP2uv:NumberUV, aP3uv:NumberUV;
		var aP1:Vertex3D, aP2:Vertex3D, aP3:Vertex3D, aP4:Vertex3D;

		for (j=0;j<iVerNum;j++) {
			var iHorNum:int = aVtc[j].length;
			for (i=0;i<iHorNum;i++) {
				if (j>0&&i>0) {
					// select vertices
					var bEnd:Boolean = i==(iHorNum-0);
					aP1 = aVtc[j][bEnd?0:i];
					aP2 = aVtc[j][(i==0?iHorNum:i)-1];
					aP3 = aVtc[j-1][(i==0?iHorNum:i)-1];
					aP4 = aVtc[j-1][bEnd?0:i];
					// uv
					var fJ0:Number = j		/ (iVerNum - 1);
					var fJ1:Number = (j-1)	/ (iVerNum - 1);
					var fI0:Number = i	/ (iHorNum - 1);
					var fI1:Number = (i-1)		/ (iHorNum - 1);
					aP4uv = new NumberUV(fI0,fJ1);
					aP1uv = new NumberUV(fI0,fJ0);
					aP2uv = new NumberUV(fI1,fJ0);
					aP3uv = new NumberUV(fI1,fJ1);
					// 2 faces
					faces.push( new Face3D(new Array(aP1,aP2,aP3), null, new Array(aP1uv,aP2uv,aP3uv)) );
					faces.push( new Face3D(new Array(aP1,aP3,aP4), null, new Array(aP1uv,aP3uv,aP4uv)) );
				}
			}
			if (j==0||j==(iVerNum-1)) {
				for (i=0;i<(iHorNum-2);i++) {
					// uv
					var iI:int = Math.floor(i/2);
					aP1 = aVtc[j][iI];
					aP2 = (i%2==0)? (aVtc[j][iHorNum-2-iI]) : (aVtc[j][iI+1]);
					aP3 = (i%2==0)? (aVtc[j][iHorNum-1-iI]) : (aVtc[j][iHorNum-2-iI]);

					var bTop:Boolean = j!=0;
					aP1uv = new NumberUV( (bTop?1:0)+(bTop?-1:1)*(aP1.x/fRadius/2+.5), aP1.y/fRadius/2+.5 );
					aP2uv = new NumberUV( (bTop?1:0)+(bTop?-1:1)*(aP2.x/fRadius/2+.5), aP2.y/fRadius/2+.5 );
					aP3uv = new NumberUV( (bTop?1:0)+(bTop?-1:1)*(aP3.x/fRadius/2+.5), aP3.y/fRadius/2+.5 );

					// face
					if (j==0)	faces.push( new Face3D(new Array(aP1,aP3,aP2), null, new Array(aP1uv,aP3uv,aP2uv)) );
					else		faces.push( new Face3D(new Array(aP1,aP2,aP3), null, new Array(aP1uv,aP2uv,aP3uv)) );
				}
			}
		}
	}
}
}
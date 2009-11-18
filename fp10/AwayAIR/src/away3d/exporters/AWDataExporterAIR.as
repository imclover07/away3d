﻿package away3d.exporters{	import away3d.arcane;	import away3d.containers.ObjectContainer3D;	import away3d.core.base.Element;	import away3d.core.base.Face;	import away3d.core.base.Frame;	import away3d.core.base.Geometry;	import away3d.core.base.Mesh;	import away3d.core.base.Object3D;	import away3d.core.base.UV;	import away3d.core.base.Vertex;	import away3d.core.math.Number3D;	import away3d.loaders.data.MaterialData;	import away3d.materials.BitmapMaterial;	import away3d.primitives.*;	import away3d.events.ExporterEvent;		import flash.utils.*;	import flash.events.Event;	import flash.system.*;	import flash.display.BitmapData;	import flash.utils.ByteArray;	import flash.filesystem.*;		import away3d.exporters.data.JPEGEncoder;	import away3d.exporters.data.PNGEncoder; 	import away3d.exporters.data.ImageData;	import away3d.exporters.data.ExporterEventDispatcher;		use namespace arcane;		public class AWDataExporterAIR{				private var useMesh:Boolean;		private var isAnim:Boolean;		private var asString:String;		private var containerString:String;		private var materialString:String;		private var geoString:String;		private var meshString:String;		private var gcount:int;		private var mcount:int;		private var objcount:int;		private var geocount:int;		private var geonums:Dictionary;		private var facenums:Dictionary;		private var indV:int;		private var indVt:int;		private var indF:int;		private var geos:Array;				private var p1:RegExp = new RegExp("/0.0000/","g");				private var exporterEventDispatcher:ExporterEventDispatcher;		private var _exportmaps:Boolean;		private var _filename:String;		private var _aMats:Array;				private function addOnGenerateComplete(listener:Function):void        {			if(exporterEventDispatcher == null)				exporterEventDispatcher = new ExporterEventDispatcher();						exporterEventDispatcher.addOnGenerateComplete( listener);        }		 		private function removeOnGenerateComplete(listener:Function):void        {            exporterEventDispatcher.removeOnGenerateComplete(listener);        }						private  function reset():void		{			containerString = "";			materialString = "";			geoString = "";			meshString = "";			asString = "";			indV = indVt = indF = gcount = mcount = objcount = geocount = 0;			geonums = new Dictionary(true);			facenums = new Dictionary(true);			geos= [];			_aMats = [];		}			private  function write(object3d:Object3D, containerid:int = -1):void		{			var mat:String = "null"; 			var nameinsert:String = (object3d.name == null)? "" : object3d.name;			useMesh = true;			var aV:Array = [];			var aVt:Array = [];			var aF:Array = [];			var MaV:Array = [];			var MaVt:Array = [];			var imName:String = "";						if(_exportmaps && object3d is Mesh && (object3d as Mesh).material is BitmapMaterial){				var object3dname:String = (object3d as Mesh).name;				var ext:String = ((object3d as Mesh).material as BitmapMaterial).bitmap.transparent ? ".png" : ".jpg";				imName = ",images/"+object3dname+ext;				var bmd:BitmapData = ((object3d as Mesh).material as BitmapMaterial).bitmap;				_aMats.push(new ImageData(bmd, (bmd.transparent)? true : false, ""+object3dname+ext, 100));			}			 			meshString += objcount+","+object3d.transform.sxx+","+object3d.transform.sxy+","+object3d.transform.sxz+","+object3d.transform.tx+",";			meshString += object3d.transform.syx+","+object3d.transform.syy+","+object3d.transform.syz+","+object3d.transform.ty+","+object3d.transform.szx+",";			meshString += object3d.transform.szy+","+object3d.transform.szz+","+object3d.transform.tz+"\n";			meshString += nameinsert+","+object3d.pivotPoint.x+","+object3d.pivotPoint.y+","+object3d.pivotPoint.z+",";			meshString += containerid+","+(object3d as Mesh).bothsides+","+(object3d as Mesh).ownCanvas+","+(object3d as Mesh).pushfront+","+(object3d as Mesh).pushback+",";			meshString += object3d.x+","+object3d.y+","+object3d.z+imName+"\n";						var aFaces:Array = (object3d as Mesh).faces;			var geometry:Geometry = (object3d as Mesh).geometry;			var va:int;			var vb:int;			var vc:int;			var vta:int;			var vtb:int;			var vtc:int;			var nPos:Number3D = object3d.scenePosition;			var tmp:Number3D = new Number3D();			var i:int;			var j:int;			var aRef:Array = [vc, vb, va];			var animated:Boolean = (object3d as Mesh).geometry.frames != null;			var face:Face;			var geoIndex:int;						if ((geoIndex = checkGeometry(geometry)) == -1) {				geoIndex = geos.length;				geos.push(geometry);								for(i = 0; i<aFaces.length ; ++i)				{					face = aFaces[i];					geonums[face] = geoIndex;					facenums[face] = i;										for(j=0;j<3;++j){						tmp.x =  face["v"+j].x;						tmp.y =  face["v"+j].y;						tmp.z =  face["v"+j].z;						aRef[j] = checkDoubles( MaV, (tmp.x.toFixed(4)+"/"+tmp.y.toFixed(4)+"/"+tmp.z.toFixed(4)) );					}										vta = checkDoubles( MaVt, face.uv0.u +"/"+ face.uv0.v);					vtb = checkDoubles( MaVt, face.uv1.u +"/"+ face.uv1.v);					vtc = checkDoubles( MaVt, face.uv2.u +"/"+ face.uv2.v);										aF.push( aRef[0].toString(16)+","+aRef[1].toString(16)+","+aRef[2].toString(16)+","+vta.toString(16)+","+vtb.toString(16)+","+vtc.toString(16));				}								geoString += "v:"+encode( MaV.toString() )+"\n";				geoString += "u:"+encode( MaVt.toString() )+"\n";				geoString += "f:"+aF.toString()+"\n";				 			}			 			objcount ++;		}				private function encode(str:String):String		{			var start:int= 0;			var chunk:String;			var end:int= 0;			var encstr:String = "";			var charcount:int = str.length;			for(var i:int = 0;i<charcount;++i){				if (str.charCodeAt(i)>=48 && str.charCodeAt(i)<= 57 && str.charCodeAt(i)!= 48 ){					start = i;					chunk = "";					while(str.charCodeAt(i)>=48 && str.charCodeAt(i)<= 57 && i<=charcount){						i++;					}					chunk = Number(str.substring(start, i)).toString(16);					encstr+= chunk;					i--;				} else{					encstr+= str.substring(i, i+1);				}			}			return encstr.replace(p1,"/0/");		}				private function checkUnicV(arr:Array, v:Vertex, mesh:Mesh):int		{			for(var i:int = 0;i<arr.length;++i){				if(v === arr[i].vertex){					return arr[i].index;				}			}			var id:int;			for(i = 0;i<mesh.vertices.length;++i){				if(v == mesh.vertices[i]){					id = i;					break;				}			}			arr.push({vertex:v, index:id});			 			return id;		}		//to be replaced by the checkdouble code		private function checkUnicUV(arr:Array, uv:UV, mesh:Mesh):int		{			for(var i:int = 0;i<arr.length;++i){				if(uv === arr[i]) return i;			}			arr.push(uv);			return int(arr.length-1);		}				private function checkDoubles(arr:Array, string:String):int		{			for(var i:int = 0;i<arr.length;++i)				if(arr[i] == string) return i;			 			arr.push(string);			return arr.length-1;		}				private function checkGeometry(geometry:Geometry):int		{			for (var i:String in geos)				if (geos[i] == geometry)					return Number(i);						return -1;		}				private  function parse(object3d:Object3D, containerid:int = -1):void		{			if(object3d is ObjectContainer3D){				var obj:ObjectContainer3D = (object3d as ObjectContainer3D);								var id:int = gcount;				containerString += "\n"+id+","+obj.transform.sxx+","+obj.transform.sxy+","+obj.transform.sxz+","+obj.transform.tx+","+obj.transform.syx+","+obj.transform.syy+","+obj.transform.syz+","+obj.transform.ty+","+obj.transform.szx+","+obj.transform.szy+","+obj.transform.szz+","+obj.transform.tz+",";				containerString += obj.name+","+obj.pivotPoint.x+","+obj.pivotPoint.y+","+obj.pivotPoint.z;				gcount++;								for(var i:int =0;i<obj.children.length;i++){					if(obj.children[i] is ObjectContainer3D){						parse(obj.children[i], id);					} else{						write( obj.children[i], id);					}				}							} else {				write( object3d, -1);			}		}				private function checkPath(nativePath:String):String		{			var path:String = nativePath;			if(nativePath.indexOf(".awd") == -1){				path+=".awd";			}						return path;		}				 		private function writeFiles(e:Event):void		{			//recheck name in case user changed it again...			var filename:String = resolveFilename(File(e.target).name);			var file:File = File(e.target);			var stream:FileStream;						//awd file			var asfile:File = new File( file.nativePath+"/"+filename+".awd");			stream = new FileStream();			stream.open(asfile, FileMode.WRITE);						//asfile.endian = Endian.LITTLE_ENDIAN;						stream.writeUTFBytes(asString);			stream.close();			//images			if(_exportmaps && _aMats.length > 0){				var byteArray:ByteArray;				var imagedata:ImageData;				var totalfiles:int = _aMats.length;				for(var i:int = 0;i<totalfiles;++i){						imagedata = _aMats[i];												if(imagedata.image != null){							if(imagedata.transparent){								byteArray = PNGEncoder.encode( imagedata.image );							} else {								var jpgEncoder:JPEGEncoder = new JPEGEncoder( imagedata.compress );								byteArray = jpgEncoder.encode( imagedata.image );							}														try{								var wr:File = new File( file.nativePath+"/images/"+imagedata.filename);								stream = new FileStream();								stream.open( wr , FileMode.WRITE);								stream.writeBytes ( byteArray, 0, byteArray.length );								stream.close();															} catch(e:Error){							}						}												if(exporterEventDispatcher != null){							var percent:Number =  ((i+1) / totalfiles) *100;							if(percent == 100){								cleanUp();							}							dispatchSaveEvent(percent);						}				}  			}						cleanUp();			dispatchSaveEvent(100);		}				private function cleanUp():void		{			asString = "";			 			if(_aMats.length>0){				for(var i:int = 0;i<_aMats.length;++i){					_aMats[i] = null;				}				_aMats = [];			}		}		private function resolveFilename(classname:String):String		{			if(classname.indexOf(".") != -1)			 	classname = classname.substring(-1, classname.indexOf("."));							classname = classname.substring(0,1).toUpperCase()+classname.substring(1,classname.length);			return classname;		}				/**		* Class generates a string in the Actionscript3 format representing an abstraction of the object3D(s). The AWDataParser will be required for reserialisation.		*/				function AWDataExporterAIR(){}				/**		* Generates a string in the awd format (away3D data). Generate files represents the exported object3D(s).		* The event onComplete, returns in event.data the generated class string.		* This class is suitable for runtime load of data.		* The Away3D version exports only the geometry, PreFab3D or AWDataExporterAIR class supports material		* The AWData in Away3D loaders and Away3DLite are supporting both types.		*		* @param	object3d				Object3D. The Object3D to be exported to the awd format (away3d data).		* @param	filename				String. The name for the to be saved .awd file.		* @param	exportmaps			[optional] Boolean. Export the texture maps or not. Default is true.		*/		public function export(object3d:Object3D, filename:String, exportmaps:Boolean = true):void		{			_filename = filename;			_exportmaps = exportmaps;			reset();			addOnGenerateComplete(saveFiles);			parse(object3d);			asString = "//AWDataExporterAIR version 1.0, Away3D Flash 10, generated by Away3D: http://www.away3d.com\n";			asString += "#v:1.0/AIR\n"			asString += "#f:"+(_aMats.length>0? 2: 1)+"\n";			asString += "#t:"+((!gcount)? "mesh\n": "object3d\n");			asString += "#o\n"+meshString;			asString += "#d\n"+geoString;			asString += "#c"+containerString;			asString += "\n#end of file";						dispatchGenerated();		}		 		public function saveFiles(e:Event):void		{			removeOnGenerateComplete(saveFiles);			 			var f:File = File.documentsDirectory.resolvePath("/"+_filename);			f.addEventListener(Event.SELECT, writeFiles);			f.addEventListener(Event.CANCEL, dispatchCancelEvent);			f.browseForSave("Select directory to save your .awd file");		}				/**		 * Default method for adding a savecomplete event listener		 * 		 * @param	listener		The listener function		 */		public function addOnSaveComplete(listener:Function):void        {			if(exporterEventDispatcher == null)				exporterEventDispatcher = new ExporterEventDispatcher();			exporterEventDispatcher.addOnSaveComplete( listener);        }				/**		 * Default method for removing a savecomplete event listener		 * 		 * @param	listener		The listener function		 */		public function removeOnSaveComplete(listener:Function):void        {            exporterEventDispatcher.removeOnSaveComplete(listener);        }				/**		 * Default method for adding a savecanceled event listener		 * 		 * @param	listener		The listener function		 */		public function addOnSaveCanceled(listener:Function):void        {			if(exporterEventDispatcher == null)				exporterEventDispatcher = new ExporterEventDispatcher();			exporterEventDispatcher.addOnSaveCanceled( listener );        }				/**		 * Default method for removing a savecanceled event listener		 * 		 * @param	listener		The listener function		 */		public function removeOnSaveCanceled(listener:Function):void        {            exporterEventDispatcher.removeOnSaveCanceled(listener);        }				//dispatches		private function dispatchGenerated():void		{			if(exporterEventDispatcher != null)				if(exporterEventDispatcher.hasGenerateListener)					exporterEventDispatcher.dispatchGenerated();		}				private function dispatchSaveEvent(percent:Number = 100):void		{			if(exporterEventDispatcher != null)				if(exporterEventDispatcher.hasSaveListener)					exporterEventDispatcher.dispatchSave(percent);		}				private function dispatchCancelEvent(e:Event):void		{			if(exporterEventDispatcher != null)				if(exporterEventDispatcher.hasCancelListener)					exporterEventDispatcher.dispatchCancel();		}			}}
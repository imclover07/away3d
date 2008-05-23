﻿package away3d.animation{	import away3d.core.base.*;		import flash.utils.Dictionary;	public class Animator extends Mesh	{		private var varr:Array = [];		private var uvarr:Array = [];		private var fnarr:Array = [];		 				public function Animator(baseObject:Mesh, aFrames:Array, init:Object = null, doloop:Boolean = false)		{			super(init);			generate(baseObject, aFrames, doloop);						type = "Animator";        	url = "Mesh";					}				//Array aFrames properties: vertices:Array[vertex.x,y and z positions], prefix:String		public function generate(baseObject:Mesh, aFrames:Array, doloop:Boolean):void		{			var i:int ;			var j:int ;			var k:int ;						// export requirement			indexes = new Array();						if(doloop){				var fr:Object = new Object();				fr.vertices = aFrames[0].vertices;				fr.prefix = aFrames[0].prefix;				var pref:String = "";				for(i=0; i<fr.prefix.length;i++){					if(isNaN(fr.prefix.substring(i,i+1)) ){						pref += fr.prefix.substring(i,i+1);					} else{						break;					}				}				fr.prefix = pref+(aFrames.length+1);				aFrames.push(fr);			}						var face:Face;			varr = varr.concat(baseObject.vertices);						for(i=0;i<baseObject.faces.length;i++){				face = baseObject.faces[i];				uvarr.push(face.uv0, face.uv1, face.uv2);				addFace(face);            }			 			frames = new Dictionary();			framenames = new Dictionary();			fnarr = [];			var oFrames:Object = new Object();			var arr:Array;						for(i=0;i<aFrames.length;i++){				oFrames[aFrames[i].prefix]=new Array();				fnarr.push(aFrames[i].prefix);				 arr = aFrames[i].vertices;				 for(j=0;j<arr.length;j++){					 oFrames[aFrames[i].prefix].push(arr[j], arr[j], arr[j]); 				 }							} 						var frame:Frame;			for(i = 0;i<fnarr.length; i++){				trace("[ "+fnarr[i]+" ]");				frame = new Frame();				framenames[fnarr[i]] = i;				frames[i] = frame;				k=0;				 for (j = 0; j < oFrames[fnarr[i]].length; j+=3){					var vp:VertexPosition = new VertexPosition(varr[k]);					k++;						vp.x = oFrames[fnarr[i]][j].x;						vp.y = oFrames[fnarr[i]][j+1].y;						vp.z = oFrames[fnarr[i]][j+2].z;						frame.vertexpositions.push(vp);				}  								if (i == 0)					frame.adjust();			}					}				public function get framelist():Array{			return fnarr;		}				 		// not tested yet, should allow to add a frame or more at runtime too... array		// contains same object vertices and prefix as constructor.		public function addFrames(aFrames:Array):void		{			var i:int ;			var j:int ;			var k:int ;			var oFrames:Object = new Object();			var arr:Array;						for(i=0;i<aFrames.length;i++){				oFrames[aFrames[i].prefix]=new Array();				fnarr.push(aFrames[i].prefix);				arr = aFrames[i].vertices;				for(j=0;j<arr.length;j++){					oFrames[aFrames[i].prefix].push(arr[j], arr[j], arr[j]); 				}			} 			var frame:Frame;			for(i = 0;i<fnarr.length; i++){				trace("[ "+fnarr[i]+" ]");				frame = new Frame();				framenames[fnarr[i]] = i;				frames[i] = frame;				k=0;				 for (j = 0; j < oFrames[fnarr[i]].length; j+=3){					var vp:VertexPosition = new VertexPosition(varr[k]);					k++;						vp.x = oFrames[fnarr[i]][j].x;						vp.y = oFrames[fnarr[i]][j+1].y;						vp.z = oFrames[fnarr[i]][j+2].z;						frame.vertexpositions.push(vp);				}  								if (i == 0)					frame.adjust();			}					}		 			}}
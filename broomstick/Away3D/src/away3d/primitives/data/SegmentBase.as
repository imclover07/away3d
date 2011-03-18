﻿package away3d.primitives.data{	import away3d.arcane;	import away3d.entities.SegmentsBase;	import flash.geom.Vector3D;		use namespace arcane;		public class SegmentBase	{		arcane var _segmentsBase:SegmentsBase;		private var _thickness:Number;		 		private var _colors:Vector.<Number>;		private var _positions:Vector.<Number>;		private var _index:uint;		 		public function SegmentBase (v0:Vector3D, v1:Vector3D, v2:Vector3D, color0:uint = 0x333333, color1:uint = 0x333333, thickness:Number = 1):void		{			_thickness = thickness *.5;			//to do add support for curve using anchor v1			_positions = Vector.<Number>([v0.x, v0.y, v0.z, v2.x, v2.y, v2.z]);			_colors = new Vector.<Number>();			startColor 	= color0;			endColor 	= color1;		}				/**		 * Defines the starting vertex.		 */        public function get start():Vector3D        {            return new Vector3D(_positions[0], _positions[1], _positions[2] );        }        public function set start(value:Vector3D):void        {			_positions[0] = value.x;			_positions[1] = value.y;			_positions[2] = value.z;						update();        }				/**		 * Defines the ending vertex.		 */        public function get end():Vector3D        {            return new Vector3D(_positions[3], _positions[4], _positions[5] );        }		        public function set end(value:Vector3D):void        {         	_positions[3] = value.x;			_positions[4] = value.y;			_positions[5] = value.z;						update();        }				/**		 * Defines the ending vertex.		 */        public function get thickness():Number        {            return _thickness;        }		        public function set thickness(value:Number):void        {         	_thickness = value*.5;						update();        }		/**		 * Defines the startColor		 */        public function get startColor():uint        {            return  _colors[0]*255 << 16 | _colors[1]*255 << 8 | _colors[2]*255;        }		        public function set startColor(color:uint):void        {         	_colors[0] =  ( ( color >> 16 ) & 0xff ) / 255;			_colors[1] =  ( ( color >> 8 ) & 0xff ) / 255;			_colors[2] =  ( color & 0xff ) / 255;						update();        }				/**		 * Defines the endColor		 */        public function get endColor():uint        {             return  _colors[3]*255 << 16 | _colors[4]*255 << 8 | _colors[5]*255;        }		        public function set endColor(color:uint):void        {         	_colors[3] =  ( ( color >> 16 ) & 0xff ) / 255;			_colors[4] =  ( ( color >> 8 ) & 0xff ) / 255;			_colors[5] =  ( color & 0xff ) / 255;						update();        }				arcane function get index():uint        {			return _index;		}				arcane function set index(ind:uint):void        {			_index = ind;		}				arcane function set segmentsBase(segBase:SegmentsBase):void        {			_segmentsBase = segBase;		}		 		arcane function get rgbColorVector():Vector.<Number>        {			return _colors;		}		arcane function get vertices():Vector.<Number>        {			return _positions;		}		 				private function update():void		{			if(!_segmentsBase) return;			_segmentsBase.updateSegment(this);		}	}}
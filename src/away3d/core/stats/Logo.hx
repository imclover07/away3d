package away3d.core.stats;

import flash.display.Shape;
import flash.text.TextFormat;
import flash.display.Graphics;


class Logo extends Shape  {
	
	private var arr:Array<Array<Int>>;
	

	public function new() {
		// autogenerated
		super();
		this.arr = [[7, 1, 262151], [8, 1, 3215136], [9, 1, 2033436], [10, 1, 1], [7, 2, 2098723], [8, 2, 5908501], [9, 2, 4922400], [10, 2, 720913], [6, 3, 327691], [7, 3, 6957102], [8, 3, 5975556], [9, 3, 6368779], [10, 3, 4789809], [11, 3, 2], [6, 4, 2361127], [7, 4, 10833686], [8, 4, 4926728], [9, 4, 6239495], [10, 4, 9190690], [11, 4, 1114647], [5, 5, 786453], [6, 5, 7088423], [7, 5, 14055707], [8, 5, 2103310], [9, 5, 3877139], [10, 5, 13134098], [11, 5, 5577773], [12, 5, 131077], [4, 6, 1], [5, 6, 3608110], [6, 6, 11227664], [7, 6, 12748351], [8, 6, 65793], [9, 6, 986379], [10, 6, 14980667], [11, 6, 10044437], [12, 6, 2230306], [4, 7, 1179676], [5, 7, 8007967], [6, 7, 14911011], [7, 7, 6509633], [10, 7, 9138771], [11, 7, 13989655], [12, 7, 7350824], [13, 7, 327689], [3, 8, 262153], [4, 8, 4592689], [5, 8, 12016138], [6, 8, 15774570], [7, 8, 855309], [10, 8, 2434083], [11, 8, 16233056], [12, 8, 11489803], [13, 8, 3345958], [3, 9, 1966887], [4, 9, 8665113], [5, 9, 15636021], [6, 9, 6773581], [11, 9, 9140836], [12, 9, 15240489], [13, 9, 8467743], [14, 9, 852240], [2, 10, 458767], [3, 10, 5774639], [4, 10, 13265683], [5, 10, 10845518], [6, 10, 257], [11, 10, 657931], [12, 10, 14396016], [13, 10, 12739344], [14, 10, 5184297], [15, 10, 2], [2, 11, 2557230], [3, 11, 10307863], [4, 11, 12548133], [5, 11, 723464], [12, 11, 1512721], [13, 11, 14651446], [14, 11, 10307352], [15, 11, 1508630], [1, 12, 983068], [2, 12, 7154221], [3, 12, 9522185], [4, 12, 1314568], [6, 12, 131586], [7, 12, 921102], [8, 12, 1710618], [9, 12, 1513239], [10, 12, 657930], [13, 12, 2892051], [14, 12, 12610067], [15, 12, 7220009], [16, 12, 196614], [1, 13, 3936052], [2, 13, 5908749], [3, 13, 1773570], [4, 13, 4402968], [5, 13, 10714191], [6, 13, 12884326], [7, 13, 14396274], [8, 13, 15053429], [9, 13, 14790257], [10, 13, 13935206], [11, 13, 12159571], [12, 13, 9265971], [13, 13, 2759432], [14, 13, 2561537], [15, 13, 8601360], [16, 13, 3346464], [1, 14, 3938326], [2, 14, 5712395], [3, 14, 10900499], [4, 14, 11951126], [5, 14, 11490833], [6, 14, 11358991], [7, 14, 11227662], [8, 14, 11161870], [9, 14, 11030286], [10, 14, 10964497], [11, 14, 10898963], [12, 14, 10833429], [13, 14, 11096344], [14, 14, 8797973], [15, 14, 4595726], [16, 14, 4594459], [17, 14, 327941], [1, 15, 2296596], [2, 15, 3280925], [3, 15, 2821148], [4, 15, 2624284], [5, 15, 2558749], [6, 15, 2624031], [7, 15, 2558496], [8, 15, 2558498], [9, 15, 2492705], [10, 15, 2361630], [11, 15, 2361374], [12, 15, 2295839], [13, 15, 2295840], [14, 15, 2427171], [15, 15, 2624036], [16, 15, 1377300]];
		
		
		graphics.beginFill(0x000000);
		graphics.drawRect(0, 0, 18, 17);
		var _length:Int = arr.length;
		var i:Int = 0;
		while (i < _length) {
			graphics.beginFill((arr[i][2]));
			graphics.drawRect(arr[i][0], arr[i][1], 1, 1);
			
			// update loop variables
			i++;
		}

		graphics.endFill();
	}

}


package com.wmz.audiodsp.ui 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author morriswmz
	 */
	public class XYGraph extends Sprite 
	{
		
		private var intensityMatrix:Vector.<Vector.<int>>;
		private var bitmapData:BitmapData;
		private var bitmap:Bitmap;
		private var canvas:Shape;
		private var graphWidth:int;
		private var graphHeight:int;
		
		private var lastX:Number;
		private var lastY:Number;
		private var color:uint = 0x00ff00;
		
		private static const MAX_INTENSITY:int = 6;
		private static const INV_MI:Number = 1.0 / (MAX_INTENSITY - 1);
		
		public function XYGraph(w:int, h:int) 
		{
			graphWidth = w;
			graphHeight = h;
			init();
		}
		
		private function init():void {
			bitmapData = new BitmapData(graphWidth, graphHeight, false, 0xff000000);
			bitmap = new Bitmap(bitmapData);
			addChild(bitmap);
			var i:int, j:int;
			intensityMatrix = new Vector.<Vector.<int>>();
			for (i = 0 ; i < graphWidth; i++) {
				intensityMatrix[i] = new Vector.<int>();
				for (j = 0; j < graphHeight; j++) {
					intensityMatrix[i][j] = 0;
				}
			}
			lastX = graphWidth / 2;
			lastY = graphHeight / 2;
			canvas = new Shape();
		}
		
		public function render(xSource:Vector.<Number>, ySource:Vector.<Number>):void {
			var i:int, j:int, x:int, y:int;
			var px:Number, py:Number;
			var m:int = xSource.length;
			var n:int = ySource.length;
			if (m != n) throw new Error('x y vector length mismatch!');
			var halfWidth:int = graphWidth >> 1;
			var halfHeight:int = graphHeight >> 1;
			for (i = 0; i < m; i++) {
				x = halfWidth * (1.0 + xSource[i]);
				y = halfHeight * (1.0 + ySource[i]);
				if (x >= graphWidth) { x = graphWidth - 1; }
				if (x < 0) { x = 0; }
				if (y >= graphHeight) { y = graphHeight - 1; }
				if (y < 0) { y = 0; }
				intensityMatrix[x][y] = MAX_INTENSITY;
			}
			
			//canvas.graphics.clear();
			//canvas.graphics.lineStyle(1, 0x00ff00, 0.5);
			//canvas.graphics.moveTo(lastX, lastY);
			//for (i = 1; i < m; i++) {
				//px = halfWidth * (1.0 + xSource[i]);
				//py = halfHeight * (1.0 + ySource[i]);
				//if (px >= graphWidth) { px = graphWidth - 1; }
				//if (px < 0) { px = 0; }
				//if (py >= graphHeight) { py = graphHeight - 1; }
				//if (py < 0) { py = 0; }
				//canvas.graphics.lineTo(px, py);
			//}
			//lastX = px;
			//lastY = py;
			//bitmapData.lock();
			//bitmapData.fillRect(bitmapData.rect, 0x000000);
			//bitmapData.draw(canvas, null, null, null, null, true);
			//bitmapData.unlock();
			
			bitmapData.lock();
			for (i = 0; i < graphWidth; i++) {
				for (j = 0; j < graphHeight; j++) {
					intensityMatrix[i][j] --;
					if (intensityMatrix[i][j] < 0) {
						intensityMatrix[i][j] = 0;
					}
					bitmapData.setPixel(i, j, int(Number(intensityMatrix[i][j]) * INV_MI * 255) << 8);
				}
			}
			bitmapData.unlock();
		}
	}

}
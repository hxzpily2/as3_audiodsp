package com.wmz.audiodsp.ui 
{
	import com.wmz.audiodsp.math.FFTResult;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class SpectrumMap extends Sprite
	{
		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;
		private var translationMat:Matrix;
		
		public function SpectrumMap(p_x:Number=0, p_y:Number=0,p_w:Number=200, p_h:Number=100) 
		{
			this.x = p_x;
			this.y = p_y;
			bitmapData = new BitmapData(int(p_w), int(p_h), false, 0xff000000);
			bitmap = new Bitmap(bitmapData);
			addChild(bitmap);
		}
		
		public function render(p_ffts:FFTResult):void {
			if (!p_ffts) return;
			var n:int = p_ffts.re.length / 2;
			var i:int;
			var divider:int = n / bitmapData.height;
			var spectrum:Vector.<Number> = p_ffts.getAmplitude(divider, n, true, true);
			var redLevel:uint;
			var greenLevel:uint;
			var cur:Number;
			bitmapData.scroll( -1, 0);
			for (i = 0; i < bitmapData.height; i++) {
				cur = - spectrum[i] / 40;
				if (cur < 0) cur = 0;
				if (cur > 1.0) cur = 1.0
				redLevel = 255 * (1.0 - cur);
				if (cur > 0.7) {
					greenLevel = 0;
				} else {
					greenLevel = 255 * (0.7 - cur);
				}
				bitmapData.setPixel(bitmapData.width - 1, i, (redLevel << 16) + (greenLevel << 8));
			}
		}
		
	}

}
package com.wmz.audiodsp.ui 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author morriswmz
	 */
	public class WaveGraph extends Sprite 
	{
		public var waveWidth:Number;
		public var waveHeight:Number;
		private var waveColor:uint;
		
		public function WaveGraph(p_x:Number = 0.0, p_y:Number= 0.0, p_w:Number=200.0, p_h:Number=100.0, color:uint=0xffffff) 
		{
			super();
			this.x = p_x;
			this.y = p_y;
			waveWidth = p_w;
			waveHeight = p_h;
			waveColor = color;
		}
		
		public function render(p_wave:Vector.<Number>, divider:int = 1):void {
			this.graphics.clear();
			var n:int = p_wave.length;
			var n_1:int = n + 1;
			var curX:Number;
			var curY:Number;
			this.graphics.lineStyle(1, waveColor);
			this.graphics.moveTo(0, waveHeight * 0.5);
			this.graphics.lineTo(waveWidth, waveHeight * 0.5);
			for (var i:int = 0; i < n; i+=divider) {
				curX = i * waveWidth / n;
				curY = waveHeight * 0.5 * (1.0 - p_wave[i]);
				this.graphics.moveTo(curX, waveHeight - curY);
				this.graphics.lineTo(curX, curY);
			}
		}
		
	}

}
package com.wmz.audiodsp.ui 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class ProgressBar extends Sprite
	{
		public var barWidth:Number;
		public var barHeight:Number;
		
		public function ProgressBar(p_x:Number = 0.0, p_y:Number= 0.0, p_w:Number=200.0, p_h:Number=100.0, p_limit:int=0) 
		{
			super();
			this.x = p_x;
			this.y = p_y;
			barWidth = p_w;
			barHeight = p_h;
		}
		
		public function render(ratio:Number):void {
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xffffff);
			this.graphics.drawRect(0, 0, barWidth, barHeight);
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRect(0, 0, barWidth * ratio, barHeight);
			this.graphics.endFill();
		}
	}

}
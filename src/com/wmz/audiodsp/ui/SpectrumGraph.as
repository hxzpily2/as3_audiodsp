package com.wmz.audiodsp.ui 
{
	import com.wmz.audiodsp.math.FFTResult;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class SpectrumGraph extends Sprite 
	{
		private var axisPadding:Number = 32.0;
		public var spectrumWidth:Number;
		public var spectrumHeight:Number;
		public var color:uint = 0xffffff;
		public var limit:int;
		
		private var maxText:TextField;
		private var minText:TextField;
		
		public function SpectrumGraph(p_x:Number = 0.0, p_y:Number= 0.0, p_w:Number=200.0, p_h:Number=100.0, p_limit:int=0) 
		{
			super();
			this.x = p_x;
			this.y = p_y;
			spectrumWidth = p_w;
			spectrumHeight = p_h;
			limit = p_limit;
			
			var format:TextFormat = new TextFormat('Arial', 10, 0xffffff);
			format.align = 'right';
			maxText = new TextField();
			minText = new TextField();
			maxText.text = '0dB';
			maxText.setTextFormat(format);
			maxText.width = axisPadding;
			maxText.height = 18;
			maxText.y = -maxText.height/2;
			maxText.x = 0;
			minText.text = '-40dB';
			minText.setTextFormat(format);
			minText.width = axisPadding;
			minText.height = 18;
			minText.x = 0;
			minText.y = spectrumHeight - minText.height / 2;
			addChild(maxText);
			addChild(minText);
		}
		
		public function render(p_fftr:FFTResult):void {
			if (!p_fftr) return;
			this.graphics.clear();
			var spectrum:Vector.<Number> = p_fftr.getAmplitude(16, limit,true, true);
			var n:int = spectrum.length;
			var n_1:int = n + 1;
			var curX:Number;
			var curY:Number;
			this.graphics.lineStyle(1, color, 1.0);
			this.graphics.moveTo(0, spectrumHeight);
			for (var i:int = 0; i < n; i++) {
				curX = (i + 1) * (spectrumWidth - axisPadding - 2.0) / n + axisPadding;
				this.graphics.moveTo(curX, spectrumHeight);
				// max -100dB
				curY =  - spectrum[i] / 40;
				if (curY < 0) curY = 0;
				if (curY > 1.0) curY = 1.0
				curY *= spectrumHeight;
				this.graphics.lineTo(curX, curY);
			}
			this.graphics.lineStyle(1.0, color, 0.5);
			this.graphics.moveTo(axisPadding, 0);
			this.graphics.lineTo(axisPadding, spectrumHeight);
			this.graphics.lineTo(spectrumWidth, spectrumHeight);
			//this.graphics.drawRect(axisPadding, 0, spectrumWidth - 1 - axisPadding, spectrumHeight - 1);
		}
	}

}
package com.wmz.audiodsp.filters 
{
	/**
	 * ...
	 * @author morriswmz
	 */
	public class TDEqualizer implements ITimeDomainFilter 
	{
		private var eqValues:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
		private var buffer:Vector.<Number> = new Vector.<Number>();
		private var eqChannels:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		
		private var x_n1:Vector.<Number> = new Vector.<Number>(nEqChannel);
		private var x_n2:Vector.<Number> = new Vector.<Number>(nEqChannel);
		private var y_n1:Vector.<Number> = new Vector.<Number>(nEqChannel);
		private var y_n2:Vector.<Number> = new Vector.<Number>(nEqChannel);
		
		private static var eqDefault:Vector.<Number> = new <Number>[1,1,1,1,1,1,1,1,1,1];
		private static var nEqChannel:int = 10;
		private static var inv_nEqChannel:Number = 1.0 / nEqChannel;
		private var coeff_alpha:Vector.<Number> = new Vector.<Number>();
		private var coeff_beta:Vector.<Number> = new Vector.<Number>();
		private var coeff_gamma:Vector.<Number> = new Vector.<Number>();
		private var coeff_delta:Vector.<Number> = new Vector.<Number>();
		
		private var oldEq:Vector.<Number>;
		private var newEq:Vector.<Number>;
		private var newEqLoaded:Boolean = false;
		private var transitionPos:Number = 0.0;
		private var transitioning:Boolean = false;
		private static var transitionStep:Number = 0.5;
		
		
		private static var centerFreqs:Vector.<Number> = new <Number>[
			31,
			62,
			125,
			250,
			500,
			1000,
			2000,
			4000,
			8000,
			16000
		];
		
		public function TDEqualizer(eqv:Vector.<Number> = null) 
		{
			newEq = new Vector.<Number>();
			oldEq = new Vector.<Number>();
			initeqChannels(eqv);
			reset();
		}
		
		public function initeqChannels(eqv:Vector.<Number> = null):void {
			var i:int;
			var tmp:Vector.<Number>;
			nEqChannel = centerFreqs.length;
			inv_nEqChannel = 1.0 / nEqChannel;
			if (eqv) {
				for (i = 0; i < nEqChannel; i++) {
					eqValues[i] = eqv[i];
				}
			} else {
				for (i = 0; i < nEqChannel; i++) {
					eqValues[i] = eqDefault[i];
				}
			}
			for (i = 0; i < nEqChannel; i++) {
				eqChannels[i] = new Vector.<Number>();
				tmp = calcEQCoeff(2 * Math.PI * centerFreqs[i] / 44100, 1.4, eqValues[i]);
				coeff_alpha[i] = tmp[0];
				coeff_beta[i] = tmp[1];
				coeff_gamma[i] = tmp[2];
				coeff_delta[i] = tmp[3];
			}
		}
		
		public function setEQ(newEQ:Vector.<Number>):void {
			var i:int;
			var same:Boolean = true;
			if (!newEQ) return;
			for (i = 0; i < newEQ.length; i++) {
				if (eqValues[i] != newEQ[i]) {
					same = false;
					break;
				}
			}
			if (!same) {
				for (i = 0; i < nEqChannel; i++) {
					oldEq[i] = eqValues[i];
					newEq[i] = newEQ[i];
				}
				newEqLoaded = true;
			}
		}
		
		public function reset():void {
			var i:int;
			for (i = 0; i < nEqChannel; i++) {
				eqValues[i] = eqDefault[i];
				y_n1[i] = 0;
				y_n2[i] = 0;
				x_n1[i] = 0;
				x_n2[i] = 0;
			}
		}
		
		public function apply(p_seq:Vector.<Number>, clone:Boolean = false):Vector.<Number> {
			var i:int, ch:int;
			var n:int = p_seq.length;
			var tx_n1:Number, tx_n2:Number;
			var alpha:Number, beta:Number, gamma:Number, delta:Number;
			var curChannel:Vector.<Number>;
			var sourceSeq:Vector.<Number>;
			
			if (newEqLoaded) {
				newEqLoaded = false;
				initeqChannels(newEq);		
			}
			
			sourceSeq = p_seq;
			for (ch = 0; ch < nEqChannel; ch++) {
				alpha = coeff_alpha[ch];
				beta = coeff_beta[ch];
				gamma = coeff_gamma[ch];
				delta = coeff_delta[ch];
				tx_n1 = x_n1[ch];
				tx_n2 = x_n2[ch];
				x_n1[ch] = sourceSeq[n - 1];
				x_n2[ch] = sourceSeq[n - 2];
				curChannel = eqChannels[ch];
				curChannel[0] = alpha * sourceSeq[0] + beta * tx_n2 + gamma * (tx_n1 - y_n1[ch]) - delta * y_n2[ch];
				curChannel[1] = alpha * sourceSeq[1] + beta * tx_n1 + gamma * (sourceSeq[0] - curChannel[0]) - delta * y_n1[ch];
				for (i = 2; i < n; i++) {
					curChannel[i] = alpha * sourceSeq[i] + beta * sourceSeq[i - 2] + gamma * (sourceSeq[i - 1] - curChannel[i - 1]) - delta * curChannel[i - 2];
				}
				y_n1[ch] = curChannel[n - 1];
				y_n2[ch] = curChannel[n - 2];
				sourceSeq = curChannel;
			}
			if (clone) {
				for (i = 0; i < n; i++) {
					buffer[i] = curChannel[i];
				}
				return buffer;
			} else {
				for (i = 0; i < n; i++) {
					p_seq[i] = curChannel[i];
				}
				return null;
			}
		}
		
		private function transition():void {
			var i:int;
			transitionPos += transitionStep;
			if (transitionPos >= 1.00) {
				transitioning = false;
				transitionPos = 0.0;
				for (i = 0; i < nEqChannel; i++) {
					eqValues[i] = oldEq[i] * (1 - transitionPos) + newEq[i] * transitionPos;
				}
			} else {
				for (i = 0; i < nEqChannel; i++) {
					eqValues[i] = newEq[i];
				}
			}
			initeqChannels(eqValues);
		}
		
		// using bi-quad peakEQ filter
		// y[n] = alpha * x[n] + beta * x[n-2] + gamma * (x[n-1] - y[n-1]) + delta * y[n-2]
		// alpha = b0/a0
		// beta = b2/a0
		// gamma = [b1|a1]/a0
		// delta = a2/a0
		private function calcEQCoeff(w0:Number, q:Number, A:Number = 1.0):Vector.<Number> {
			var coeffs:Vector.<Number> = new Vector.<Number>(4);
			var alpha:Number = Math.sin(w0) / q * 0.5 * A;
			var b0:Number = 1 + alpha*A;
			var b1:Number = -2 * Math.cos(w0);
			var b2:Number = 1 - alpha*A;
			var a0:Number = 1 + alpha/A;
			var a1:Number = -2 * Math.cos(w0);
			var a2:Number = 1 - alpha / A;
			//trace('design wa = ' + w0 * 44100 + ' q = ' + q + ' A = ' + A);
			//trace('freqz([' + b0 + ' ' + b1 + ' ' + b2 + '],[' + a0 + ' ' + a1 + ' ' + a2 + '])');
			//trace(newEq);
			coeffs[0] = b0 / a0;
			coeffs[1] = b2 / a0;
			coeffs[2] = b1 / a0;
			coeffs[3] = a2 / a0;
			return coeffs;
		}
	}

}
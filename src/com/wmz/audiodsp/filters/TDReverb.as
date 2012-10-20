package com.wmz.audiodsp.filters 
{
	import com.wmz.audiodsp.data.NumberRing;
	import com.wmz.audiodsp.data.NumberRingNode;
	/**
	 * ...
	 * @author morriswmz
	 */
	public class TDReverb implements ITimeDomainFilter 
	{
		
		//
		private static const AP1_DELAY:int = 113;
		private static const AP2_DELAY:int = 337;
		private static const AP3_DELAY:int = 1051;
		
		private var inputRingBuffer:NumberRing;
		private var comb1RingBuffer:NumberRing;
		private var comb2RingBuffer:NumberRing;
		private var comb3RingBuffer:NumberRing;
		private var comb4RingBuffer:NumberRing;
		private var comb1XMPtr:NumberRingNode;
		private var comb2XMPtr:NumberRingNode;
		private var comb3XMPtr:NumberRingNode;
		private var comb4XMPtr:NumberRingNode;
		private var comb1ReadPtr:NumberRingNode;
		private var comb2ReadPtr:NumberRingNode;
		private var comb3ReadPtr:NumberRingNode;
		private var comb4ReadPtr:NumberRingNode;
		private var inputWritePtr:NumberRingNode;
		private var comb1WritePtr:NumberRingNode;
		private var comb2WritePtr:NumberRingNode;
		private var comb3WritePtr:NumberRingNode;
		private var comb4WritePtr:NumberRingNode;
		
		private var lpfXRingBuffer:NumberRing;
		private var lpfYRingBuffer:NumberRing;
		/*
		 *        |--> comb1[RY] -->|
		 *        |--> comb2[RY] -->|
		 * p_seq -|--> comb3[RY] -->+ --> ap1[RX, RY] --> ap2[RX, RY]
		 *        |--> comb4[RY] -->|
		 * 
		 * 
		 */
		
		private var ap1XRingBuffer:NumberRing;
		private var ap1YRingBuffer:NumberRing;
		private var ap2XRingBuffer:NumberRing;
		private var ap2YRingBuffer:NumberRing;
		private var ap3XRingBuffer:NumberRing;
		private var ap3YRingBuffer:NumberRing;
		private var ap1XReadPtr:NumberRingNode;		// AP1 x[n-k]
		private var ap1XWritePtr:NumberRingNode;	// AP1 x[n]
		private var ap1YReadPtr:NumberRingNode;		// AP1 y[n-k]
		private var ap1YWritePtr:NumberRingNode;	// AP1 y[n]
		private var ap2XReadPtr:NumberRingNode;		// AP2 x[n-k]
		private var ap2XWritePtr:NumberRingNode;	// AP2 x[n]
		private var ap2YReadPtr:NumberRingNode;		// AP2 y[n-k]
		private var ap2YWritePtr:NumberRingNode;	// AP2 y[n]
		private var ap3XReadPtr:NumberRingNode;		// AP3 x[n-k]
		private var ap3XWritePtr:NumberRingNode;	// AP3 x[n]
		private var ap3YReadPtr:NumberRingNode;		// AP3 y[n-k]
		private var ap3YWritePtr:NumberRingNode;	// AP3 y[n]
		
		private var buffer:Vector.<Number>;
		private var bufferSize:int;
		private var reverbTime:Number;
		private var reverbStrength:Number;
		private var comb1Gain:Number;
		private var comb2Gain:Number;
		private var comb3Gain:Number;
		private var comb4Gain:Number;
		private var ap1Gain:Number;
		private var ap2Gain:Number;
		private var ap3Gain:Number;
		private static const lpfFc:Number = 1000;
		private static const lpfQ:Number = 1.8;
		
		private var lpfB00:Number;
		private var lpfB10:Number;
		private var lpfB20:Number;
		private var lpfA10:Number;
		private var lpfA20:Number;
		
		private var lpfX_n0:NumberRingNode;
		private var lpfX_n1:NumberRingNode;
		private var lpfX_n2:NumberRingNode;
		private var lpfY_n0:NumberRingNode;
		private var lpfY_n1:NumberRingNode;
		private var lpfY_n2:NumberRingNode;
		
		// delay in samples
		private static const COMB1_DELAY:int = 1523;
		private static const COMB2_DELAY:int = 1601;
		private static const COMB3_DELAY:int = 1747;
		private static const COMB4_DELAY:int = 1873;
		private static const COMB5_DELAY:int = 2027;
		
		private var maxDelay:int;
		
		
		public function TDReverb(decayTime:Number, p_strength:Number, bSize:int) 
		{
			reverbTime = decayTime;
			reverbStrength = p_strength;
			bufferSize = bSize;
			init();
		}
		
		public function get strength():Number {
			return reverbStrength;
		}
		
		public function set strength(p_strength:Number):void {
			reverbStrength = p_strength;
		}
		
		
		public function init():void {
			var i:int;
			
			buffer = new Vector.<Number>();
			
			// init number rings
			
			// #input
			inputRingBuffer = new NumberRing();
			maxDelay = Math.max(Math.max(COMB1_DELAY, COMB2_DELAY), Math.max(COMB3_DELAY, COMB4_DELAY));
			for (i = 0; i < maxDelay + bufferSize + 1; i++) { inputRingBuffer.insert(0); }
			comb1XMPtr = inputRingBuffer.seek(maxDelay - COMB1_DELAY);
			comb2XMPtr = inputRingBuffer.seek(maxDelay - COMB2_DELAY);
			comb3XMPtr = inputRingBuffer.seek(maxDelay - COMB3_DELAY);
			comb4XMPtr = inputRingBuffer.seek(maxDelay - COMB4_DELAY);
			inputWritePtr = inputRingBuffer.seek(maxDelay);
			
			// #1
			comb1RingBuffer = new NumberRing();
			for (i = 0; i < COMB1_DELAY; i++) { comb1RingBuffer.insert(0); }
			comb1WritePtr = comb1RingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { comb1RingBuffer.insert(0); }
			comb1ReadPtr = comb1RingBuffer.head;
			// #2
			comb2RingBuffer = new NumberRing();
			for (i = 0; i < COMB2_DELAY; i++) { comb2RingBuffer.insert(0); }
			comb2WritePtr = comb2RingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { comb2RingBuffer.insert(0); }
			comb2ReadPtr = comb2RingBuffer.head;
			// #3
			comb3RingBuffer = new NumberRing();
			for (i = 0; i < COMB3_DELAY; i++) { comb3RingBuffer.insert(0); }
			comb3WritePtr = comb3RingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { comb3RingBuffer.insert(0); }
			comb3ReadPtr = comb3RingBuffer.head;
			// #4
			comb4RingBuffer = new NumberRing();
			for (i = 0; i < COMB4_DELAY; i++) { comb4RingBuffer.insert(0); }
			comb4WritePtr = comb4RingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { comb4RingBuffer.insert(0); }
			comb4ReadPtr = comb4RingBuffer.head;
			
			// lpf
			lpfXRingBuffer = new NumberRing();
			for (i = 0; i < bufferSize + 2; i++) { lpfXRingBuffer.insert(0); }
			lpfX_n0 = lpfXRingBuffer.seek(2);
			lpfX_n1 = lpfXRingBuffer.seek(1);
			lpfX_n2 = lpfXRingBuffer.head;
			
			lpfYRingBuffer = new NumberRing();
			for (i = 0; i < bufferSize + 2; i++) { lpfYRingBuffer.insert(0); }
			lpfY_n0 = lpfYRingBuffer.seek(2);
			lpfY_n1 = lpfYRingBuffer.seek(1);
			lpfY_n2 = lpfYRingBuffer.head;
			
			// AP1
			ap1XRingBuffer = new NumberRing();
			for (i = 0; i < AP1_DELAY; i++) { ap1XRingBuffer.insert(0); }
			ap1XWritePtr = ap1XRingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { ap1XRingBuffer.insert(0); }
			ap1XReadPtr = ap1XRingBuffer.head;
			
			ap1YRingBuffer = new NumberRing();
			for (i = 0; i < AP1_DELAY; i++) { ap1YRingBuffer.insert(0); }
			ap1YWritePtr = ap1YRingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { ap1YRingBuffer.insert(0); }
			ap1YReadPtr = ap1YRingBuffer.head;
			
			// AP2
			ap2XRingBuffer = new NumberRing();
			for (i = 0; i < AP2_DELAY; i++) { ap2XRingBuffer.insert(0); }
			ap2XWritePtr = ap2XRingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { ap2XRingBuffer.insert(0); }
			ap2XReadPtr = ap2XRingBuffer.head;
			
			ap2YRingBuffer = new NumberRing();
			for (i = 0; i < AP2_DELAY; i++) { ap2YRingBuffer.insert(0); }
			ap2YWritePtr = ap2YRingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { ap2YRingBuffer.insert(0); }
			ap2YReadPtr = ap2YRingBuffer.head;
			
			// AP3
			ap3XRingBuffer = new NumberRing();
			for (i = 0; i < AP3_DELAY; i++) { ap3XRingBuffer.insert(0); }
			ap3XWritePtr = ap3XRingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { ap3XRingBuffer.insert(0); }
			ap3XReadPtr = ap3XRingBuffer.head;
			
			ap3YRingBuffer = new NumberRing();
			for (i = 0; i < AP3_DELAY; i++) { ap3YRingBuffer.insert(0); }
			ap3YWritePtr = ap3YRingBuffer.insert(0);
			for (i = 0; i < bufferSize; i++) { ap3YRingBuffer.insert(0); }
			ap3YReadPtr = ap3YRingBuffer.head;
			
			// calc coeffs
			calcCoeffs();
			
		}
		
		public function reset():void {
			
		}
		
		public function apply(p_seq:Vector.<Number>, clone:Boolean = false):Vector.<Number> {
			var i:int;
			// update sequence : last stage --> first stage
			// apply ap2, ap1, 4 combs
			for (i = 0; i < bufferSize; i++) {
				//y3[n] = g * (y3[n-k] - x3[n]) + x3[n-k]
				//ap3YWritePtr.data = ap3Gain * (ap3YReadPtr.data - ap3XWritePtr.data) + ap3XReadPtr.data;
				// x3[n] = y2[n]
				//ap3XWritePtr.data = ap2YWritePtr.data;
				// y2[n] = g * (y2[n-k] - x2[n]) + x2[n-k]
				ap2YWritePtr.data = ap2Gain * (ap2YReadPtr.data - ap2XWritePtr.data) + ap2XReadPtr.data;
				// x2[n] = y1[n]
				ap2XWritePtr.data = ap1YWritePtr.data;
				// y1[n] = g * (y1[n-k] - x1[n]) + x1[n-k]
				ap1YWritePtr.data = ap1Gain * (ap1YReadPtr.data - ap1XWritePtr.data) + ap1XReadPtr.data;
				// x1[n] = lpfOut[n]
				ap1XWritePtr.data = lpfY_n0.data;
				// lpf
				lpfY_n0.data = lpfB00 * (lpfX_n0.data + lpfX_n2.data) + lpfB10 * lpfX_n1.data - lpfA10 * lpfY_n1.data - lpfA20 * lpfY_n2.data;
				lpfX_n0.data = comb1WritePtr.data * 0.08 + comb2WritePtr.data * 0.04 + comb3WritePtr.data * 0.02 + comb4WritePtr.data * 0.01;
				
				// combs
				comb1WritePtr.data = comb1XMPtr.data + comb1Gain * comb1ReadPtr.data;
				comb2WritePtr.data = comb2XMPtr.data + comb2Gain * comb2ReadPtr.data;
				comb3WritePtr.data = comb3XMPtr.data + comb3Gain * comb3ReadPtr.data;
				comb4WritePtr.data = comb4XMPtr.data + comb4Gain * comb4ReadPtr.data;
				inputWritePtr.data = p_seq[i];
				// write buffer
				buffer[i] = ap2XWritePtr.data;
				// advace
				ap1XReadPtr = ap1XReadPtr.next;
				ap1XWritePtr = ap1XWritePtr.next;
				ap1YReadPtr = ap1YReadPtr.next;
				ap1YWritePtr = ap1YWritePtr.next;
				ap2XReadPtr = ap2XReadPtr.next;
				ap2XWritePtr = ap2XWritePtr.next;
				ap2YReadPtr = ap2YReadPtr.next;
				ap2YWritePtr = ap2YWritePtr.next;
				ap3XReadPtr = ap3XReadPtr.next;
				ap3XWritePtr = ap3XWritePtr.next;
				ap3YReadPtr = ap3YReadPtr.next;
				ap3YWritePtr = ap3YWritePtr.next;
				comb1ReadPtr = comb1ReadPtr.next;
				comb2ReadPtr = comb2ReadPtr.next;
				comb3ReadPtr = comb3ReadPtr.next;
				comb4ReadPtr = comb4ReadPtr.next;
				comb1WritePtr = comb1WritePtr.next;
				comb2WritePtr = comb2WritePtr.next;
				comb3WritePtr = comb3WritePtr.next;
				comb4WritePtr = comb4WritePtr.next;
				inputWritePtr = inputWritePtr.next;
				comb1XMPtr = comb1XMPtr.next;
				comb2XMPtr = comb2XMPtr.next;
				comb3XMPtr = comb3XMPtr.next;
				comb4XMPtr = comb4XMPtr.next;
				lpfX_n0 = lpfX_n0.next;
				lpfX_n1 = lpfX_n1.next;
				lpfX_n2 = lpfX_n2.next;
				lpfY_n0 = lpfY_n0.next;
				lpfY_n1 = lpfY_n1.next;
				lpfY_n2 = lpfY_n2.next;
			}
			// write output buffer
			var writeTarget:Vector.<Number> = clone ? buffer : p_seq;
			for (i = 0; i < bufferSize; i++) {
				writeTarget[i] = reverbStrength * buffer[i] + p_seq[i];
			}
			return writeTarget;
		}
		
		private function calcCoeffs():void {
			comb1Gain = calcCombGain(COMB1_DELAY, reverbTime);
			comb2Gain = calcCombGain(COMB2_DELAY, reverbTime);
			comb3Gain = calcCombGain(COMB3_DELAY, reverbTime);
			comb4Gain = calcCombGain(COMB4_DELAY, reverbTime);
			ap1Gain = 0.7;
			ap2Gain = 0.7;
			ap3Gain = 0.7;
			
			var w0:Number = 2 * Math.PI * (COMB1_DELAY + COMB2_DELAY + COMB3_DELAY + COMB4_DELAY) / 4 / 44100;
			var alpha:Number = Math.sin(w0) * 0.5 / lpfQ;
			var a0:Number = 1.0 + alpha;
			lpfB00 = lpfB20 = (0.5 - 0.5 * Math.cos(w0)) / a0;
			lpfB10 = (1.0 - Math.cos(w0)) / a0;
			lpfA10 = (-2.0 * Math.cos(w0)) / a0;
			lpfA20 = (1.0 - alpha) / a0;
		}
		
		private static const INV_FS:Number = 1.0 / 44100.0;
		private function calcCombGain(delayInSamples:int, t60:Number):Number {
			return Math.pow(10, -3.0 * delayInSamples * INV_FS / t60);
		}
		
		
	}

}
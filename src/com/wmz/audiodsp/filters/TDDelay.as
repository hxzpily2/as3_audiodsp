package com.wmz.audiodsp.filters 
{
	import com.wmz.audiodsp.data.IntRing;
	import com.wmz.audiodsp.data.IntRingNode;
	/**
	 * ...
	 * @author morriswmz
	 */
	public class TDDelay implements ITimeDomainFilter 
	{
		// buffers
		private var ringBuffer:Vector.<Number>;
		private var buffer:Vector.<Number>;
		private var bufferSize:int;
		private var maxIndex:int;
		private var rdPtr:int;
		private var wrPtr:int;
		
		// triangle lfo
		private var lfoTable:IntRing;
		private var lfoCounter:Number;
		private var lfoStep:Number;
		private var lfoPtr:IntRingNode;
		private var lfoEnabled:Boolean;
		private var lfoF:Number;
		private var lfoM:Number;
		
		public function TDDelay(delay:int, bSize:int, lfoFreq:Number = 0.0, lfoFactor:Number = 0.0) 
		{
			if (lfoM > bSize + 1) throw new Error('LFO factor too large.');
			lfoF = lfoFreq;
			lfoM = lfoFactor;
			bufferSize = bSize;
			maxIndex = Math.max(bufferSize, delay) * 3; // ensure ring buffer is large enough
			ringBuffer = new Vector.<Number>(maxIndex);
			buffer = new Vector.<Number>(bufferSize);
			rdPtr = 0;
			wrPtr = delay;
			initLfo();
		}
		
		public function reset():void {
			// @todo
		}
		
		public function apply(p_seq:Vector.<Number>, clone:Boolean = false):Vector.<Number> {
			if (p_seq.length != bufferSize) throw new Error('Buffer size mismatch.');
			var endPtr:int;
			var i:int, j:int;
			// write new samples
			endPtr = wrPtr + bufferSize;
			if (endPtr > maxIndex) {
				endPtr -= maxIndex;
				j = 0;
				for (i = wrPtr; i < maxIndex; i++, j++) {
					ringBuffer[i] = p_seq[j];
				}
				for (i = 0; i < endPtr; i++, j++) {
					ringBuffer[i] = p_seq[j];
				}
			} else {
				j = 0;
				for (i = wrPtr; i < endPtr; i++, j++) {
					ringBuffer[i] = p_seq[j];
				}
			}
			wrPtr = endPtr;
			// read delayed samples
			var writeTarget:Vector.<Number> = clone ? buffer : p_seq;
			if (lfoEnabled) {
				for (i = 0; i < bufferSize; i++) {
					lfoCounter += lfoStep;
					if (lfoCounter > 1.0) {
						lfoCounter -= 1.0;
						lfoPtr = lfoPtr.next;
					}
					j = (rdPtr + lfoPtr.data + i);
					if (j >= maxIndex) {
						j -= maxIndex;
					}
					writeTarget[i] = ringBuffer[j];
				}
				rdPtr += bufferSize;
				if (rdPtr >= maxIndex) rdPtr -= maxIndex;
			} else {
				// no lfo, simple
				endPtr = rdPtr + bufferSize;
				if (endPtr > maxIndex) {
					endPtr -= maxIndex;
					j = 0;
					for (i = rdPtr; i < maxIndex; i++, j++) {
						writeTarget[j] = ringBuffer[i];
					}
					for (i = 0; i < endPtr; i++, j++) {
						writeTarget[j] = ringBuffer[i];
					}
				} else {
					j = 0;
					for (i = rdPtr; i < endPtr; i++, j++) {
						writeTarget[j] = ringBuffer[i];
					}
				}
				rdPtr = endPtr;
			}
			
			if (clone) {
				return buffer;
			} else {
				return null;
			}
		}
		
		private function initLfo():void {
			var i:int, n:int;
			if (lfoF == 0.0 || lfoM == 0.0) {
				lfoEnabled = false;
			} else {
				lfoEnabled = true;
				if (lfoTable) lfoTable.dispose();
				lfoTable = new IntRing();
				n = lfoM << 1;
				lfoCounter = 0.0;
				lfoStep = n * lfoF / 44100; 
				for (i = 0; i < lfoM; i++) lfoTable.insert(i);
				for (; i < n; i++) lfoTable.insert(n - i);
				lfoPtr = lfoTable.head;
			}
		}
	}

}
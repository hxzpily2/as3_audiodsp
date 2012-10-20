package com.wmz.audiodsp.filters 
{
	import com.wmz.audiodsp.data.NumberRing;
	import com.wmz.audiodsp.data.NumberRingNode;
	/**
	 * ...
	 * @author morriswmz
	 */
	public class TDFDNReverb 
	{
		private static const DELAY1:int = 1423;
		private static const DELAY2:int = 1543;
		private static const DELAY3:int = 1607;
		private static const DELAY4:int = 1873;
		private static const DELAY5:int = 2083;
		private static const DELAY6:int = 2399;
		private static const DELAY:Vector.<int> = new <int>[
			1019,
			1049,
			1123,
			1249,
			1321,
			1429
		];
		
		private static const DIM:int = 4;
		
		private var b:Vector.<Number>;
		
		private var G:Array = [
			[0.6667, -0.3333, -0.3333, -0.3333, -0.3333, -0.3333],
			[-0.3333, 0.6667, -0.3333, -0.3333, -0.3333, -0.3333],
			[-0.3333, -0.3333, 0.6667, -0.3333, -0.3333, -0.3333],
			[-0.3333, -0.3333, -0.3333, 0.6667, -0.3333, -0.3333],
			[-0.3333, -0.3333, -0.3333, -0.3333, 0.6667, -0.3333],
			[-0.3333, -0.3333, -0.3333, -0.3333, -0.3333, 0.6667]
		];
		private var g11:Number = 0.0;
		private var g12:Number = 0.0;
		private var g13:Number = 0.0;
		private var g14:Number = 0.0;
		private var g15:Number = 0.0;
		private var g16:Number = 0.0;
		
		private var g21:Number = 0.0;
		private var g22:Number = 0.0;
		private var g23:Number = 0.0;
		private var g24:Number = 0.0;
		private var g25:Number = 0.0;
		private var g26:Number = 0.0;
		
		private var g31:Number = 0.0;
		private var g32:Number = 0.0;
		private var g33:Number = 0.0;
		private var g34:Number = 0.0;
		private var g35:Number = 0.0;
		private var g36:Number = 0.0;
		
		private var g41:Number = 0.0;
		private var g42:Number = 0.0;
		private var g43:Number = 0.0;
		private var g44:Number = 0.0;
		private var g45:Number = 0.0;
		private var g46:Number = 0.0;
		
		private var g51:Number = 0.0;
		private var g52:Number = 0.0;
		private var g53:Number = 0.0;
		private var g54:Number = 0.0;
		private var g55:Number = 0.0;
		private var g56:Number = 0.0;
		
		private var g61:Number = 0.0;
		private var g62:Number = 0.0;
		private var g63:Number = 0.0;
		private var g64:Number = 0.0;
		private var g65:Number = 0.0;
		private var g66:Number = 0.0;
		private var g:Vector.<Vector.<Number>>;
		
		private var delayLine1:NumberRing;
		private var delayLine2:NumberRing;
		private var delayLine3:NumberRing;
		private var delayLine4:NumberRing;
		private var delayLine5:NumberRing;
		private var delayLine6:NumberRing;
		private var d1RPtr:NumberRingNode;
		private var d1WPtr:NumberRingNode;
		private var d2RPtr:NumberRingNode;
		private var d2WPtr:NumberRingNode;
		private var d3RPtr:NumberRingNode;
		private var d3WPtr:NumberRingNode;
		private var d4RPtr:NumberRingNode;
		private var d4WPtr:NumberRingNode;
		private var d5RPtr:NumberRingNode;
		private var d5WPtr:NumberRingNode;
		private var d6RPtr:NumberRingNode;
		private var d6WPtr:NumberRingNode;
		private var delayLines:Vector.<NumberRing>;
		private var dRPtrs:Vector.<NumberRingNode>;
		private var dWPtrs:Vector.<NumberRingNode>;
		
		private var reverbTime:Number;
		private var reverbStrength:Number;
		private var bufferSize:int;
		private var buffer:Vector.<Number>;
		
		private var b1:Number;
		private var b2:Number;
		private var b3:Number;
		private var b4:Number;
		private var b5:Number;
		private var b6:Number;

		
		public function TDFDNReverb(Tr:Number, strength:Number, bSize:int) 
		{
			reverbTime = Tr;
			reverbStrength = strength;
			bufferSize = bSize;
			init();
		}
		
		public function reset():void {
			
		}
		
		public function get strength():Number {
			return reverbStrength;
		}
		
		public function set strength(p_strength:Number):void {
			reverbStrength = p_strength;
		}
		
		public function apply(p_seq:Vector.<Number>, clone:Boolean = false):Vector.<Number> {
			var i:int, j:int, k:int;
			var cur:Number, out:Number;
			var writeTarget:Vector.<Number> = clone ? buffer : p_seq;
			
			for (i = 0; i < bufferSize; i++) {
				cur = p_seq[i];
				//out = 0.0;
				//for (k = 0; k < DIM; k++) {
					//out += dRPtrs[k].data;
				//}
				//out = out * reverbStrength + cur;
				//for (j = 0; j < DIM; j++) {
					//dWPtrs[j].data = cur * b[j];
					//for (k = 0; k < DIM; k++) {
						//dWPtrs[j].data += g[j][k] * dRPtrs[k].data;
					//}
					//dRPtrs[j] = dRPtrs[j].next;
					//dWPtrs[j] = dWPtrs[j].next;
				//}
				writeTarget[i] = (d1RPtr.data + d2RPtr.data + d3RPtr.data + d4RPtr.data + d5RPtr.data + d6RPtr.data) * reverbStrength + cur;
				d1WPtr.data = cur * b1 + g11 * d1RPtr.data + g12 * d2RPtr.data + g13 * d3RPtr.data + g14 * d4RPtr.data + g15 * d5RPtr.data + g16 * d6RPtr.data;
				d2WPtr.data = cur * b2 + g21 * d1RPtr.data + g22 * d2RPtr.data + g23 * d3RPtr.data + g24 * d4RPtr.data + g25 * d5RPtr.data + g26 * d6RPtr.data;
				d3WPtr.data = cur * b3 + g31 * d1RPtr.data + g32 * d2RPtr.data + g33 * d3RPtr.data + g34 * d4RPtr.data + g35 * d5RPtr.data + g36 * d6RPtr.data;
				d4WPtr.data = cur * b4 + g41 * d1RPtr.data + g42 * d2RPtr.data + g43 * d3RPtr.data + g44 * d4RPtr.data + g45 * d5RPtr.data + g46 * d6RPtr.data;
				d5WPtr.data = cur * b4 + g51 * d1RPtr.data + g52 * d2RPtr.data + g53 * d3RPtr.data + g54 * d4RPtr.data + g55 * d5RPtr.data + g56 * d6RPtr.data;
				d6WPtr.data = cur * b4 + g61 * d1RPtr.data + g62 * d2RPtr.data + g63 * d3RPtr.data + g64 * d4RPtr.data + g65 * d5RPtr.data + g66 * d6RPtr.data;
				d1RPtr = d1RPtr.next;
				d2RPtr = d2RPtr.next;
				d3RPtr = d3RPtr.next;
				d4RPtr = d4RPtr.next;
				d5RPtr = d5RPtr.next;
				d6RPtr = d6RPtr.next;
				d1WPtr = d1WPtr.next;
				d2WPtr = d2WPtr.next;
				d3WPtr = d3WPtr.next;
				d4WPtr = d4WPtr.next;
				d5WPtr = d5WPtr.next;
				d6WPtr = d6WPtr.next;
			}
			
			return clone ? writeTarget : null;
			
		}
		private static const INV_FS:Number = 1.0 / 44100.0;
		private function init():void {
			var i:int;
			var avgDelay:int = 0;
			// init G matrix
			
			//calcGMatrix(DIM, Math.pow(10, -3.0 * avgDelay * INV_FS / reverbTime));
			
			// coeffs
			//b = new Vector.<Number>();
			//for (i = 0; i < DIM; i++) {
				//b[i] = 1.0 / DIM * Math.exp( - Number(i) / Number(DIM));
			//}
			b1 = 0.3;
			b2 = 0.2;
			b3 = 0.15;
			b4 = 0.15;
			b5 = 0.1;
			b6 = 0.1;
			avgDelay = (DELAY1 + DELAY2 + DELAY3 +DELAY4 + DELAY5 + DELAY6) / 6;
			var loss:Number = Math.pow(10, -3.0 * avgDelay * INV_FS / reverbTime);
			
			g11 = G[0][0] * loss;
			g12 = G[0][1] * loss;
			g13 = G[0][2] * loss;
			g14 = G[0][3] * loss;
			g15 = G[0][4] * loss;
			g16 = G[0][5] * loss;
			
			g21 = G[1][0] * loss;
			g22 = G[1][1] * loss;
			g23 = G[1][2] * loss;
			g24 = G[1][3] * loss;
			g25 = G[1][4] * loss;
			g26 = G[1][5] * loss;
			
			g31 = G[2][0] * loss;
			g32 = G[2][1] * loss;
			g33 = G[2][2] * loss;
			g34 = G[2][3] * loss;
			g35 = G[2][4] * loss;
			g36 = G[2][5] * loss;
			
			g41 = G[3][0] * loss;
			g42 = G[3][1] * loss;
			g43 = G[3][2] * loss;
			g44 = G[3][3] * loss;
			g45 = G[3][4] * loss;
			g46 = G[3][5] * loss;
			
			g51 = G[4][0] * loss;
			g52 = G[4][1] * loss;
			g53 = G[4][2] * loss;
			g54 = G[4][3] * loss;
			g55 = G[4][4] * loss;
			g56 = G[4][5] * loss;
			
			g61 = G[5][0] * loss;
			g62 = G[5][1] * loss;
			g63 = G[5][2] * loss;
			g64 = G[5][3] * loss;
			g65 = G[5][4] * loss;
			g66 = G[5][5] * loss;
			// rings
			//var j:int;
			//delayLines = new Vector.<NumberRing>();
			//dWPtrs = new Vector.<NumberRingNode>();
			//dRPtrs = new Vector.<NumberRingNode>();
			//for (i = 0; i < DIM; i++) {
				//delayLines[i] = new NumberRing();
				//for (j = 0; j < DELAY[i] + bufferSize + 1; j++) { delayLines[i].insert(0); }
				//dWPtrs[i] = delayLines[i].seek(DELAY[i]);
				//dRPtrs[i] = delayLines[i].head;
			//}
			
			delayLine1 = new NumberRing();
			for (i = 0; i < DELAY1 + bufferSize + 1; i++) { delayLine1.insert(0); }
			d1WPtr = delayLine1.seek(DELAY1);
			d1RPtr = delayLine1.head;
			
			delayLine2 = new NumberRing();
			for (i = 0; i < DELAY2 + bufferSize + 1; i++) { delayLine2.insert(0); }
			d2WPtr = delayLine2.seek(DELAY2);
			d2RPtr = delayLine2.head;
			
			delayLine3 = new NumberRing();
			for (i = 0; i < DELAY3 + bufferSize + 1; i++) { delayLine3.insert(0); }
			d3WPtr = delayLine3.seek(DELAY3);
			d3RPtr = delayLine3.head;
			
			delayLine4 = new NumberRing();
			for (i = 0; i < DELAY4 + bufferSize + 1; i++) { delayLine4.insert(0); }
			d4WPtr = delayLine4.seek(DELAY4);
			d4RPtr = delayLine4.head;
			
			delayLine5 = new NumberRing();
			for (i = 0; i < DELAY5 + bufferSize + 1; i++) { delayLine5.insert(0); }
			d5WPtr = delayLine5.seek(DELAY5);
			d5RPtr = delayLine5.head;
			
			delayLine6 = new NumberRing();
			for (i = 0; i < DELAY6 + bufferSize + 1; i++) { delayLine6.insert(0); }
			d6WPtr = delayLine6.seek(DELAY6);
			d6RPtr = delayLine6.head;
			
		}
		
		private function calcGMatrix(dim:int, loss:Number):void {
			var i:int, j:int;
			g = new Vector.<Vector.<Number>>();
			for (i = 0; i < dim; i++) {
				g[i] = new Vector.<Number>();
				for (j = 0; j < dim; j++) {
					if (i == j) {
						g[i][j] = loss * (1.0 - 2.0 / dim);
					} else {
						g[i][j] = - loss * 2.0 / dim;
					}
				}
			}
		}
		
	}

}
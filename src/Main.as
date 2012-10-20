package 
{
	import com.wmz.audiodsp.data.SampleDataList;
	import com.wmz.audiodsp.filters.FreqShifter;
	import com.wmz.audiodsp.filters.TDDelay;
	import com.wmz.audiodsp.filters.TDEqualizer;
	import com.wmz.audiodsp.math.FFT;
	import com.wmz.audiodsp.math.FFTResult;
	import com.wmz.audiodsp.math.WindowFunc;
	import com.wmz.audiodsp.ui.ProgressBar;
	import com.wmz.audiodsp.ui.SpectrumGraph;
	import com.wmz.audiodsp.ui.SpectrumMap;
	import com.wmz.audiodsp.ui.WaveGraph;
	import flash.display.Sprite;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import org.audiofx.mp3.MP3FileReferenceLoader;
	import org.audiofx.mp3.MP3SoundEvent;
	
	/**
	 * ...
	 * @author morriswmz
	 */
	public class Main extends Sprite 
	{
		private var microphone:Microphone;
		private var mp3Sound:Sound;
		private var mp3Position:int;
		private var player:Sound;
		private var playerChannel:SoundChannel;
		private var fileBrowser:FileReference;
		private var fileFilter:FileFilter;
		private var mp3loader:MP3FileReferenceLoader;
		
		private var inputBuffer:Vector.<Number>;
		private var outputBuffer:Vector.<Number>;
		private var outputBufferL:Vector.<Number>;
		private var outputBufferR:Vector.<Number>;
		private var testBuffer:Vector.<Number>;
		private var filterCoeff:Vector.<Number>;
		private var bufferOK:Boolean;
		private var playingOK:Boolean;
		
		private var eqL:TDEqualizer;
		private var eqR:TDEqualizer;
		private var delayL:TDDelay;
		private var delayR:TDDelay;
		
		private var windowFunc:WindowFunc;
		private var fftResultL:FFTResult;
		private var fftResultR:FFTResult;
		private var spectrumDisplayL:SpectrumGraph;
		private var spectrumDisplayR:SpectrumGraph;
		private var waveDisplayL:WaveGraph;
		private var waveDisplayR:WaveGraph;
		private var spectrumMapL:SpectrumMap;
		private var spectrumMapR:SpectrumMap;
		private var progressBar:ProgressBar;
		
		
		private var dFFTTime:Number = 0;
		private var dLastTime:Number = 0;
		private var dFFTCount:Number = 0;
		private var dFrameCount:Number = 0;
		private var dFPS:Number;
		private var dMaxFPS:Number;
		private var textFormat:TextFormat;
		private var FPSDisplay:TextField;
		private var FFTTimeDisplay:TextField;
		private var statusText:String;
		
		private static const BUFFER_SIZE:int = 2048;
		private static const SAFE_BUFFER_SIZE:int = 1025;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			var i:int;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			// init
			inputBuffer = new Vector.<Number>();
			outputBuffer = new Vector.<Number>(BUFFER_SIZE);
			outputBufferL = new Vector.<Number>(BUFFER_SIZE);
			outputBufferR = new Vector.<Number>(BUFFER_SIZE);
			testBuffer = new Vector.<Number>();
			bufferOK = false;
			for (i = 0; i < BUFFER_SIZE; i++) {
				outputBuffer[i] = 0.0;
				outputBufferL[i] = 0.0;
				outputBufferR[i] = 0.0;
			}
			windowFunc = new WindowFunc(WindowFunc.W_BLACKMAN, BUFFER_SIZE);
			// setup microphone
			// trace(Microphone.names);
			//microphone = Microphone.getMicrophone();
			//microphone.setSilenceLevel(0);
			//microphone.rate = 44;
			//microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, microphoneSampleEventHandler);
			
			// setup mp3 player
			mp3Sound = new Sound();
			mp3Position = 0;
			fileBrowser = new FileReference();
			mp3loader = new MP3FileReferenceLoader();
			fileFilter = new FileFilter('mp3 files', '*.mp3');
			// setup player
			player = new Sound();
			player.addEventListener(SampleDataEvent.SAMPLE_DATA, playerSampleEventHandler);
			
			// setup spectrum display
			//spectrumDisplay = new SpectrumGraph(10, 70, 280, 120, BUFFER_SIZE/2);
			//addChild(spectrumDisplay);
			waveDisplayL = new WaveGraph(90, 10, 200, 40);
			waveDisplayR = new WaveGraph(90, 50, 200, 40);
			addChild(waveDisplayL);
			addChild(waveDisplayR);
			spectrumMapL = new SpectrumMap(10, 100, 280, 45);
			spectrumMapR = new SpectrumMap(10, 145, 280, 45);
			addChild(spectrumMapL);
			addChild(spectrumMapR);
			progressBar = new ProgressBar(12, 55, 60, 4);
			addChild(progressBar);
			
			textFormat = new TextFormat('Arial', 10, 0xffffff);
			FPSDisplay = new TextField();
			FPSDisplay.text = 'FPS:';
			FPSDisplay.setTextFormat(textFormat);
			FPSDisplay.x = 10;
			FPSDisplay.y = 20;
			FPSDisplay.width = 70;
			FPSDisplay.height = 20;
			addChild(FPSDisplay);
			FFTTimeDisplay = new TextField();
			FPSDisplay.text = '';
			FPSDisplay.setTextFormat(textFormat);
			FFTTimeDisplay.x = 10;
			FFTTimeDisplay.y = 35;
			FFTTimeDisplay.width = 70;
			FFTTimeDisplay.height = 20;
			addChild(FFTTimeDisplay);
			statusText = 'Click Below'
			
			dMaxFPS = this.stage.frameRate;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			dLastTime = getTimer();
			// init filter
			//filterCoeff = new Vector.<Number>(BUFFER_SIZE);
			//for (i = 0; i < BUFFER_SIZE / 2; i++) {
				//filterCoeff[i] = 1 - Math.exp(-i*i/1000000);
				//filterCoeff[BUFFER_SIZE-i - 1] = filterCoeff[i];
			//}
			
			// filters
			eqL = new TDEqualizer();
			eqR = new TDEqualizer();
			delayL = new TDDelay(1024, BUFFER_SIZE, 0.01, 100);
			delayR = new TDDelay(1024, BUFFER_SIZE, 0.09, 100);
			
			this.doubleClickEnabled = true;
			this.mouseEnabled = true;
			this.addEventListener(MouseEvent.CLICK, doubleClickHandler);
			this.graphics.moveTo(0, 0);
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, this.stage.width, this.stage.height);
			this.graphics.endFill();
			
			//playerChannel = player.play();
		}
		
		private function benchMark(e:Event):void {
			// benchmark
			var _n:int, _m:int, _t:int, i:int;
			var _buffer:Vector.<Number> = new Vector.<Number>();
			var ptrs:int = 256;
			var ptre:int = 700;
			var buffersize:int = 512;
			for (i = 0; i < buffersize; i++) {
				_buffer[i] = 0;
			}
			_t = getTimer();
			
			for (_n = 0; _n < 1000; _n++) {
				for (_m = 0; _m < 8; _m++) {
					for (i = ptrs; i < ptre; i++) {
						_buffer[i%buffersize] = Math.random();
					}
				}
			}
			trace(getTimer() - _t);
			_t = getTimer();
			var ptr:int;
			for (_n = 0; _n < 1000; _n++) {
				for (_m = 0; _m < 8; _m++) {
					if (ptre > buffersize) {
						ptr = ptre - buffersize;
						for (i = ptrs; i < buffersize; i++) {
							_buffer[i] = Math.random();
						}
						for (i = 0; i < ptr; i++) {
							_buffer[i] = Math.random();
						}
					} else {
						
					}
				}
			}
			trace(getTimer() - _t);
		}
		
		private function doubleClickHandler(e:Event):void {
			fileBrowser.browse([fileFilter]);
			fileBrowser.addEventListener(Event.SELECT, fileSelectHandler);
		}
		
		private function fileSelectHandler(e:Event):void {
			statusText = 'Loading';
			mp3loader.getSound(fileBrowser);
			if (playerChannel) playerChannel.stop();
			mp3loader.addEventListener(MP3SoundEvent.COMPLETE, mp3LoadedHandler);
		}
		
		private function mp3LoadedHandler(e:MP3SoundEvent):void {
			mp3Sound = e.sound;
			mp3Position = 0;
			playerChannel = player.play();
		}
		
		private function mp3LoadCompleteHandler(e:Event):void {
			playerChannel = player.play();
		}
		
		private function enterFrameHandler(e:Event):void {
			if (outputBuffer) {
				
			}
			dFrameCount++;
			if (dFrameCount > 100) {
				dFPS = 1000 * dFrameCount / (getTimer() - dLastTime);
				dLastTime = getTimer();
				dFrameCount = 0;
			}
			FPSDisplay.text = 'FPS:' + int(dFPS) + '/' + int(dMaxFPS);
			FFTTimeDisplay.text = statusText;
			FPSDisplay.setTextFormat(textFormat);
			FFTTimeDisplay.setTextFormat(textFormat);
		}
		
		private function microphoneSampleEventHandler(e:SampleDataEvent):void {
			var n:int = e.data.bytesAvailable / 4;
			for (var i:int = 0; i < n; i++)
				inputBuffer.push(e.data.readFloat());
			if (!bufferOK && inputBuffer.length > SAFE_BUFFER_SIZE) {
				bufferOK = true;
			}
			if (inputBuffer.length < SAFE_BUFFER_SIZE) {
				bufferOK = false;
			}
			if (inputBuffer.length > BUFFER_SIZE) {
				//outputBuffer = inputBuffer.splice(0, BUFFER_SIZE);
				//fftResult = FFT.compute(outputBuffer);
			}
		}
		
		private var sinePhase:Number = 0;
		private var sinePhaseDelta:Number = 880 * 2 * Math.PI / 44100;
		private var sineModPhase:Number = 0;
		private var sineModFreq:Number = 440;
		private var sineModPhaseDelta:Number = 440 * 2 * Math.PI / 44100;
		private var sineModFactor:Number = 440;
		
		private var phaseShiftDelta:Number = 75 * 2 * Math.PI / 44100;
		private var phaseShift:Number = 0;
		
		private var delayBufferL:Vector.<Number> = new Vector.<Number>();
		private var delayBufferR:Vector.<Number> = new Vector.<Number>();
		private var delayCount:int = 2048;
		private var delayFeedback:Number = 0.6;
		
		private var lfoPhaseDelta:Number = 0.1 * 2 * Math.PI / 44100;
		private var lfoPhase:Number = 0;
		private var lfoM:Number = 512;
		
		private function playerSampleEventHandler(e:SampleDataEvent):void {
			var i:int;
			var n:int = inputBuffer.length;
			// create output buffer
			//if (bufferOK) {
				//if (n < BUFFER_SIZE) {
					//for (i = 0; i < n; i++)
						//outputBuffer[i] = 2 * inputBuffer[i];
					//for (; i < BUFFER_SIZE; i++)
						//outputBuffer[i] = 0.0;
					//inputBuffer.splice(0, n);
					//trace('WARN: Buffer underflow!');
				//} else {
					//for (i = 0; i < BUFFER_SIZE; i++)
						//outputBuffer[i] = 2 * inputBuffer[i];
					//inputBuffer.splice(0, BUFFER_SIZE);
				//}
			//} else {
				//for (i = 0; i < BUFFER_SIZE; i++)
					//outputBuffer[i] = 0.0;
			//}
			statusText = 'Playing';
			var rawData:ByteArray = new ByteArray();
			mp3Sound.extract(rawData, BUFFER_SIZE, mp3Position);
			rawData.position = 0;
			if (rawData.bytesAvailable >= BUFFER_SIZE * 8) {
				mp3Position += BUFFER_SIZE;
				for (i = 0; i < BUFFER_SIZE; i++) {
					outputBufferL[i] = rawData.readFloat();
					//outputBufferL[i] = 0;
					outputBufferR[i] = rawData.readFloat();
				}
			} else {
				trace('end!');
				mp3Position = 0;
				for (i = 0; rawData.bytesAvailable > 8; i++) {
					outputBufferL[i] = rawData.readFloat();
					//outputBufferL[i] = 0;
					outputBufferR[i] = rawData.readFloat();
				}
				for (; i < BUFFER_SIZE; i++) {
					outputBufferL[i] = 0.0;
					outputBufferR[i] = 0.0;
				}
			}
			//for (i = 0; i < BUFFER_SIZE; i++) {
				//sinePhase += sinePhaseDelta;
				//sineModPhase += sineModPhaseDelta;
				//outputBuffer[i] = Math.sin(sinePhase + sineModFactor / sineModFreq * Math.sin(sineModPhase)) * 0.8;
			//}
			delayL.apply(outputBufferL);
			delayR.apply(outputBufferR);
			eqL.apply(outputBufferL);
			eqR.apply(outputBufferR);
			fftResultL = FFT.computeTable(windowFunc.apply(outputBufferL, true));
			fftResultR = FFT.computeTable(windowFunc.apply(outputBufferR, true));
			//fftResultL = FFT.computeTable(outputBufferL);
			//fftResultR = FFT.computeTable(outputBufferR);
			waveDisplayL.render(outputBufferL, 16);
			waveDisplayR.render(outputBufferR, 16);
			//spectrumDisplay.render(fftResult);
			spectrumMapL.render(fftResultL);
			spectrumMapR.render(fftResultR);
			progressBar.render(mp3Position / mp3Sound.length / 44.100);
			
			// lowpass filter
			//for (i = 0; i < BUFFER_SIZE; i++) {
				//fftResult.re[i] *= filterCoeff[i];
				//fftResult.im[i] *= filterCoeff[i];
			//}
			//var processedBuffer:Vector.<Number> = FFT.compute(fftResult.re, fftResult.im, false).re;
			var curSampleL:Number;
			var curSampleR:Number;
			
			// write to player buffer
			for (i = 0; i < BUFFER_SIZE; i++) {
				curSampleL = outputBufferL[i];
				curSampleR = outputBufferR[i];
				//phaseShift += phaseShiftDelta * Math.sin(lfoPhase * 0.4);
				//lfoPhase += lfoPhaseDelta;
				//
				//if (delayBufferL.length > delayCount) {
					//delayBufferL.shift();
					//delayBufferR.shift();
					//curSampleL = curSampleL + delayBufferL[int(lfoM * (1 + Math.sin(lfoPhase)))] * delayFeedback;
					//curSampleR = curSampleR + delayBufferR[int(lfoM * (1 + Math.sin(lfoPhase)))] * delayFeedback;
				//}
				//delayBufferL.push(curSampleL);
				//delayBufferR.push(curSampleR);
				
				//curSample = curSample * (0.1 + 0.9 * Math.sin(phaseShift));
				e.data.writeFloat(curSampleL);
				e.data.writeFloat(curSampleR);
			}
			
		}
		
	}
	
}
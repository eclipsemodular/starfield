s.boot;

~sampPath = "Q:/1 SkyeData/1 Projects/Timeless/hgExtra/samples/vocoder.wav";

~sampBuffer = Buffer.readChannel(s, ~sampPath,channels:[0],bufnum:1010);



(
SynthDef(\sampler, {
	arg sampBuffer, cpsPitch = 440, paramX = 0.75, paramY = 0, paramZ = 1, isLoop = 1;
	var sig, rate, start, duration, ratioPitch, frames, loopStart, loopLength, loopRate, activePos, activePhase;


	rate = (paramX-0.5)*4;
	start = paramY;
	duration = paramZ**3;
	ratioPitch = rate * (2**((cpsPitch.cpsmidi / 12) - 5));


	//prevents overflow or underflow
	duration = duration.clip(0.001,1);
	//convert positional args to samples
	frames = BufFrames.kr(sampBuffer);

	deltaTrig = Changed.ar(LeakDC.ar(start.asAudioRateInput),0);
	deltaTrig = Trig1.ar(deltaTrig,0.25);
	deltaTrig = deltaTrig * (0-1) + 1;
	deltaTrig.poll(20,deltaTrig);

	loopStart = start * frames;
	loopLength = duration * frames;
	loopLength = loopLength.clip(128,loopLength+20);

	//positive rate is forward playback, negative is reversed. +-1 is initial speed
	loopRate = BufRateScale.kr(sampBuffer) * (ratioPitch);
	//Positional driver
	activePos = Phasor.ar(trig, loopRate, 0, loopLength);

	activePhase = Wrap.ar(activePos,0, frames)

	sig = BufRd.ar(1, sampBuffer, activePhase,isLoop,3);

}).add;
)
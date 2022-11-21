p = ProxySpace.push.quant_(1).
p.fadeTime_(8).reshaping_(\elastic)

~tra[0] = { SinOscFB.ar(130 * [1,1.01], 1) * \amp.kr(0.2) }; ~tra.play

~tra.xset(\amp, 0.1); ~org.xset(\amp, 0.1); ~fourses.xset(\amp, 0)

~freq = {|freq=130| freq } ~freq[10] = \set -> Pbind( \freq, Pbrown(15.midicps, 16.midicps), \dur, 0.1 )

~org[0] = { Splay.ar( SinOsc.ar( ~freq/2 * Array.geom(2,1,2), mul: \amp.kr(0.2) ))}; ~org.play

~string.stop
s.record
~string.play; ~sfreq = ~freq/0.25 ; ~trig = {Dust2.kr(0.2)}; ~string[0] = {StringVoice.ar( ~trig!2, infsustain: 0, freq: ~sfreq, accent: TRand.kr(0.0,1.0, ~trig), structure: TRand.kr(0.0,1.0, ~trig), brightness: TRand.kr(0.0,0.15, ~trig), damping: TRand.kr(0.1,0.7, ~trig))}; 

~fourses.stop

~fourses.play;
~fourses[0] = { Splay.ar (LeakDC.ar(VBFourses.ar(LFNoise0.ar([4, 3, 2, 1, 1, 2, 3, 4]).range(1,1200), 0.7)) * \amp.kr(0.3) ) * LFClipNoise.kr( BrownNoise.kr().range(1,16), 1).range(0,1)};

~chaos.stop;

~chaos={SinOsc.ar([260, 261], mul: ChaosGen.allSubclasses.choose.ar(rrand(1, 30))* 0.23)}; ~chaos.play;
~chaos[10] = \filter -> {|in| Vocoder.ar( in * 4, ~clarinete * 4, 6, low: 100, high: 5000, q: 0.02, hpf: 2500, hpfscal: 0.05, outscal: 25) * 4 }
~chaos.fadeTime = 2
~clarinete.release(4)

~clarinete[0] = {|att=0.2| var env = Env.asr(att,1,0.2,1).ar(0,1,\sustain.kr(1) ); DWGClarinet3.ar(Lag.kr(\freq.kr(40.midicps).lag(0.02) * [1,1.01],0) * SinOsc.kr(8,0,0.001,1),pm: env, gate:1, pc:LFCub.kr(0.1).range(0.8,1), m:LFCub.kr(1).range(1.2,2), release: Dust.kr(0.25), c1:0.2, c3:7) * \amp.kr(1)}; ~clarinete.play
~clarinete.fadeTime = 4
~clarinete[1] = \xset -> Pbind(\degree, Prand( (-6..0)*3,inf), \dur, Prand([1,0.5,0.25],inf)*4 )


~klang.play;
~klang.stop;
~klang[0] = { Klang.ar({`[ Array.rand(12, 600.0, 1000.0), nil, nil ]}!2, 1, 0) * 0.05 };

Server.default.options.numWireBufs = 1024;

(
{
	var voicedCarrier;
	var snd, numBands, bandFreqs, carrier;
	numBands = 32;
	bandFreqs = (0..numBands - 1).linexp(0, numBands - 1, 100, 8000);
	snd = PlayBuf.ar(1, ~buffer, BufRateScale.kr(~buffer));
	voicedCarrier = Saw.ar((60 + [0, 3, 7]).midicps);
	carrier = SelectX.ar((ZeroCrossing.ar(snd).cpsmidi.lag(0.05) > 5000.cpsmidi).lag(0.05), [voicedCarrier, PinkNoise.ar]);
	snd = Amplitude.ar(BPF.ar(snd, bandFreqs, 0.05), 0.01, 0.05);
	snd = BPF.ar(carrier, bandFreqs, 0.05) * snd;
	snd = snd.sum;
	snd = snd * 30.dbamp;
	snd = Limiter.ar(snd);
	snd ! 2;
}.play;
)

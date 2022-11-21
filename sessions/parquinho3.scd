p = ProxySpace.push.quant_(1).fadeTime_(8).reshaping_(\elastic)
n = ProxyMixer(p)
ProxyMeter.addMixer(n)
s.boot
//~freq = {|freq=130| freq } ~freq[10] = \set -> Pbind( \freq, Pbrown(15.midicps, 16.midicps), \dur, 0.1 )
~org.play; ~freq = 130;
~org[0] = { Splay.ar( SinOsc.ar( ~freq * Array.geom(2,1,2), mul: \amp.kr(0.2) ))};
~org.stop(8)
Troop.start
~string.stop(8)
~string.play; ~sfreq = ~freq/0.25 ; ~trig = {Dust2.kr(0.2)}; ~string[0] = {StringVoice.ar( ~trig!2, infsustain: 0, freq: ~sfreq, accent: TRand.kr(0.0,1.0, ~trig), structure: TRand.kr(0.0,1.0, ~trig), brightness: TRand.kr(0.0,0.15, ~trig), damping: TRand.kr(0.1,0.7, ~trig))};


~drm.play; ~drm[0] = { DiodeRingMod.ar( SinOsc.ar( 1200 * ( [1, 1.001] * SinOsc.ar(1550).range(1, 2))), 
    SinOsc.ar(130 * [0.5, 1, 0.5]).sum * 0.3 * LFPulse.ar([7/5, 9/8] * 0.35, 0, 0.04) * 0.3};

~chaos.stop(8);
~chaos.play; ~chaos={SinOsc.ar([260, 261], mul: ChaosGen.allSubclasses.choose.ar(rrand(1, 30))* 0.2)};
~chaos[10] = \filter -> {|in| Vocoder.ar( in * 4, ~clarinete * 4, 6, low: 100, high: 5000, q: 0.02, hpf: 2500, hpfscal: 0.05, outscal: 25) * 4 }

~clarinete.stop(8)
~clarinete.play; ~clarinete[0] = {|att=0.2| var env = Env.asr(att,1,0.2,1).ar(0,1,\sustain.kr(1) ); DWGClarinet3.ar(Lag.kr(\freq.kr(40.midicps).lag(0.02) * [1,1.01],0) * SinOsc.kr(8,0,0.001,1),pm: env, gate:1, pc:LFCub.kr(0.1).range(0.8,1), m:LFCub.kr(1).range(1.2,2), release: Dust.kr(0.25), c1:0.2, c3:7) * \amp.kr(0.2)};
~clarinete[10] = \xset -> Pbind(\degree, Prand( (-6..0)*3,inf), \dur, Prand([1,0.5,0.25],inf)*4 )

~tra.stop(8)
~tra.play; ~tra[0] = { SinOscFB.ar(130 * [1,1.01], 1) * \amp.kr(0.1) };

~drone.stop(8)
~freqs = ~basef *[1, 1/3, 2/3, 4/5, 2/5, 3/5, 6/5, 7/5].keep(2).scramble;
~basef = { |freq = 130 | freq * SinOsc.kr( LFBrownNoise2.ar(0.2).range(3,12) ).exprange(0.9, 1.1) };
~drone.play; ~drone[0] = {|freq = 130| Squine.ar( ~freqs, clip: SinOsc.kr(0.3, 0, 0.69, 0.85), skew: LFCub.kr(0.0002)) * 0.15 }
~drone[30] = \filter -> {|in| FreqShift.ar(in, LFCub.kr(0.002), LFCub.kr (0.01) ) }
~drone[40] = \filter -> {|in| in = in * 0.35 ; in + AdCVerb.ar(in*0.5, LFNoise2.ar(0.02).range(0.2, 2), LFNoise2.ar(0.2).range(0, 1) )}

~diode.stop(8)
~diode.play; ~diode[0] = {VADiodeFilter.ar({WhiteNoise.ar(0.525)}!2 * 0.2, freq: SinOsc.kr(LFNoise2.kr(32)).exprange(80.0,400.0), res:0.7, overdrive:0.9)}

~fourses.stop(8)
~fourses.play; ~fourses[0] = { Splay.ar (LeakDC.ar(VBFourses.ar(LFNoise0.ar([4, 3, 2, 1, 1, 2, 3, 4]).range(1,1200), 0.7)) * \amp.kr(0.3) ) * LFClipNoise.kr( BrownNoise.kr().range(1,16), 1).range(0,1)};

~klang.stop(8);
~klang.play; ~klang[0] = { Klang.ar({`[ Array.rand(12, 600.0, 1000.0), nil, nil ]}!2, 1, 0) * 0.05 };

~drm.stop(8)
~drm.play; ~drm[0] = {DiodeRingMod.ar(SinOsc.ar(520 * ([1, 1.1] * SinOsc.ar(3550).range(1, 2))), SinOsc.ar(130 * [0.75, 1, 0.5])).sum * 0.3 * LFPulse.ar([7/5, 9/8] * 0.35, 0, 0.04) * 0.3};
:SCN

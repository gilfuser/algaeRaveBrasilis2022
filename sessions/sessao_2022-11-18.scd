p = ProxySpace.push.quant_(1).fadeTime_(8).reshaping_(\elastic).know_(true);
n = ProxyMixer(p);
ProxyMeter.addMixer(n);

~org[0] = { Splay.ar( SinOsc.ar( LFSaw.ar( LFSaw.kr( LFSaw.kr(0.05).range(0.05,0.2)).range(1, LFSaw.kr(0.1).range(4,16) ) ).exprange(22, {LFNoise0.kr(0.1).exprange(55, 550)}!2 ) * Array.geom(4,1,0.5), mul: \amp.kr(0.2) ))};
~org[10] = \filter -> {|in| (in * * Decay2.ar(~lfpulse,0.1, 0.2) * 0.01 * {LFNoise2.kr(2).range(0.2,1)}!2).wrap(0,1) * \amp.kr(0.1) }
~org[20] = \filter -> {|in| LeakDC.ar(in) }

~org.play.vol_(1)

~string.stop(8)

~string.play; ~sfreq = ~freq/8; ~trig = {Dust2.kr(0.2)}; ~string = {StringVoice.ar( ~trig!2, infsustain: 0, freq: ~sfreq, accent: TRand.kr(0.0,0.005, ~trig), structure: TRand.kr(0.0,0.2, ~trig), brightness: TRand.kr(0.0,0.5, ~trig), damping: TRand.kr(0.1,0.7, ~trig))};
~string[11] = \filterIn -> { |in| Lores.ar(in, ~ffreq, 0.25) * 0.5 }
~string.set(\wet11, 0.5)
~org.stop(8);
~neo[0] = { NeoFormant.ar( ~freqs.ar.lag(0.2) * 3, Splay.ar(~freqs.ar) * 10, LFNoise2.kr(0.23).range(0,1) ) * 0.7 }
~neo.play.vol_(1)

~neo[10] = \filter -> {|in| FreqShift.ar(in, LFCub.kr(0.002), LFCub.kr (0.01) ) }
~neo[20] = \filterIn -> {|in| AdCVerb.ar(in) * 0.5}
~neo.set(\wet20, 0.25)
~neo[30] = \filter -> {|in| in * AdCVerb.ar(Decay2.ar(Dust.ar(1), 0.01, 0.25)) }
~neo[40] = \filterIn -> {|in| VADiodeFilter.ar(in, ~ffreq, LFNoise2.kr(0.2).range(0.05,0.25) ) }
~ffreq = { LFNoise0.kr(1).exprange(200, 2000).lag(0.2) }
~neo.set(\wet40, 0.5)
~chaos.stop(8)
~chaos.play; ~chaos = {SinOsc.ar( 55 * ~freqs, mul: ChaosGen.allSubclasses.choose.ar(rrand(1, 30))* 0.16)};

~chaos[10] = \filter -> {|in| Vocoder.ar( in, ~test, 6, low: 100, high: 15000, q: 0.2, hpf: 2500, hpfscal: 0.05, outscal: 2) * 4 }
~chaos[20] = \filter -> {|in| PLL.ar(in * 0.1, 1, 16, 100, 50) * 0.05 }

~clarinete.stop(8)


~clarinete.play; ~clarinete[0] = {|att=0.2| var env = Env.asr(att,1,0.2,1).ar(0,1,\sustain.kr(1) ); DWGClarinet3.ar(Lag.kr(\freq.kr(40.midicps).lag(0.02) * [1,1.01],0) * SinOsc.kr(8,0,0.001,1),pm: env, gate:1, pc:LFCub.kr(0.1).range(0.8,1), m:LFCub.kr(1).range(1.2,2), release: Dust.kr(0.25), c1:0.2, c3:7) * \amp.kr(0.12)};

~clarinete[10] = \xset -> Pbind(\degree, Prand( (-6..0)*3,inf), \dur, Prand([1,0.5,0.25],inf)*4 )

~tra.stop(8)

~tra.play; ~tra[0] = { SinOscFB.ar(50 * [1,1.1], 1) * \amp.kr(0.2) };
~tra[30] = \filter -> {|in| FreqShift.ar(in, LFCub.kr(0.02), LFCub.kr (0.1) ) }

~drone.stop(8)



Tdef(\laj, {loop{ ~freqs = ~basef *[1, 1/3, 2/3, 4/5, 2/5, 3/5, 6/5, 7/5].keep(4).scramble; 4.wait;}}).play;
Tdef(\laj).gui
~basef = { |freq = 50 | freq * SinOsc.kr( LFBrownNoise2.ar(0.2).range(3,12) ).exprange(0.9, 1.1) };

~drone.play; ~drone[0] = {|freq = 50| Squine.ar( Splay.ar(~freqs.ar), clip: SinOsc.kr(0.3, 0, 0.69, 0.85), skew: LFCub.kr(12)) * 0.21 }
~drone[30] = \filter -> {|in| FreqShift.ar(in, LFCub.kr(8), LFCub.kr (16) ) }

~drone.stop

~drone[40] = \filter -> {|in| in = in * 0.35 ; in + AdCVerb.ar(in*0.75, LFNoise2.ar(0.02).range(0.2, 2), LFNoise2.ar(0.2).range(0, 1) )}

~diode.stop(8)
~diode.play; ~diode[0] = {VADiodeFilter.ar({WhiteNoise.ar(0.25)}!2 * 0.1, freq: SinOsc.kr(LFNoise2.kr(32)).exprange(80.0,400.0), res:0.7, overdrive:0.29)}

~fourses.stop(8)
~fourses.play; ~fourses[0] = { Splay.ar (LeakDC.ar(VBFourses.ar(LFNoise0.ar([4, 3, 2, 1, 1, 2, 3, 2]).range(201,200), 0.27)) * \amp.kr(0.3) ) * LFClipNoise.kr( BrownNoise.kr().range(1,16), 1).range(0,1)};

~klang.stop(8);
~klang.play;
~klang[0] = { Klang.ar({`[ Array.rand( 2, 166.0, 1800.0), nil, nil ]}, 1, 0) * 0.0013 };

~drm.stop(8)
~lfpulse = {Splay.ar(LFPulse.ar( [7/5, 9/8, 2/3, 2/5] * LFNoise0.kr(0.5).range(0.5,2), 0, 0.04))};
~drm.play; ~drm[0] = { DiodeRingMod.ar( SinOsc.ar( ~freqs * 10 * ( [1, 1.001] * SinOsc.ar( ~freqs * 1000 ).range(1, 2) )),SinOsc.ar(130 * [0.5, 1, 0.5])).sum * 0.23 * ~lfpulse * 0.3};

(
~test = { Ringz.ar( Impulse.ar(
    SinOsc.kr(0.5, [0.25pi, 1.5pi, 0, pi] ).range(0.25, 2 ) ) * 0.2,
    LFSaw.ar([1/3, 1/8]).exprange([8800, 88], [88, 880]),
    0.02) }
)

~test.play

~test.stop
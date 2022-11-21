
Troop.start

s.boot
p = ProxySpace.push;
p.quant = 1;
s.meter

~vai = { AnalogFoldOsc.ar( (\freq.kr(110).lag3ud(1) ) * [1,1.1] ) * \amp.kr(0.2) };
~vai.stop(4)
~vai[2] = \filter -> q.fx['pitch'];
~vai[3] = \filter -> q.fx['bitcrush'];

Plugins.gui


~vai[4] = \filter -> q.fx['lpf']

~vai[5] = \set ->  Pbind ( \dur, Prand( [1,2,0.5,0.25],inf ), \test, 0.5,\beatsPerSec, Ndef(\tempo).bus.asMap, \degree, Pxrand( [-5, -2, 1, 0], inf) - 12, \amp, 0.2, \divide, Prand([1,2,3,0.5],inf) );

~vai.play;
~vai[4] = \filter -> { |in| var trig = Ndef(\click).ar; trig = PulseDivider.ar(trig, \divide.kr(2)); in * Decay2.ar( trig, 0.01, ~tempo.kr )   };

~vai[6] = \filter -> q.fx['modelay']

HelpBrowser.instance

Ndef(\boop).play(2)//, {
	var trig = Ndef(\click).kr(1);
	var eg = Decay2.kr(trig, 0.01, 0.1);
	var osc = SinOsc.ar(TExpRand.kr(200, 800, trig));
	(osc * eg * 0.5).dup
});




~vai[5] = \filter -> q.fx['wah']

~vai[6] = \filter -> q.fx['modelay']

Ndef(\click2).set(\subdiv, 2)

Ndef(\click).copy( \click2 )

~vai2 = ~vai[0].copy
~vai2.play(4)
~vai2.offset = 0.5

l.tempo = 2/3





Ndef( \kariri_xokó).clear//[0] = ~vai[0] // {   VarSaw.ar( (\freq.kr(110) ) * [1,1.1], 0.5pi, LFCub.kr( [0.1, 0.11] ).range(0,1) ) * \amp.kr(0.01) }; //).quant_(1).play(2);

Ndef( \kariri_xokó ).quant_(1).clock_(l).play(4) ;

Ndef( \kariri_xokó )[2] = \filter -> { |in| Decay2.ar( Ndef(\click).ar(1) * 2 , 0.1, Ndef(\tempo).kr * 0.5 ) * in };

Ndef(\aua).play(0)
Ndef( \kariri_xokó).play(0);

Ndef( \kariri_xokó)[4] = \pset -> Pbind( \dur, /Prand([1,1,0.5,0.25],inf), \degree, Pxrand((0..3) - 5 * 2, inf), \test, Ndef(\tempo).bus.asMap )

CmdPeriod.run

q = q ?? ()
q.ndefmix = NdefMixer(s)
q.pxmix = ProxyMixer.new(p)
q.pxmix.gui
ProxyMeter.addMixer(q.pxmix)
s.scope
l.tempo = 1.25
~tempo = l.tempo
l.tempo = 1
HelpBrowser.instance


s.boot;

Troop.start

// TODO: startup file com:
// p.push
// ~click e/ou Ndef(/click)
// History
// FX Dict?
// Vocoder?
// PV?

t = TempoClock.default.new.latency_(s.latency);

// no need to re-evaluate this if you did it already in the earlier example
(
var ctl;

Ndef(\tempo, t.tempo);  // numeric proxy

ctl = SimpleController(l)
.put(\tempo, { Ndef(\tempo, t.tempo) })
.put(\stop, { ctl.remove });
)

(
SynthDef(\krClick, { |out, beatsPerSec = 1, beats = 1, subdiv = 4|
	var click = Impulse.kr(beatsPerSec * subdiv);
	var count = PulseCount.kr(click);
	FreeSelf.kr(Delay1.kr(count >= (subdiv * beats)));
	Out.kr(out, click);
}).add;
)

// It turns out, if I don't initialize the proxy
// to a kr signal, then the Pbind will be assumed to be ar
// and that will make the clicks unavailable
Ndef(\click, { DC.kr(0) }).quant_(1).clock_(t);

CmdPeriod.runÖ

(
Ndef(\click, Pbind(
\instrument, \krClick,
\beatsPerSec, Ndef(\tempo).bus.asMap,
\dur, 1
))
)
l.tempo = 1

Ndef(\boop, {
	var trig = Ndef(\click).kr(1);
	var eg = Decay2.kr(trig, 0.01, 0.1);
	var osc = SinOsc.ar(TExpRand.kr(200, 800, trig));
	(osc * eg * 0.5).dup
});

Ndef(\boop).play;

Ndef(\boop).stop;

Ndef( \matis, { }).play;

Ndef( \lalala, {  })

(
~freqs = 110*[1, 1/3, 2/3, 4/5, 2/5, 3/5, 6/5, 8/5].keep(6).scramble;
~lala = { 
    Squine.ar(
        ~freqs.kr, 
        LFNoise0.ar(0.1*[0.5,0.55]).range(0,1), 
        LFNoise0.ar(0.1*[0.2,0.22]).range(-1,1), 
        02.50,
        {LFNoise2.kr( 0.05 ).range(0.125, 0.5/4)} ! ~freqs.numChannels,
        0,
        {LFNoise0.kr(0.1).range(4,100)}
    )
};
)

~lala.play(2)

( 
~buchla = {
    AnalogFoldOsc.ar(
        TChoose.kr( Ndef(\click).ar, ~freqs.kr ),
        LFNoise2.kr( 0.25 ).exprange(0.5,1.5 ) 
    ) * { LFNoise2.kr(0.2).exprange(0.05,0.075) } ! 2
};
)
~surui_paiter.ar;

(
~surui_paiter[0] = { 
    var trig2 = Ndef(\click2).kr;
    var trig = Ndef(\click).kr;
    var seq = Demand.kr( [ trig, trig2 ], 0 , Dseq([400,99,791,2000,200], inf)).lag3ud(0.01);
    var sig = SinOscFB.ar( 55 * [1,1.01], LFNoise2.kr(0.22).range(1.1, 1.5) ) + WhiteNoise.ar(0.1);
    sig * 1
};
~surui_paiter[2] = \filter -> {|in| 
    var env = in * Env.perc( ).kr( Ndef(\click).kr, ~tempo.kr * 0.25 );
    in = LPG.ar(in, env, LFSaw.kr(0.1).range(0,0.2), LFNoise2.kr( 0.1 ).range(0.4,0.95), LFNoise2.kr( 1 ).unipolar, 1.1, 1, 0) * 0.25;
    // Pan2.ar( in, )
}
)

~surui_paiter.play(2)

~buchla.play(8)

p.play

HelpBrowser.instance

l.tempo = 0.75

Plugins.gui

Squine.ar()

AnalogBassDrum
AnalogFoldOsc
LPG.ar()
AnalogPhaser
AnalogPhaserMod
AnalogSnareDrum
AnalogTape
AnalogVintageDistortion
BLOsc
Chen
DCompressor
HarmonicOsc
LPG
HelpBrowser.instance
LockhartWavefolder
NeoFormant
NeoVarSawOsc
NonlinearFilter
OscBank
PhasorModal
Resonator
Rongs
StringVoice
VA1Pole
VADiodeFilter
VAKorg35
VALadder
VASEM12
VadimFilter
VarShapeOsc
VosimOsc
ZOsc

GutterSynth

f0plugins
RedPhasor
Beep.ar
Atari2600
...

vbUGens
Lores
SCM
RCD
Slide
VBChebyFilt
VBFourses
VBJonVerb
VBPVoc

Myplugins

PLL

SimplexSynth

Steroids
SSinOscFB
TDemand

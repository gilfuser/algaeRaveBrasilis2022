p.push;

s.meter
().play
~vai.play
s.makeGui
Troop.start
s.quit
./startup_algaRave.scd
SinOscFB.ar(220) * 0.2
~vai[0] = { VarSaw.ar(\freq.kr(220) * LFNoise2.ar(0.25).range(0.95, 1.05)  * [1, 1.01], SinOsc.kr(0.25, [0.5pi, 1.5pi]).range(0,1) ) * \amp.kr(0.2) }
~vai1.fadeTime = 0
~dustdecay = {Decay.ar( Ndef(\click).kr, ~tempo.kr)}
~dustdecay.copy(~anotherdust)
~vai[2] = \filter -> {|in| in * ~dustdecay * 0.1 }
~vai1[2] = \filter -> {|in| Compander.ar( in, ~dustdecay, 0.01,1,0.1,clampTime:0.004, relaxTime:0.05) }
~saw1[10] = nil // \set -> Pbind( \note, Prand([-12, -6, -3, 0], inf), \dur, Pbjorklund2(3,5)*1, \legato, 0.1 )
~vai1[3] = \filter -> { |in| [Ndef(\click).kr, Ndef(\click2).kr ] + BlitB3Saw.ar(0.125) * in }
~vai[5] = \filter -> { |in| FreeVerb2.ar(in, DelayN.ar( in, 2, ~tempo.kr * 0.5), 0.5, 0.25, 0.2, 2) }
~vai[7] = \filterIn -> { |in| CombC.ar(in, 2, ~tempo.kr * [1.5,1]*1.5,0.5) }
~vai[10] = \filter -> { |in| SineShaper.ar(in, 0.1, 4) }
~vai[15] = nil//\filter -> { |in| Ringz.ar(in, {LFNoise0.ar(0.25).exprange(55, 5500).lag2(0.5)}!2, 0.075, 0.023) }
~vai[16] = \filter -> { |in| [ in[0] + (in[1]* 0.5),in[1] + (in[0]* 0.5) ] }
~vai[20] = \filter -> { |in| (in * \ampx4.kr(1) ).softclip }
l.tempo = 0.5
HelpBrowser.instance
~saw1.vol = 0.05
~saw1.play(2)
~saw1.vol = 0.01
~saw1[0] = { Saw.ar(\freq.kr(330/2).lag(0.5) * [1,1.01] * (1 + (\lfowidth.kr(0.1) * ~vibrato) ) ) }
~osc2[0] = { LFTri.ar((\freq.kr(220).cpsmidi+[11.9,12.1]).midicps) }
~saw1[2] = \set -> Pbind( \degree, Prand( (-12..6),inf ), \scale, Pdefn(\scale), \dur, 0.25, \t_trig, Ndef(\click2).bus.asMap, \scale, Pdefn(\scale) )
~saw1[1] = \mix -> { ~osc2 * 1 }; ~saw1.set(\mix1, 1)

~beis = { Pulse.ar(\freq.kr(88)*[1,1.01], ~lfo*\lfowidth.kr(0.5)+0.5, \amp.kr(0.3)) * Env( [0,1,0], [0.002,1] ).kr(0, \t_gate.kr(1)) }; ~beis.play(6)
~lfo = { LFTri.kr(\lforate.kr(10)*[1,1.01], Rand(0.0, 2)!2 ) }
~beis[3] = \set -> Pbind(\dur, 8, \t_gate, 1, \degree, Pseq( [-12, -12, -12, -16] + 5, inf))
~lfnoise = { LFNoise2.kr(0.125).exprange(88,8800) }
~beis[6] = \filter -> { |in| RLPF.ar(in, ~lfnoise.kr, \rq.kr(0.5)) }
~beis[9] = \filter -> { |in| FreeVerb.ar(in, 0.7, 0.7, damp:0.25) }
~beis.fadeTime = 0

~organ.play(2)
~organ = { VarSaw.ar([1,1.9953843530485,3.0139733629359]*\freq.kr(88)*( 1 + ( \lfowidth.kr(0.5)*~vibrato.kr ) ) , Rand(0.0,1)!3, Rand(0.3,0.5), [1,0.7,0.3]) }

~env[0] = { Env( [0,1,0], [0.001,1] ).kr(0, \t_gate.kr(1), \sustain.kr(1) ) }
~env[10] = \set -> Pbind(\dur, Pbjorklund2(3,8) * 0.25, \legato, 0.2, \t_gate, 1)

~organ[5] = \filter -> {|in | RLPF.ar(in, \cutoff.kr(100) ) * ~env.kr }
~organ[10] = \set -> Pbind(\dur, Pbjorklund2(3,5) * 0.5, \legato, 0.2, \degree, -6)

~tic[0] = { Decay.ar(Ndef(\click).ar!2, ~tempo.kr, \amp.kr(0.1) ) }
~tic[3] = \filter -> {|in| AudioMSG.ar(in, \preAmp.kr(1).ceil).distort }
~tic.play(8)
~pla.fadeTime = 0
~pla[0] = { WhiteNoise.ar(\amp.kr(0.1)) * DelayN.kr(~tic[0], 2, [~tempo.kr*0.5, ~tempo.kr/2] * 1 )/* LFPulse.ar(0.5, ~lfo*0.5, \width.kr(0.0625))*/ }
~pla[5] = \filter -> {|in| MoogVCF.ar(in,\freq.kr(12000).lag(0.5) * (1+(~vibrato * 0.25)) , \rq.kr(0.5), \amp.kr(0.2).lag3(0.2)) }
~pla[10] = \pset -> Pbind(\dur, 0.25, \scale, Pdefn(\scale), \degree, Prand([-5,0],inf) + 5, \amp, Pbjorklund(5,8) * 0.75 , \offset, 0.25 )
~pla.play(2)

~freqenv.quant_(4)
~lfnoise = {LFNoise2.ar(0.25).range(0.1,0.6)!2}


~freqenv.map(\att, ~lfnoise )
~freqenv = { Env( [4,0.5,1,1], [\att.kr(0.4),0.01,1] ).ar( 0, \t_gate.kr(1), \sustain.kr(1) )  }
~freqenv[2] = \set -> Pbind(\dur, 1/3, \t_gate, 1, \legato, Pbrown(0.1,2) )
~vai = { LFTri.ar(\freq.kr(276)*[0.9,1,0.1] * (1+(~vibrato * 0.0)) * ~freqenv.kr , Rand()!3 , \amp.kr(0.2)) }
~vai[5] = \set -> Pbind(\amp, Pbjorklund(5,8)*0.25, \scale, Pdefn(\scale), \degree, Prand([0,2],inf), \dur, 0.125)

~vibrato = {SinOsc.ar(\lforate.kr(10) * LFNoise2.kr(0.5).range(0.99,0.01), Rand(0,2.0))}
~saw1.fadeTime = 0
~saw1[2] = \filter -> { |in| RHPF.ar( in * Env([0,1,0],[0.002,1]).kr(0, \t_trig.kr(1), \sustain.kr(1) ), \cutoff.kr(110).lag(1), \rq.kr(1),\amp.kr(0.2) , ~tempo.kr * LFNoise2.kr(0.25).range(0.25,4) ) ) /* * ~delaydust.ar */ }
~osc2.addSpec(\cutoff, \freq.asSpec)
~osc2.set(\cutoff, 110)
(<F2><F2>
~osc2[5] = \set -> Pbind(
    // \dur, Pbjorklund2(5,8),
    \dur, Pbjorklund2(3,5) * 0.125,
    \degree, Prand( (-12..6),inf ),
    \scale, Pdefn(\scale),
    // \freq, Pwhite(200.0, 1000, inf),
    // \cutoff, (60 + Pkey(\degree)).midicps * 1.5,
    // \cutoff, Pwhite(0.0, 1, inf).linexp(0,1,88,880),
    // \rate, Pdup(4, Prand([1, 3, 6, 10], inf)),
    // \dt, Pwhite(0.01, 0.1, inf),
    // \t_click, 1
)
)
~osc2.clock = p.clock
(
~osc2[3] = nil// \filter -> { |in| {Mix.fill(7, {
    var maxdelaytime= ~tempo.kr;
    DelayC.ar( in, maxdelaytime,{LFNoise1.kr( Rand(4.5,10.5) ).range(0.05, maxdelaytime * 0.25 ) } )
});}!2 }
)

~deriva[2] = \filter -> {  |in| SwitchDelay.ar(in, 1, 1, 1.3333 ) }
~delaydust = { CombN.ar(~anotherdust.ar, 2, 1.3333 ) }
~deriva.vol_(0.02)

~vai[2] = \mix -> {~saw1.ar}
~vai.set(\mix2, 0.2 )
~saw1.play(6).vol_(0.025)
~saw1[5] = \filter -> { |in| Decay.ar( [Ndef(\click).ar, Ndef(\click2).ar], ~tempo.kr, 0.065) * in * 0.25 }
~saw1.play(4)
~saw1env.play(6)
q.pxmix = ProxyMixer(p)

~vai.outBus


Ndef(\click).copy(\click2)
Ndef(\click2)!2

Ndef(\click2).quant = 1

Ndef(\click2).set(\subdiv, 2)

~vai[2] = nil

ProxyMeter.addMixer(q.pxmix)

~vai.stop

l.tempo = 1
p.tempo
s.makeGui
~vai[0].clear
s.meter



TODO: SynthDef no final para diminuir 8 canais em stereo.

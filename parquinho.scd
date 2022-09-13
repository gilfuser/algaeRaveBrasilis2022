p.push
().play
~vai.play(4)
~vai[0] = { VarSaw.ar(\freq.kr(55) * [1, 1.01], SinOsc.kr(0.25, [0.5pi, 1.5pi]).range(0,1) ) * \amp.kr(0.2) }
~saw1[5] = \set -> Pbind( \note, Prand([-12, -6, -3, 0], inf), \dur, Pbjorklund2(3,5)*0.25, \legato, 0.1 )
~vai[3] = \filter -> { |in| [Ndef(\click).kr, Ndef(\click2).kr ] + BlitB3Saw.ar(0.125) * in }
~vai[5] = \filter -> { |in| FreeVerb2.ar(in, DelayN.ar( in, 2, ~tempo.kr * 0.5), 0.5, 0.25, 0.2, 2) }
~vai[7] = \filterIn -> { |in| CombC.ar(in, 2, ~tempo.kr * [1.5,1]*1.5,0.5) }
~vai[10] = \filter -> { |in| SineShaper.ar(in, 0.1, 4) }
~saw1[15] = \filter -> { |in| Ringz.ar(in, {LFNoise0.ar(0.25).exprange(55, 5500).lag2(0.5)}!2, 0.075, 0.023) }
~saw1[16] = \filter -> { |in| [ in[0] + (in[1]* 0.5),in[1] + (in[0]* 0.5) ] }
~saw1[20] = \filter -> { |in| (in * \ampx4.kr(1) ).softclip }

~saw1 = { Saw.ar(\freq.kr(207) * [1,1.01]) }
~saw1.play(6)
~saw1env = { |in| Decay.ar( [Ndef(\click).ar, Ndef(\click2).ar], ~tempo.kr, 0.065) * ~saw1 * 0.25 }
~saw1env.play(6)
q.pxmix = ProxyMixer(p)

~vai.outBus


Ndef(\click).copy(\click2)
Ndef(\click2)!2

Ndef(\click2).quant = 1

Ndef(\click2).set(\subdiv, 1.5)

~vai[16] = nil

ProxyMeter.addMixer(q.pxmix)

~vai.stop

l.tempo = 1
p.tempo
s.makeGui
~vai[0].clear
s.meter



TODO: SynthDef no final para diminuir 8 canais em stereo.

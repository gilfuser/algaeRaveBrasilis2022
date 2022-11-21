
t.tempo = 2

s.scope

s.stopRecording

~drone.play

~drone[0] = {|freq = 400| Squine.ar( ~freqs*4, clip: SinOsc.kr(0.3, 0, 0.69, 0.85), skew: LFCub.kr(0.0002)) * 0.095 }

~drone[30] = \filter -> {|in| FreqShift.ar(in, LFCub.kr(0.002), LFCub.kr (0.009) ) }

~drone[40] = \filter -> {|in| in = in * 0.35 ; in + AdCVerb.ar(in*0.5, LFNoise2.ar(0.02).range(0.2, 2), LFNoise2.ar(0.2).range(0, 1) )}

~drone.stop(4)

~basef = { |freq = 300 | freq * SinOsc.kr( LFBrownNoise2.ar(0.2).range(3,12) ).exprange(0.9, 1.1) }

~tata = Pbind( \type, \set, \group, ~basef, \freq, Prand( [55, 110, 220, 440, 880 ], inf ), \dur, 16 )
~lala.play
(
~freqs = ~basef *[1, 1/3, 2/3, 4/5, 2/5, 3/5, 6/5, 7/5].keep(3).scramble;
~lala = { 
    Squine.ar( Mix.ar(2,~freqs.kr), LFNoise0.ar(0.1*[0.5,0.55]).range(0,1), LFNoise0.ar(0.1*[0.2,0.22]).range(-1,1), 2.50,
        {LFNoise2.kr( 0.05 ).range(0.1, 0.2)} ! ~freqs.numChannels,
        0,
        {LFNoise0.kr(0.1).range(4,100)}
    )
};
)

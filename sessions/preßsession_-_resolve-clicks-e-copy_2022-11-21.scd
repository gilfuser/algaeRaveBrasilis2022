~vai.play

~lfsaw = { LFSaw.kr(LFSaw.kr(0.005).exprange([0.16,16],[16,0.16])).range([1.5,0],[0,1.5]).softclip }

~vai.fadeTime = 0

~vai = {SinOscFB.ar(Splay.ar(DC.ar(100*LFNoise2.kr([0.01,0.015]).range(1,1.2)*[1,1.01,2,2.5,1.5,1])), ~lfsaw) * 0.2 }
~vai[1] = \filter -> {|in| Compander.ar(in, ~foi.ar, 0.001, 1, 0.125, 0.001, ~tempo*0.125, 2 ) }
~foi.play
~foi.fadeTime = 0
~foi[0] = { PulseDPW.ar(55*[1,1.01]) * 0.005 };
~foi2[1] = \filter -> {|in| in * Decay2.ar(~click2.ar, 0.01, 0.2) }
~click2 = ~click.copy
~click.set(\subdiv, 3)
~foi2.play
~foi2 = ~foi[0].copy
q = q ? ();
(
q.fx = /*q.fxf ?*/ (

    bitcrush: { |in bpre=1 brate=2250 bits=12|
        var sig = ( in * bpre ).softclip;
        Decimator.ar( sig, brate, (bits).floor );
    },

    tape: { |in trate=0.25 tphase=1.5 tdepth=0.25 toffset=0.25|
        var curve = SinOsc.ar(
            ( trate * { l.tempo } ),
            ( tphase * 2pi + 1.5pi) % 2pi,
            tdepth, toffset
        );
        DelayC.ar(in, 2, curve);
    },

    wah: { |in, wrate = 1, wdepth = 0.5, jrate = 0.125, jdepth = 0.125, sinsaw = 0 |
        var  wring = 0.002, wrq = 0.8,  ggain = 1.25 ;
        var jitter = LFNoise2.ar( jrate, jdepth);
        var mod = Select.kr( sinsaw, [
            SinOsc.ar( wrate, ( jitter * 2pi) % 2pi, wdepth).exprange(100, 5000),
            VarSaw.kr(wrate, jitter, 0.1, wdepth).lag(0.1).exprange(100, 5000),
        ]);
        var ringz = Ringz.ar( in, mod, wring );
        var sig = RLPF.ar(ringz, mod, wrq.lag(0.1)) * ggain.tanh.lag(0.0003) / ggain.sqrt;
        Limiter.ar(sig, 0.9);
    },

    pitch: { | in, slide = 0.4, deg = 0, tdisp = 0.1, pdisp = 0.025 |
        // var degree = Select.kr(degree, (0..11)).asInteger;
        // var freq = Scale.chromatic.degreeToFreq(deg, 60.midicps,0);
        var pitchRatio =  deg.midiratio;
        var window =  0.15;
        var timeDisp = LFDNoise3.ar( 0.0626).range(0, window) * tdisp;
        PitchShift.ar( in, window, pitchRatio, pdisp, timeDisp );
    },

    lfo: { | in,  lrate = 0.0125, iphase = 0, lwidth = 0.5, sisap = 0, hifreq = 20000, midfreq = 60 |
        var tempo = ( lrate * l.tempo );
        var mod = Select.ar( sisap, [
            SinOsc.ar( tempo, ( lrate *  iphase * 2pi + 1.5pi ) % 2pi ),
            LFSaw.ar( tempo, iphase % 2, lwidth ), // change to LFTri
            LFPulse.ar(tempo, (lrate * iphase) % 1, lwidth.clip(0.02, 0.998) ) * 2 - 1,
        ] );
        BLowPass.ar( in, mod.lag2(0.05).exprange( midfreq, hifreq ) );
    },



    hpf: { |in hff=320 hrq=1|
        BHiPass.ar( in, hff, hrq );
    },

    lpf: { |in lff = 80 lqr = 1|
        BLowPass.ar( in, lff, lqr );
    },

    /*compt: { |in|
        var ctrl = HPF2Casc.ar( p.dubba, \ccff.kr (1000,0.2,spec:\midfreq), 4 );
        var comp = Compander.ar(
            in, ctrl, \cthresh.kr( 0.25,spec:[-60.dbamp,1,\amp]), 1, \slopea.kr( 0.5,spec:[0.05,1]),
            \clamp.kr( 0.002,spec:[0.001, 0.4]), \relax.kr( 0.1,spec:[0.1,1]) * \delta.kr( 1,spec:[0.01,10])
        );
        Limiter.ar( comp );
    },*/

    verb: { |in vmix=0.5 vroom=0.5 vdamp=0.5|
        FreeVerb.ar(in, vmix, vroom, vdamp)
    },

    modelay: { | in mdfb=0.5 mdtime=1 mdtimel=1.5 mdtimer=1 mdlock=0 mdff=800 mdfq=3 mdamp=1 |
        var decaytime, decaytimeL, decaytimeR, delayL, delayR, timeMod, eqMod;
        var maxDelayTime = 4;
        var signal = in;

        // in = if(numChannels > 2) { in.clump(2).sum } { in.dup };
        mdfb = mdfb.clip(0, 0.99);
        mdtime = mdtime * if( mdlock, reciprocal( l.tempo ), 1 );
        mdtime = mdtime.clip(0.014, maxDelayTime);
        decaytime = log2(-60.dbamp) / log2(mdfb) * mdtime;
        decaytime = decaytime.clip(0, 20);
        mdtimel = mdtimel * if(mdlock, reciprocal( l.tempo ), 1);
        mdtimel = mdtimel.clip(0.014, maxDelayTime); // just to be sure
        mdtimer = mdtimer * if(mdlock, reciprocal( l.tempo ), 1);
        mdtimer = mdtimer.clip(0.014, maxDelayTime);
        decaytimeL = log2(-60.dbamp) / log2(mdfb) * mdtimel;
        decaytimeL = decaytimeL.clip(0, 20);
        decaytimeR = log2(-60.dbamp) / log2(mdfb) * mdtimer;
        decaytimeR = decaytimeR.clip(0, 20);

        timeMod = { LFDNoise3.ar(5.5, 0.001) };
        eqMod = { LFDNoise3.kr(1, 0.25, 1) };

        signal = signal + ( [ LocalIn.ar(2)[0] * mdtimel.lincurve(0, 4, 0, 1, -16), LocalIn.ar(2)[1] * mdtimer.lincurve(0, 4, 0, 1, -16) ] );

        delayL = CombC.ar( signal[0], maxDelayTime, mdtimel + timeMod, decaytimeL );
        delayL = BBandPass.ar( delayL, mdff.lag(0.1) * eqMod, mdfq.lag(0.1) );

        delayR = CombC.ar(signal[1], maxDelayTime, mdtimer + timeMod, decaytimeR );
        delayR = BBandPass.ar( delayR, mdff.lag(0.1) * eqMod, mdfq.lag(0.1) );

        signal = Limiter.ar( [ delayL, delayR] * mdamp.clip2(4) );
        LocalOut.ar( AllpassN.ar(mdfb * signal, maxDelayTime, delaytime: mdtime , decaytime: decaytime) );
        signal;
    },

    leakDC: { |in leak=0.99| LeakDC.ar(in, leak ) },
)
);
q.fx.know = true;
q.fx[\modelay].addSpec(
    \mdtime, [0,4],
    \mdtimel, [0,4],
    \mdtimer, [0,4],
    \mdfb, [0,1],
    \mdlock, [0,1,\lin,1],
    \mdff, [42,4200, \exp]
);
q.fx[\modelay].addSpec( \mdfq, [0.3, 3],\mdamp, \ampx4.asSpec );

q.fx[\wah].addSpec(
    \wrate, [0, 8, \lin],
    \wdepth, [0, 1],
    \jrate, [0.1,10,\exp],
    \jdepth, [0,1],
    \sinsaw, [0, 1, \lin, 1, 0]
);

q.fx[\lfo].addSpec(
    \sisap, [ 0, 2, 1, 1 ],
    \hifreq, [ 200, 20000, \exp ],
    \iphase, [ 0.001, 1, \exp, 0, 0.5 ],
    \lwidth, [ 0, 1 ],
    \lrate, [ 0, 16, \lin, 0.125, 1 ]
);

q.fx[\pitch].addSpec(
    \pdisp, [0, 0.5],
    \tdisp, [0, 1],
    \slide, [0.02, 2],
    \deg, [-36, 36, \lin, 1, 0]
);

q.fx[\hpf].addSpec(
    \hff, [20, 10000, \exp, 0, 320],
    \hff, [20, 10000, \exp],
    \hrq, \qr.asSpec,
);

q.fx[\lpf].addSpec( \lff, [40, 20000, \exp], \lrq, \qr.asSpec );

q.fx[\bitcrush].addSpec(
    \brate, [44100,44.1,\exp],
    \bpre, \ampx4.asSpec,
    \bits, [24,2.4,\exp]
);

q.fx[\tape].addSpec(
    \trate, [ 0.125, 4, \lin, 0.125, 1],
    \tphase, [0, 2],
    \tdepth, [0.001,1],
    \toffset, [0, 1]
);

q.fx[\leakDC].addSpec( \leak, [0.5,0.999,\exp] );

q.fx[\verb].addSpec( \vmix, [0,1], \vdamp, [0,1], \vroom, [0,1] );

(
q.printFxFuncs = {
    q.fx.keysValuesDo{ |key val|
        q[key.asSymbol] = val;
        postf("% -> ", key);
        q.fx[key.asSymbol].argNames.do {|n, i|
            if (n != \in) {
                postf("% %, ", n, q.fx[key.asSymbol].defaultArgs[i]);
                //
		}
        };
        "\n".postln;
    };
    ">>>> q.fx.foo = q.foo\n".postString;
    '';
};
q.printFxFuncs;
);
'';
"FX Lib -> Functions - check with q.printFxFuncs\n ".postString;

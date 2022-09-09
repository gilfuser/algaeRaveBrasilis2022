q = q ? ();
q.fx = q.fx ? ();

    q.deltas = q.deltas ? Bus.control(s, 5).setn(1!5);

    ProxyChain.add3( '00_in', \filter -> { |in, level=0.85|
            LeakDC.ar( in * level.lag(0.2) )
            + (BrownNoise.ar(0.000001) ! s.options.numOutputBusChannels );
        }, 1,
        ( level: \ampx4.asSpec )
    );

    ProxyChain.add3( \ampFin, \filter -> { |in, drive=1.2, ampLimit=0.8 |
        Limiter.ar(in * drive, ampLimit);
    }, 1,
    ( [
        drive: [1, 10, \exp],
        ampLimit: \amp.asSpec
    ] )
    );

    ProxyChain.add3(
        \analysis,  \filter -> { | in, rate = 60 |
            var freq, hasFreq, in_copy, amp, trig /*trigA, trigHf, trigF*/;
            in_copy = HPF2Casc.ar( in, 40, 8 );
            in_copy = Compander.ar( in_copy, in_copy, 0.05, slopeBelow: 8 );
            amp = Amplitude.kr( in_copy, 0.05, 0.05 );
            # freq, hasFreq = Tartini.kr( in_copy, 0.93, 1024, 512, 512 );
            trig = Impulse.kr(rate);
            /*
            trigA = Changed.kr( amp );
            trigHf = Changed.kr( hasFreq );
            trigF = Changed.kr( freq );
            */
            SendReply.kr( trig, '/amp', amp );
            SendReply.kr( trig, '/hasFreq', hasFreq );
            SendReply.kr( trig, '/freq', freq );
            in;
        }, 1,
        ( rate: [ 8, 60, \lin, 1, 8 ] )
    );

    ProxyChain.add3( 'bitcrush', \filter -> { |in brate = 44100.0 bits = 16 bpre = 1 |
        var sig = ( in * bpre ).softclip;
        Decimator.ar(sig, brate, bits.floor );
    }, 1,
    ( [
            brate: [44100.0, 44.1, \exp],
            bits: [24, 2.4, \exp],
            bpre: \ampx4.asSpec
    ] )
    );

    ProxyChain.add3( \comp, \filterIn -> { | in, thresh = 0.33, slopea = 0.33, clamp = 0.03, relax = 0.35, cmix = 0.5 |
        var sig = HPF.ar(in, 65.4);
        sig = Limiter.ar( Compander.ar( in, sig, thresh.linexp(0, 1, 0.001, 1), 1, slopea, clamp, relax ) );
        XFade2.ar(in, sig, cmix);
    },
    1,
    ( [
        thresh: [-60.dbamp, 1, \amp],
        slopea: [0.05, 1],
        clamp: [0.001, 0.4],
        relax: [0.1, 1],
        cmix: [0,1]
    ] )
    );

    ProxyChain.add3( \compt, \filter -> { | in cctrl=3 ccfreq=1000 thresh = 0.25 slopea = 0.5 clamp = 0.001 relax = 0.1 deltas = 1  |
        var deltaSel = Select.kr(deltas, q.deltas);
        var bus = Select.ar(cctrl, [ Ndef(\orb0).ar, Ndef(\orb1).ar, Ndef(\orb2).ar, Ndef(\orb3).ar, 0 ]);
        var ctrl = HPF2Casc.ar( bus, ccfreq, 4 );
        var comp = Compander.ar( in, ctrl, thresh.linexp(0, 1, 0.001, 1), 1, slopea, clamp, relax * deltaSel );
        Limiter.ar( comp );
    },
    1,
    ( [
            cctrl: [0, 3, \lin, 1, 1 ],
            ccfreq: \midfreq,
            thresh: [-60.dbamp, 1, \amp ],
            slopeb: [0.5, 4],
            slopea: [0.05, 1 ],
            clamp: [0.001, 0.4 ],
            relax: [0.1, 1 ],
            deltas: [0, 4, \lin, 1, 1 ],
            // \delta: [0.01, 10 ]
    ] )
    );
    ProxyChain.add3( \endFilt, \filter -> { | in, highPass=40, lowPass=15000 |
        var l, h;
        l = HPF2Casc.ar( in, highPass);
        h = LPF2Casc.ar( in, lowPass);
        h-l;
    }, 1,
    ( [
        highPass: \lofreq.asSpec,
        lowPass: \hifreq.asSpec
    ] )
    );

    ProxyChain.add3( \hole, \filterIn -> {  | in , hrate = 0.1, damp = 0.1, hsize = 1, hdif = 0.707, hfb = 0.1 |
        var delayTime = (hrate * {TempoClock.default.tempo}).reciprocal.lag(0.2);
        Greyhole.ar( in, delayTime, damp, hsize.lag(0.2), hdif, hfb, modDepth: 0.2 );
    }, 1,
    ( [
            hrate: [0, 2],
            damp: [0, 1],
            hsize: [0.5, 3],
            hdif: [0, 1],
            hfb: [0, 1],
    ] )
    );

    ProxyChain.add3( \hpf, \filter -> { |in hifreq = 65.4 hrq = 1|
        BHiPass.ar( in, hifreq.lag(0.2), hrq.lag(0.2) ); // mul
    }, 1,
    ( [
            hrq: \rq.asSpec,
            hifreq: [65.4, 8372, \exp]
    ] )
    );

    ProxyChain.add3( 'lfo', \filterIn -> { | in,  sisap = 0, lrate = 0, iphase = 0, lwidth = 0.5,  midfreq = 60,  hifreq = 20000 |
        var tempo = (lrate * TempoClock.default.tempo )/*.reciprocal*/;
        var mod = Select.ar(sisap, [
            SinOsc.ar( tempo, ( lrate *  iphase * 2pi + 1.5pi ) % 2pi ),
            LFSaw.ar( tempo, iphase % 2, lwidth ), // change to LFTri
            LFPulse.ar(tempo, (lrate * iphase) % 1, lwidth.clip(0.02, 0.998) ) * 2 - 1,
        ]);
        BLowPass.ar(in, mod.lag2(0.05).exprange(midfreq.lag(0.1), hifreq.lag(0.1)));
    }, 1,
    ( [
            iphase: [ 0.001, 1, \exp, 0, 0.5 ],
            hifreq: [ 200, 20000, \exp, 0, 220, "Hz" ],
            lwidth: [ 0, 1 ],
            sisap: [ 0, 2, \lin, 1, 1 ],
            lrate: [ 0, 16, \lin, 0.125, 1 ],
    ] )
    );

    ProxyChain.add3( 'par_EQ', \filter -> { arg in, pFreq=40.0, pRq=0.5, pDb=6.0;
        MidEQ.ar(in, pFreq.lag(1), pRq.lag(1), pDb.dbamp);
    }, 1,
    ( [
            pFreq: \freq.asSpec,
            pDb: [-60, 32, \lin, 0, 1],
            pRq: \rq.asSpec
    ] )
    );

    ProxyChain.add3('pitch', \filterIn -> { | in pdeg = 0  pdisp = 0, tdisp = 0.5, slide = 0.4 |
        var pitchRatio = DegreeToKey.kr(Scale.chromatic.degrees.as(LocalBuf),pdeg,12,1).midiratio;
        var wSize =  0.15;
        var tDisp = LFDNoise3.ar( 0.0626).range(0, wSize) * tdisp;
        PitchShift.ar( in, wSize, pitchRatio, pdisp, tDisp );
    }, 1,
    ( [
            pdisp: [0, 0.5],
            tdisp: [0, 1],
            slide: [0.02, 2],
            pdeg: [-24, 24, \lin, 1, 0],
            // oct: [-4, 4, \lin, 1]
    ] )
    );

    ProxyChain.add3( 'soundIn', \filter -> { | in inchan = 0 mix = -1 preVol = 1 |
        var sig = in * preVol;
        XFade2.ar(sig, SoundIn.ar(inchan), mix)
    }, 1,
    ( [
        preVol: \ampx4.asSpec,
        inchan: [ 0, 1, \lin, 1, 0 ],
        mix: [ -1, 1, \lin, 0, -1 ],
    ] )
    );

    ProxyChain.add3( 'tape', \filter -> { |in trate = 1 tphase = 1.5 tdepth = 1 toffset = 1 |
        var curve = SinOsc.ar( (trate * {TempoClock.default.tempo}), ( tphase.lag(0.1) * 2pi + 1.5pi) % 2pi, tdepth, toffset.lag(0.1) );
        DelayC.ar(in, 2, curve);
    }, 1,
    ( [
            toffset: [0, 1],
            tdepth: [0.001,1, \lin],
            trate: [ 0.125, 4, \lin, 0.125, 1 ],
            tphase: [ 0, 2],
    ] )
    );

    ProxyChain.add3( 'wah', \filter -> { |in, wrate = 1, wdepth = 0.5, sinsaw = 0, wphase = 0, jrate = 1, jdepth = 0 |
        var  wring = 0.002, wrq = 0.8,  ggain = 1.25 ;
        var jitter = LFNoise2.ar(jrate, jdepth);
        var mod = Select.kr(sinsaw, [
            SinOsc.ar( wrate, ( jitter * 2pi) % 2pi, wdepth).exprange(100, 5000),
            VarSaw.kr(wrate, jitter, 0.1, wdepth).lag(0.1).exprange(100, 5000),
        ]);
        var ringz = Ringz.ar( in, mod, wring );
        var sig = RLPF.ar(ringz, mod, wrq.lag(0.1)) * ggain.tanh.lag(0.0003) / ggain.sqrt;
        Limiter.ar(sig, 0.9);
    }, 1,
    ( [
            wrate: [0, 8, \lin],
            wdepth: [0, 1],
            jdepth: [0, 1],
            wring: [0.001, 1, \exp],
            sinsaw: [0, 1, \lin, 1, 0],
            jrate: [0.1, 10, \exp],
            wphase: [0, 1],
    ] )
    );

    ProxyChain.add3( 'lpf', \filterIn -> { | in, lofreq = 60, lrq = 0.2 |
        BLowPass.ar(in, lofreq.lag2(0.2), lrq.lag2(0.2) );
    }, 1,
    ( lrq: \rq.asSpec )
    );

    ProxyChain.add3( \leakDC,  \filter -> { |in, leak=0.99| LeakDC.ar(in, leak) }, 1,
        ( leak: [0.5, 0.999, \exp] )
    );

    ProxyChain.add3( \verb, \filterIn -> { |in mix = 0.5 room = 0.5 damp = 0.5 |
        FreeVerb.ar(in, mix, room, damp)
    }, 1,
    ( [
        mix: [0,1],
        room: [0,1],
        damp: [0,1]
    ] )
    );

    ProxyChain.add3( \verbPan, \filterIn -> { |in mix = 0.5 room = 0.5 damp = 0.5 pan = 0 |
        var sig2v = PanAz.ar( s.options.numOutputBusChannels,  in, pan, 1, s.options.numOutputBusChannels );
        PanAz.ar( s.options.numOutputBusChannels,  FreeVerb.ar(in, mix, room, damp), pan, 1, s.options.numOutputBusChannels );
    }, 1,
    ( [
        mix: [0,1],
        room: [0,1],
        damp: [0,1]
    ] )
    );

    ProxyChain.add3(
        \modelay, \filter -> { | in, mdfb = 0.5, mdtime = 1, mdtimel = 1.5, mdtimer = 1, mdlock = 0, mdff = 800, mdfq = 3, mdamp = 1 |
            var decaytime, decaytimeL, decaytimeR, delayL, delayR, timeMod, eqMod;
            var maxDelayTime = 4;
            var signal = in;

            // in = if(numChannels > 2) { in.clump(2).sum } { in.dup };
            mdamp = mdamp.clip(0, 4);
            mdfb = mdfb.clip(0, 0.99);
            mdtime = mdtime * if( mdlock, reciprocal(TempoClock.default.tempo), 1 );
            mdtime = mdtime.clip(0.014, maxDelayTime);
            decaytime = log2(-60.dbamp) / log2(mdfb) * mdtime;
            decaytime = decaytime.clip(0, 20);
            mdtimel = mdtimel * if(mdlock, reciprocal(TempoClock.default.tempo ), 1);
            mdtimel = mdtimel.clip(0.014, maxDelayTime); // just to be sure
            mdtimer = mdtimer * if(mdlock, reciprocal(TempoClock.default.tempo ), 1);
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

            signal = Limiter.ar( [ delayL, delayR] * mdamp.lag(0.01) );
            LocalOut.ar( AllpassN.ar(mdfb * signal, maxDelayTime, delaytime: mdtime /* + timeMod */ , decaytime: decaytime) );
            signal;
        }, 1,
        ( [
                \mdtime: [0,4],
                mdtimel: [0,4],
                mdtimer: [0,4],
                mdfb: [0,1],
                mdlock: [0,1,\lin,1],
                mdff: [42,4200, \exp],
                mdfq: [0.3, 3],
                \mdamp: \ampx4.asSpec,
        ] )
    );

    ProxyChain.add3(
        \strobe, \filter -> { |in t_trig=1 strob=1 sphase=1 onTime=1 offTime=1 scurve |
            // var shape = *['hold', 'step', 'lin', 'exp', 'sin', 'wel', 'cub'];
            var tempo = TempoClock.default.tempo.reciprocal;
            var env = Select.kr(scurve, [
                Env( [ 0,1,0.001,0.001,1 ], [ 0,onTime,sphase,offTime ].normalizeSum, \hold, releaseNode:1 ).kr(
                    gate:t_trig, timeScale: strob * tempo ),
                Env( [ 0,1,0.001,0.001,1 ], [ 0,onTime,sphase,offTime ].normalizeSum, \step, releaseNode:1 ).kr(
                    gate:t_trig, timeScale: strob * tempo ),
                Env( [ 0,1,0.001,0.001,1 ], [ 0,onTime,sphase,offTime ].normalizeSum, \lin, releaseNode:1 ).kr(
                    gate:t_trig, timeScale: strob * tempo ),
                Env( [ 0,1,0.001,0.001,1 ], [ 0,onTime,sphase,offTime ].normalizeSum, \exp, releaseNode:1 ).kr(
                    gate:t_trig, timeScale: strob * tempo ),
                Env( [ 0,1,0.001,0.001,1 ], [ 0,onTime,sphase,offTime ].normalizeSum, \wel, releaseNode:1 ).kr(
                    gate:t_trig, timeScale: strob * tempo ),
                Env( [ 0,1,0.001,0.001,1 ], [ 0,onTime,sphase,offTime ].normalizeSum, \cub, releaseNode:1 ).kr(
                    gate:t_trig, timeScale: strob * tempo )
            ] );
            in * env;
        }, 1,
        ( [
                strob: [0.25, 12, \lin,1,0.25],
                scurve: [0, 6, \lin,0,1],
                onTime: [0.16, 16],
                offTime: [0.16, 16],
                sphase: [0.16, 16],
                t_trig: [0,1,\lin,1,1],
        ] )

    );
    Spec.add( \wet1, [0.0, 1.0]);
    Spec.add( \wet2, [0.0, 1.0]);
    Spec.add( \wet3, [0.0, 1.0]);
    Spec.add( \wet4, [0.0, 1.0]);
    Spec.add( \wet5, [0.0, 1.0]);
    Spec.add( \wet6, [0.0, 1.0]);
    Spec.add( \wet7, [0.0, 1.0]);
    Spec.add( \wet8, [0.0, 1.0]);
    Spec.add( \wet9, [0.0, 1.0]);
    Spec.add( \wet10, [0.0, 1.0]);
    Spec.add( \wet11, [0.0, 1.0]);
    Spec.add( \wet12, [0.0, 1.0]);

    Spec.add( \wet20, [0.0, 1.0]);
    Spec.add( \wet30, [0.0, 1.0]);
    Spec.add( \wet40, [0.0, 1.0]);
    Spec.add( \wet50, [0.0, 1.0]);
    Spec.add( \wet60, [0.0, 1.0]);
    Spec.add( \wet70, [0.0, 1.0]);
    Spec.add( \wet80, [0.0, 1.0]);
    Spec.add( \wet90, [0.0, 1.0]);
    Spec.add( \wet100, [0.0, 1.0]);

    Spec.add( \wet200, [0.0, 1.0]);
    Spec.add( \wet210, [0.0, 1.0]);

"***** FX Lib for ProxyChains LOADED! *****\n".postString

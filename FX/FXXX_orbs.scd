

q.fxDir = thisProcess.nowExecutingPath.dirname;
q.numOrbs = q.numOrbs ? 4;
fork{
    q.numOrbs.do{|i|
        Ndef(format("orb%",i).asSymbol).addSpec(
            // /* soundIn --*/ \inchan, [ 0, 2, \lin, 1, 0 ], \mix, [ -1, 1, \lin, 0, -1 ],
            /* 00_in ----*/ \level, \ampx4.asSpec,
            /* bitcrush -*/ \brate, [44100.0, 44.1, \exp], \bits, [24, 2.4, \exp], \bpre, \ampx4.asSpec,
            /* hole -----*/ \hrate, [0, 1],  \damp, [0, 1],  \hsize, [0.5, 3],  \hdif, [0, 1],  \hfb, [0, 1],
            /*\hpf ------*/ \hrq, \rq.asSpec,
            /* pitch ----*/ \pdisp,  [0, 0.5],  \tdisp, [0, 1],  \slide, [0.02, 2],
            /* tape -----*/ \trate, [ 0.125, 4, \lin, 0.125, 0.25 ],  \tphase, [ 0, 2], \toffset, [0, 1],
            \tdepth, [0, 1],
            // /* filter ---*/ \ftype, [0, 4, \lin, 1, 0], \sfreq, \freq, \res, [0, 1],
            /* wah ------*/ \wrate,  [0, 10, \lin],  \depth, [0, 1], \jdepth, [0, 1], \jfreq, [0.1, 10, \exp],
            \sinsaw, [0, 1, \lin, 1, 0],  \ggain, [0.001, 1, \lin/*\amp*/],\wring, [0.001, 1, \exp],
            /* lfo -----*/ \lrate, [ 0, 16, \lin, 0.125, 1 ],  \hifreq, [200, 20000, \exp, 0, 20000],
            \lwidth, [ 0, 1 ], \sisap, [0, 2, \lin,1, 1],  \iphase, [ 0.001, 1, \exp, 0, 0.5 ],
            /*\lpf ------*/ \lrq, \rq.asSpec,
            /* modelay --*/ \mdtime, [0,4], \mdtimel, [0,4], \mdtimer, [0,4], \mdfb, [0,1], \mdlock, [0,1,\lin,1], \mdff, [42,4200, \exp], \mdfq, [0.3, 3], \mdamp, \ampx4,
            // /* duck --*/ \dcurve, [-6, 6],  \dwidth, [0, 1],  \ddur, [ 0.25, 4 ],  \iphase, [ 0, 1 ],
            /* strobe */ \strob, [0.25, 12, 1, 0.25],  \scurve, [0, 6, 0, 1],  \ontime, [0.16, 16],
            \offtime, [0.16, 16],  \sphase, [0.16, 16],
            /* comp -----*/ // \cctrl, [0, 3, \lin, 1, 1], \thresh, [-60.dbamp, 1, \amp], \slopea, [0.05, 1],
            // \clamp, [0.002, 0.4], \relax, [0.005, 2], \delta, [0.01, 10],
            /* ampFin ---*/ \limDrive, \ampx4,  \ampLimit, \amp,  \postAmp, \ampx4,
            // \cps, [0.1,1],
            // \wet200, [0.0, 1.0], \wet210, [0.0, 1.0],
            /* hpf ------*/ \hrq, \rq.asSpec, \hifreq, [65.4, 8372, \exp],
            /* lpf ------*/ \lrq, \rq.asSpec,
            \delta, [0, 20],
        );
        wait(0.1);
        q.fx[format("orb%",i).asSymbol]  = ProxyChain.from( Ndef( format("orb%",i).asSymbol ),
            [ '00_in'] ++ ['strobe', 'tape', 'wah', 'lfo', 'pitch', 'modelay'].scramble ++ [\hpf, \lpf, \ampFin]
        );

        wait(0.1);
        Ndef( format("orb%",i).asSymbol ).set(
            // /* soundIn */ \inchan, 0, \mix, -1,
            /* tape */ \trate, 0.25, \tphase, 0, \tdepth, 0.5, \toffset, 0.5,
            // /* hole */ \hrate, 0.5, \damp, 0.5, \hsize, 1, \hdif, 0.7, \hfb, 0,
            // /* filter */ \ftype, 1, \sfreq, 632.46, \res, 0.5,  // lpf, bpf, hpf, notch, peak
            /* pitch */ \pdisp, 0, \tdisp, 0.5, \slide, 0.4,
            /* wah */ \wrate, 1, \depth, 0.75, \sinsaw, 0, \jdepth, 0.1, \jfreq, 1,
            /* lfo */ \lrate, 0, \iphase, 0.5, \lwidth, 0.5, \sisap, 0, \midfreq, 60, \hifreq, 20000,
            /* modelay */ \mdfb, 0.5, \mdtime, 1, \mdtimel, 1.5, \mdtimer, 1, \mdlock, 0, \mdff, 800, \mdfq, 3, \mdamp, 1,
            // /* strobe */ \strob, 1, \sphase, 1, \ontime, 1, \offtime, 1, \scurve, 0,
            /* comp */ // \cctrl, 1, \thresh, 0.5, \slopea, 1, \clamp, 0.002, \relax, 0.02, \delta, 1,
            /* ampFin */ \limDrive, 1.25, \ampLimit, 1, \postAmp, 1,
            // \cps, 1
        );
        q.fx[format("orb%",i).asSymbol].add('00_in', 1).add('ampFin', 1);
        wait(0.1);
    };

};

// Pró: good for liveCoding || Contra: dificult to access controlkeys.

{
    q.numOrbs.do{|i|
        q.guiOrb1 = q.fx[format("orb%",i).asSymbol].gui(50).moveTo(500*i, 570);
        q[format("o%Pset",i).asSymbol] = NdefPreset( format("orb%",i).asSymbol );

    };
    // q.guiOrb4 = q.fx.orb4.gui(8).moveTo(0, 0);
    /*q.o0Pset = NdefPreset( Ndef(\orb0) );
    q.o0Pset.loadSettings( q.fxDir ++ "/orb0.pxpreset.scd");
    q.o0PsetGui = NdefPresetGui(q.o0Pset, 40).moveTo(0, 570);*/

}.defer(1);



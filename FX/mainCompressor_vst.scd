p.pop;
SynthDef(\mainFX, { | in out bypass = 0 |
    ReplaceOut.ar(out, VSTPlugin.ar( In.ar(in, 10 ), 2, bypass ));
}).add;
fork{
    ~mainFxGroup = ~mainFxGroup ?? Group.after(1); // after default group
    0.2.wait;
    ~mainComp = VSTPluginController( Synth( \mainFX, [ \in, 0, \out, 0 ], target: ~mainFxGroup , addAction: 'addToTail') );
    0.2.wait;
    // ~comp.open( "Auburn Sounds Couture.vst3" );
    ~mainComp.open( "RoughRider3.vst3" );
    1.wait;
    // s.sync;
    ~mainComp.readProgram("/home/skmecs/vst/roughRider.fxp");
    {~mainComp.editor;}.defer(4);
}

defer{ Server.killAll };
// Quarks.install("https://github.com/madskjeldgaard/plugins.quark")
// Plugins.gui
q = q ? ();
" >>>>>>>>>>>>> startup GERAL <<<<<<<<<<<<<".postln;
"\n**********  loading serverConfig:  **********".postln;
// more latency gives more accurate timing and quantizing. Less latency gives better instrument feeling with imediate response
s.latency = 0.02;
s.options
.numOutputBusChannels_(10)
.numAudioBusChannels_(128 * 16)	 // for proxy usage: lots of ar bus space 1024
.zeroConf_(false)
.memSize_(8192 * 32)		 // 512 MB This memory is used to allocate synths! 64 increase this if you get "alloc failed" messages
.hardwareBufferSize_(256)
.maxNodes_(1024 * 32)		 // lots of synth nodes 16 increase this if you are getting drop outs and the message "too many nodes"
.maxSynthDefs_(1024 *2)
.numWireBufs_(64 * 32)			 // fat synthdefs need lots of interconnects
// .numOutputBusChannels_(2)
.numBuffers_(1024 * 32) // increase this if you need to load more samples
// .device_("Fireface 400 (297)")	// device name
.numInputBusChannels_(2);
// .sampleRate_(4800)
// .device = "ASIO : ASIO4ALL v2"; // set this to your hardware output channel size, if necessary
s.recChannels_(10);

s.waitForBoot({
// asdasdas
    t = TempoClock.default;
    q.mod = MFunc(); "q.mod = MFunc\n".postString;
    Pdefn(\scale, Scale.choose(7, 12)).source.name;
    wait(0.2);
    "interface/proxySpace_Stuff.scd".loadRelative;
    wait(0.2);
    "interface/linkClock_Stuff.scd".loadRelative;
    wait(0.2);
    "libs/_SynthLib.scd".loadRelative;
    wait(0.2);
    "FX/_fxFunc.scd".loadRelative;
    wait(0.2);
    "FX/_fxLib.scd".loadRelative;
    wait(0.2);
    "toca/swingfy.scd".loadRelative;
    wait(0.2);
    // "FX/mainFX.scd".loadRelative; // explode se a NDef abaixo estiver ligada
    wait(0.2);
    Ndef(\allOrbs).gui;
    (
     Ndef(\allOrbs, {
            var in = [InFeedback.ar([2,4,6,8],1),InFeedback.ar([3,5,7,9],1)];
            OffsetOut.ar(0, in)
        }).play;
    );
    wait(0.2);
    "FX/vstMainFX.scd".loadRelative;
    wait(0.2);
})

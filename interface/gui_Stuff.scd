{
    PdefnAllGui.new(Pdefn.all.size);
    wait(0.1);
    q.pxMixer = ProxyMixer(p, 16); // espaço para 16 proxies
    wait(0.1);
    // q.pxMixer.parent.alwaysOnTop_(true);
    q.ndefMixer = NdefMixer(s);
    wait(0.1);
    // if you have JITLibExtensions installed, try ProxyMeter to see the proxy levels:
    if ( \ProxyMeter.asClass.notNil ) {
        ProxyMeter.addMixer(q.pxMixer);
        ProxyMeter.addMixer(q.ndefMixer)
    };
    wait(0.1);
    s.makeWindow;
    wait(0.1);
    s.meter(2,10);
    wait(0.1);
    s.scope(2);
    wait(0.1);
}.defer(1);

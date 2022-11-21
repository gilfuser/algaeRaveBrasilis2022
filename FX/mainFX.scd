q.maMasta = MainFX(s, 2, [/* '00_in',*/'leakDC','ampFin']);
// q.maMasta.add('00_in', 1);
q.maMasta.add('leakDC', 1);
q.maMasta.add('ampFin', 1);
q.maMasta.gui("MAIN!", 20);


/*
MainFX.clear('localhost')
*/

Ndef('zz_mainfx').set('postAmp', 1.5);

"MAIN FX - LOADED".postString;

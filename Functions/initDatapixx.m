function initDatapixx(dlp)

PsychDataPixx('Open');
Datapixx('SetPropixxDlpSequenceProgram',dlp);
Datapixx('RegWr');
WaitSecs(2);

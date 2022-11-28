function prepScreen
%
% 2016 by Martin Rolfs

global scr const

scr.rate    = 12;           % number of stimulus updates per refresh
scr.subDist = 2700;         % subject distance [mm]
scr.width   = 2000;         % screen width [mm]
scr.refr    = scr.rate*120; % vertical refresh frequency (Hz)
scr.fd      = 1/scr.refr;   % frame duration (sec)

% flipmethod = 0 -> Sync flips. [ Slow but easy ]
% flipmethod = 1 -> Async flips for some sort of triplebuffering. [ Potentially faster but more difficult ]
% flipmethod = 2 -> Fastest method, but only available on Linux with open-source graphics drivers.
scr.flipmethod = 0; % 

% initialize data pixx connection for 1440-Hz display control (5)
initDatapixx(5);

% Initialize for unified KbName's and normalized 0 - 1 color range:
PsychDefaultSetup(2);

% May or may not help: 
PsychImaging('PrepareConfiguration');

if scr.flipmethod >= 1
    % For drawing during async flip - aka effective triplebuffering -
    % to work, we need a virtual framebuffer. This also helps for 
    % flipmethod == 2 on Linux with double-buffering, because it
    % decouples swap completion aka availability of the backbuffer
    % from stimulus rendering and composition for 4 quadrant 3 RGB
    % channels, so those steps can run while a bufferswap is still
    % pending.
    PsychImaging('AddTask', 'General', 'UseVirtualFramebuffer');
end

% 16 bpc float is enough for a net 8 bpc output precision:
PsychImaging('AddTask', 'General', 'FloatingPoint16Bit');

% If there are multiple displays guess that one without the menu bar is the
% best choice.  Dislay 0 has the menu bar.
scr.allScreens = Screen('Screens');
scr.expScreen  = max(scr.allScreens);

% Open a window.  Note the new argument to OpenWindow with value 2,
% specifying the number of buffers to the onscreen window.
scr.main = PsychImaging('OpenWindow', scr.expScreen, 0.5);
scr.textRenderer = Screen('Preference', 'TextRenderer',1);
scr.textAntiAliasing = Screen('Preference', 'TextAntiAliasing',1);
%scr.textAntiAliasing = Screen('Preference', 'TextAntiAliasing',2);

% Setup for fast display mode, producing the final image in onscreen window
% 'w', for presentation at rate 'rate' (4 or 12), with 'flipmethod'.
% Replace 0 with 1 for GPU load benchmarking - has some performance impact
% itself, but allows assessment of how much we make the graphics card sweat:
PsychProPixx('SetupFastDisplayMode', scr.main, scr.rate, scr.flipmethod, [], 0);

% Get a suitable offscreen window 'myimg' for drawing our stimulus:
scr.myimg = PsychProPixx('GetImageBuffer');

% change font size
Screen('TextFont',scr.main, 'Helvetica');
Screen('TextFont',scr.myimg, 'Helvetica');
Screen('TextSize', scr.main  , 20);
Screen('TextSize', scr.myimg , 20);

%%%%%%% load luminance calibration file %%%%%%%


% get information about  screen
% [scr.xres, scr.yres]    = Screen('WindowSize', scr.main);       % heigth and width of screen [pix]
scr.fd = Screen('GetFlipInterval',scr.main);    % frame duration [s]
scr.fd = scr.fd/scr.rate;


fprintf(1,'\n\nScreen runs at %.1f Hz.\n\n',1/scr.fd);

% determine th main window's center
[scr.centerX, scr.centerY] = WindowCenter(scr.myimg);
[scr.resX   , scr.resY   ] = WindowSize(scr.myimg);
scr.rect = [0 0 scr.resX scr.resY];

% Give the display a moment to recover from the change of display mode when
% opening a window. It takes some monitors and LCD scan converters a few seconds to resync.
WaitSecs(2);
% hide cursor if not in dummy mode
if ~(const.TEST==1)
    HideCursor(scr.main);
end

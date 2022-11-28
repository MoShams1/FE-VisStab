function prepStim
%
% 2008 by Martin Rolfs

global visual scr


visual.black = BlackIndex(scr.main);
visual.white = WhiteIndex(scr.main);

visual.bgColor = (visual.black+visual.white)/2;      % background color
visual.fgColor = visual.black;                      % foreground color
visual.inColor = visual.white-visual.bgColor;       % increment for full contrast

visual.ppd     = dva2pix(1,scr);   % pixel per degree

visual.scrCenter = [scr.centerX scr.centerY scr.centerX scr.centerY];

visual.fixCkRad = round(2*visual.ppd); % fixation check radius
visual.fixCkCol = visual.black;    % fixation check color

% boundary radius at saccade target
visual.boundRad = visual.fixCkRad;

visual.fNyquist = 0.5;


% create standard gabor
visual.procGaborPar = getGaborPars;
visual.procGaborTex = CreateProceduralGabor(scr.myimg, visual.procGaborPar.sizp, visual.procGaborPar.sizp, 0, [visual.bgColor visual.bgColor visual.bgColor 0],1,visual.inColor); 


% get priority of window activities to maximum
if IsLinux
    scr.priorityLevel = 1;
else
    scr.priorityLevel = MaxPriority(scr.main);
end

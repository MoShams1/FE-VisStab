function [data,eyeData] = runSingleTrial(td)
%
% td = trial design
%
% 2016 by Martin Rolfs

global scr visual keys const


% clear keyboard buffer
FlushEvents('KeyDown');

% Set the transparency for gabor patch
% Screen('BlendFunction', scr.myimg, GL_SRC_ALPHA, GL_ONE);

% predefine boundary information
cxm = td.fixa.loc(1);
cym = td.fixa.loc(2);
rad = visual.boundRad;
chk = visual.fixCkRad;

% draw trial information on operator screen
if ~const.TEST
    Eyelink('command','draw_box %d %d %d %d 15', (cxm-chk)*2, (cym-chk)*2, (cxm+chk)*2, (cym+chk)*2);
end
% generate Procedural Gabor textures
nStim = length(td.stims.pars.sizp);
sti.tex = visual.procGaborTex;
sti.vis = td.stims.pars.sizp;
sti.src = [zeros(2,nStim); sti.vis; sti.vis];
if length(sti.vis)==1
    sti.dst = CenterRectOnPoint(sti.src', 0, 0)';
else
    sti.dst = CenterRectOnPoint(sti.src , 0, 0) ;
end
% precompute stimulus positions
for f = 1:td.totNFr
    for s = 1:nStim
        stiFrames(f).dst(:,s) = sti.dst(:,s) + repmat(td.stim(s).posVec(:,f),2,1);
    end
end

% predefine time stamps
tFixaOn = NaN;  % t of fixation on
tStimOn = NaN;  % t of stimulus stream on
tStimOf = NaN;  % t of stimulus off
tRes    = NaN;  % t of response (if any)
tClr    = NaN;  % t of of clear screen

% set flags before starting stimulus stream
eyePhase  = 1;  % 1 is fixation phase, 2 is saccade phase
breakIt   = 0;
fixBreak  = 0;

% Initialize vectors to store data on timing
frameTimes   = NaN(1,td.totNFr);
% flip screen to start out time counter for stimulus frames
firstFlip = 0;nextFlip = 0;
while ~firstFlip
   firstFlip = PsychProPixx('QueueImage', scr.myimg);
end
% set frame count to 0
f = 0;
% get a first timestap
t = GetSecs;
while ~breakIt && f < td.totNFr % as long as all frames have not been displayed
    f = f+1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % stimulus presentation %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Screen('BlendFunction', scr.myimg, GL_ONE, GL_ZERO);
    for slo = 1:const.sloFactor
        Screen('FillRect', scr.myimg, visual.bgColor);
        % stimuli
        % Screen('BlendFunction', scr.myimg, GL_SRC_ALPHA, GL_ONE);
        if td.stims.vis(1,f)
            Screen('DrawTextures', scr.myimg, sti.tex, sti.src, stiFrames(f).dst, td.stims.pars.ori', [], [], [], [], kPsychDontDoRotation, [td.stims.pha(:,f), td.stims.pars.frqp', td.stims.pars.sigp', td.stims.amp(:,f), td.stims.pars.asp', zeros(nStim,3)]');
        end        
        % fixation
        if td.fixa.vis(f)
            drawFixation(td.fixa.col,td.fixa.loc);
        end
        % Flip
        nextFlip = PsychProPixx('QueueImage', scr.myimg);
    end
    %frameTimes(f) = GetSecs;
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % raise stimulus flags %
    %%%%%%%%%%%%%%%%%%%%%%%%

    % Send message that stimulus is now on
    if isnan(tFixaOn) && td.events(f)==1
        if ~const.TEST  ; Eyelink('message', 'EVENT_FixaOn'); end
        if  const.TEST>1; fprintf(1,'\nEVENT_FixaOn'); end
        tFixaOn = GetSecs;
    end
    if isnan(tStimOn) && td.events(f)==2
        if ~const.TEST  ; Eyelink('message', 'EVENT_StimOn'); end
        if  const.TEST>1; fprintf(1,'\nEVENT_StimOn'); end
        tStimOn = GetSecs;
    end
    if isnan(tStimOf) && td.events(f)==3
        if ~const.TEST  ; Eyelink('message', 'EVENT_StimOf'); end
        if  const.TEST>1; fprintf(1,'\nEVENT_StimOf'); end
        tStimOf = GetSecs;
    end
    
    % eye position check
    if const.TEST<2
        [x,y] = getCoord; % here, the mouse position is assessed
        
        switch eyePhase
            case 1      % fixation phase
                if sqrt((x-cxm)^2+(y-cym)^2)>chk    % check fixation in a circular area
                    fixBreak = 1;
                end
        end
    end
    if fixBreak
        breakIt = 1;    % fixation break
    elseif  td.sacReq<=0 &&  f == td.totNFr
        breakIt = 2;    % no saccade required, stop when stimulus is done
    end
end
lastFlip = 0;
addFlips = 0;
while ~lastFlip && ~nextFlip
    addFlips = addFlips+1;
    Screen('FillRect', scr.myimg, visual.bgColor);
    if td.fixa.vis(f)
        drawFixation(td.fixa.col,td.fixa.loc);
    end
    lastFlip = PsychProPixx('QueueImage', scr.myimg);
end
tStimOf = GetSecs - addFlips*scr.fd;
if ~const.TEST; Eyelink('message', 'EVENT_StimOf'); end
if  const.TEST; fprintf(1,'\nEVENT_StimOf'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keep fixation point on response screen %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Screen('BlendFunction', scr.myimg, GL_ONE, GL_ZERO);
newFrame = 0;
while ~newFrame
    Screen('FillRect', scr.myimg, visual.bgColor);
    % fixation
    if td.fixa.vis(f)
        drawFixation(td.fixa.col,td.fixa.loc);
    end
    newFrame = PsychProPixx('QueueImage', scr.myimg);
end

switch breakIt
    case 1
        data = 'fixBreak';
        if ~const.TEST; Eyelink('command','draw_text 100 100 15 Fixation break'); end
    otherwise
        % check for keypress
        % Snd('Play',[repmat(0.5,1,1050) linspace(0.5,0.0,50)].*[zeros(1,1000) sin(1:100)],5000);
        keyPress = 0;
        while ~keyPress
            [keyPress, tRes] = checkTarPress(keys.respButtons);
        end
        WaitSecs(td.aftKey);

        newFrame = 0;
        while ~newFrame
            Screen('FillRect', scr.myimg, visual.bgColor);
            newFrame = PsychProPixx('QueueImage', scr.myimg);
        end
        tClr = GetSecs;
        if ~const.TEST; Eyelink('message', 'EVENT_Clr'); end
        if  const.TEST; fprintf(1,'\nEVENT_Clr'); end
        
        %-------------------------%
        % PREPARE DATA FOR OUTPUT %
        %-------------------------%
        % collect trial information
        trialData = sprintf('%i\t%i\t%.3f\t%.3f\t%i\t%.3f\t%.3f\t%i\t%i\t%i',[td.fixpox td.fixpoy td.staAmp td.sac.sacDur*1000 td.staHor td.staVel td.spdFac td.iniPos td.motDis td.curDir]);

        % determine presentation times relative to 1st frame
        timeData  = sprintf('%i\t%i\t%i\t%i\t%i',round(1000*([tFixaOn tStimOn tStimOf tRes tClr]-tStimOn)));
        
        % determine response data
        keyRT = tRes - tStimOf;
        
        % get response, defined as 0/1 (-1 = up, 1 = down)
        if keys.respButtons(keyPress)==keys.resUp
            resp =-1;
        elseif keys.respButtons(keyPress)==keys.resDown
            resp = 1;
        end
        respData = sprintf('%i\t%i',round(1000*keyRT),resp);
        
        % get information about how timing of frames worked
        tStimFramesDisplayed = round((tStimOf-tStimOn)/scr.fd);
        tStimFramesRequested = td.stiNFr;
        frameData = sprintf('%i\t%i',tStimFramesDisplayed,tStimFramesRequested);

        % collect data for tab [10 x trialData, 5 x timeData, 2 x respData, 2 x frameData]
        data = sprintf('%s\t%s\t%s\t%s',trialData, timeData, respData, frameData);
end

function design = genDesign(subjectCode)
%
% Notes on the design structure:
%
% General info:
%   .nTrain - number of training trials
%   .nTrial - number of test trial
%
% Trial info (.trial is replaced by .train in practice trials):
%   .trial(t).
%
% 2016 by Martin Rolfs

global visual scr keys const %#ok<NUSED>

% randomize random
rand('state',sum(100*clock));

% standard (set = 0)saccade parameters main sequence parameters (Collewijn, 1988)
sacPars = getStandardSaccadeParameters(0);

% settings for fixation (before cue)
design.timFixD = 0.0500;                        % minimum fixation duration before cue onset [s]
design.timFixJ = 0.0500;                        % additional fixation duration jitter before cue onset [s]

% timing settings
design.timAfKe = 0.200;                         % recording time after keypress  [s]
design.iti     = 0.000;                         % inter-trial interval [s]

% onset settings for stimuli
design.timSti1 = 0.000;                         % stimulus onset re cue onset [s]
design.timStiD = 0.500;                         % stimulus stream duration    [s]

% for detection experiment:
% for quartet motion experiment:
design.frqStan = 1;                             % standard spatial frequency of stimulus movements
if const.TEST
    design.ampStan = 4:4:12;                    % standard amplitude of stimulus movements
    design.speedFac = [1/4 1/2 1/1.25 1.25];
    design.nBlocks = 1;
    design.nTrialsPerCellInBlock = 1;
else
    design.ampStan = 4:2:12;                    % standard amplitude of stimulus movements
    design.speedFac = [1/4 1/3 1/2 1/1.5 1/1.25 1 1.25];
    design.nBlocks = 10;
    design.nTrialsPerCellInBlock = 1;
end
% design.speedFac =  1;
design.horStan = [1];                           % horizontal as standard amplitude?
aspRatios = [1];
design.horXver = unique([1./aspRatios aspRatios]);
design.motDisp = [1];
design.dirCurve = [-1 1];   % -1 = up, 1 = down
design.ampCurve = 0.3;

% for each stimulus (column), determine start and end positions (each column is one option)
% start positions for each stimulus (each row is a different option, each
% column is a different stimulus)
design.posX0 = [-1; 1];
design.posY0 = [ 0; 0];

% number of stimuli
design.numStim = size(design.posX0,2);
design.numPos0 = size(design.posX0,1);

% other variables
design.fixPosX = 0;                        % eccentricity of fixation x (relative to screen center)
design.fixPosY = 0;                        % eccentricity of fixation y (relative to screen center)
design.tarPosX = 0;                        % eccentricity of target   x (relative to screen center)
design.tarPosY = 0;                        % eccentricity of target   y (relative to screen center)

ntpb = design.nTrialsPerCellInBlock*length(design.horXver)*length(design.speedFac)*length(design.ampStan)*length(design.frqStan)*length(design.horStan)*design.numPos0*length(design.motDisp)*length(design.dirCurve);
for b = 1:design.nBlocks
    t = 0;
    for itri = 1:design.nTrialsPerCellInBlock
        for asra = 1:length(design.horXver)
            % Note: Velocities and amplitudes are fully crossed.
            for sped = design.speedFac
                for amps = design.ampStan
                    for frqs = design.frqStan
                        for hors = design.horStan
                            for pos0 = 1:design.numPos0
                                for modi = design.motDisp
                                    for cudi = design.dirCurve
                                        t = t + 1;
                                        fprintf(1,'\n preparing trial %i ...',t);
                                        trial(t).trialNum = t; %#ok<*AGROW>
                                        
                                        % determine fixation position
                                        % (stimulus positions are relative to this)
                                        fixx  = design.fixPosX;
                                        fixy  = design.fixPosY;
                                        
                                        % motion info (used for stimulus motion)
                                        trial(t).staAmp = amps;
                                        trial(t).staHor = hors;
                                        trial(t).staDir = pi/2-trial(t).staHor*pi/2;
                                        trial(t).movVel = sacPars.V0*(1-exp(-amps/sacPars.A0));
                                        trial(t).sacDur =(sacPars.durPerDeg*amps+sacPars.durInt)/1000;
                                        
                                        % temporal trial settings
                                        % duration before target onset [frames]
                                        trial(t).fixNFr = round((design.timFixD + design.timFixJ*rand)/scr.fd);
                                        trial(t).fixDur = trial(t).fixNFr*scr.fd;
                                        % duration after target onset [frames]
                                        trial(t).stiNFr = round((design.timSti1 + design.timStiD)/scr.fd);
                                        trial(t).stiDur = trial(t).stiNFr*scr.fd;
                                        
                                        % calculate total stimulus duration
                                        trial(t).totNFr = trial(t).fixNFr + trial(t).stiNFr;
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        % generate flag streams for stimulus presentation %
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        
                                        % fixation
                                        fixBeg = 1;
                                        fixEnd = trial(t).totNFr;
                                        trial(t).fixa.vis = zeros(1,trial(t).totNFr);
                                        trial(t).fixa.vis(fixBeg:fixEnd) = 1;
                                        trial(t).fixa.loc = visual.scrCenter+round(visual.ppd*[fixx fixy fixx fixy]);
                                        trial(t).fixa.col = visual.black;
                                        
                                        % here comes the cool part:
                                        % stimuli
                                        stiBeg = trial(t).fixNFr + 1 + round(design.timSti1/scr.fd);
                                        stiEnd = stiBeg + trial(t).stiNFr - 1;
                                        
                                        % determine stimulus parameters
                                        trial(t).stims.locX = design.posX0(pos0,:)*amps/2;
                                        trial(t).stims.locY = design.posX0(pos0,:)*amps/2;
                                        trial(t).stims.pars = getGaborPars(design.numStim);
                                        
                                        % stimulus orientation should be
                                        % orthogonal to motion direction
                                        trial(t).stims.pars.ori(:) = 90 - hors*90;
                                        
                                        % set spatial frequency
                                        trial(t).stims.pars.frq(:) = frqs;
                                        trial(t).stims.pars.frqp(:)= frqs/visual.ppd;
                                        
                                        % simulate position shift as if saccade
                                        % (sigma defined in number of frames)
                                        % trial(t).sac = genSaccadePeakVelProfiled(sacPars,trial(t).staAmp,sped);
                                        trial(t).sac = genSaccadePeakVelConstant(sacPars,trial(t).staAmp,sped);
                                        eyeVec = zeros(1,trial(t).stiNFr);
                                        sacBeg = round(trial(t).stiNFr/2-(trial(t).sac.fraDur/2));
                                        sacEnd = sacBeg + trial(t).sac.fraDur - 1;
                                        eyeVec(sacBeg:sacEnd) = trial(t).sac.posVecNorm;
                                        eyeVec(1:(sacBeg-1)) = 0;
                                        eyeVec((sacEnd+1):end) = 1;
                                        for s = 1:design.numStim
                                            % initial positions of this stimulus
                                            % and amplitude based on aspect ratio
                                            if hors
                                                x0 = trial(t).fixa.loc(1) + design.posX0(pos0,s)*amps/2*visual.ppd;
                                                y0 = trial(t).fixa.loc(2) + design.posY0(pos0,s)*amps/2*visual.ppd*design.horXver(asra);
                                            else
                                                x0 = trial(t).fixa.loc(1) + design.posX0(pos0,s)*amps/2*visual.ppd*design.horXver(asra);
                                                y0 = trial(t).fixa.loc(2) + design.posY0(pos0,s)*amps/2*visual.ppd;
                                            end
                                            % motion always applied to standard direction
                                            % scale by actual motion amplitude and
                                            % translate degrees to pixels.
                                            [x, y] = pol2cart(trial(t).staDir,visual.ppd*amps*eyeVec);
                                            % add curvature to orthogonal direction
                                            a = visual.ppd*amps;
                                            h = design.ampCurve * a/2;
                                            r = (4*h^2+a^2)/(8*h);
                                            if hors
                                                y = y0 + cudi*(sqrt(r^2 - (x-a/2).^2)+h-r);
                                                x = x0 - sign(design.posX0(pos0,s)) * x;
                                            else
                                                x = x0 + cudi*(sqrt(r^2 - (y-a/2).^2)+h-r);
                                                y = y0 - sign(design.posY0(pos0,s)) * y;
                                            end
                                            % round positions to integers
                                            xVec = round(x);yVec = round(y);
                                            
                                            % define change in stimulus position across frames
                                            trial(t).stim(s).posVec = zeros(2,trial(t).totNFr);
                                            % displace from initial fixation position.
                                            trial(t).stim(s).posVec(:,stiBeg:stiEnd) = round([xVec;yVec]);
                                            
                                            % define frames in which stimulus is in motion
                                            inMotion = find((x > x(1) & x < x(end)) | (y > y(1) & y < y(end)));
                                        end
                                        % define change in internal velocity across frames
                                        velVec = zeros(1,length(stiBeg:stiEnd));
                                        trial(t).velVec = velVec;
                                        
                                        % desired stimulus frequency [Hz]
                                        trial(t).stims.tmpfrq = 0; % temporal frequency in Hz (cycles per second)
                                        trial(t).stims.evovel = (repmat(trial(t).velVec*trial(t).movVel,design.numStim,1) + repmat(trial(t).stims.tmpfrq ./ trial(t).stims.pars.frq',1,length(trial(t).velVec))); % desired stimulus velocity [dva per sec]
                                        
                                        % define phase change per frame for entire profile
                                        phaFra = scr.fd*trial(t).stims.evovel.*repmat(trial(t).stims.pars.frq'*360,1,length(trial(t).velVec));% phase change per frame [deg per fra]
                                        
                                        % define visibility and velocity
                                        trial(t).stims.vis = zeros(design.numStim,trial(t).totNFr);
                                        trial(t).stims.pha = zeros(design.numStim,trial(t).totNFr);
                                        trial(t).stims.vis(:,stiBeg:stiEnd) = 1;
                                        
                                        % make motion invisible on pure apparent motion trials
                                        if ~modi
                                            trial(t).stims.vis(:,stiBeg-1+inMotion) = 0;
                                        end
                                        
                                        % define phase for each frame
                                        trial(t).stims.pha(:,stiBeg:stiEnd) = cumsum(phaFra,2);
                                        % add same random phase to each stimulus
                                        % trial(t).stims.pha = trial(t).stims.pha + repmat(360*rand(design.numStim,1),1,trial(t).totNFr);
                                        trial(t).stims.pha = trial(t).stims.pha + repmat(0*ones(design.numStim,1),1,trial(t).totNFr);
                                        
                                        % define modulation of contrast across time
                                        ampVec = ones(1,length(stiBeg:stiEnd));
                                        ramDur = round((design.timStiD/5)/scr.fd);
                                        ramVec = normcdf(1:ramDur,ramDur/2,ramDur/6);
                                        ampVec(1:ramDur) = ramVec;
                                        ampVec(end:-1:(end-ramDur+1)) = ramVec;
                                        trial(t).stims.evoamp = repmat(trial(t).stims.pars.amp',1,length(ampVec)) .* repmat(ampVec,design.numStim,1);
                                        trial(t).stims.amp = zeros(design.numStim,trial(t).totNFr);
                                        trial(t).stims.amp(:,stiBeg:stiEnd) = trial(t).stims.evoamp;
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        % define critical events during stimulus presentation %
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        trial(t).events = zeros(1,trial(t).totNFr);
                                        trial(t).events(fixBeg) = 1;
                                        trial(t).events(stiBeg) = 2;
                                        trial(t).events(stiEnd) = 3;
                                        
                                        % time requirements for responses
                                        trial(t).aftKey = design.timAfKe;
                                        
                                        % store stimulus features
                                        trial(t).fixpox = fixx;
                                        trial(t).fixpoy = fixy;
                                        trial(t).iniPos = pos0;
                                        trial(t).motDis = modi;
                                        trial(t).aspRat = design.horXver(asra);
                                        trial(t).sacReq = 0;
                                        trial(t).curDir = cudi;
                                        trial(t).staVel = trial(t).sac.sacVel1;
                                        trial(t).spdFac = sped;
                                        
                                        % provide feedback on progress
                                        newFrame = 0;
                                        while ~newFrame
                                            Screen('FillRect', scr.myimg, visual.bgColor);
                                            Screen('FillArc' , scr.myimg, visual.black,visual.scrCenter+30*[-1 -1 1 1],0,360*((b-1)*ntpb+t)/(design.nBlocks*ntpb))
                                            newFrame = PsychProPixx('QueueImage', scr.myimg);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    r = randperm(t);
    design.b(b).trial = trial(r);
end
design.blockOrder = 1:b;

design.nTrialsPB = t;   % number of trials per Block

save(sprintf('%s.mat',subjectCode),'design','visual','scr','keys','const');


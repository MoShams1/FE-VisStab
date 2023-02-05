function design = runTrials(design,datFile,el)
%
% 2016 by Martin Rolfs

global scr visual const

% calibration interval
const.calibInt = 1000;

% preload important functions
% NOTE: adjusting timer with GetSecsTest
% has become superfluous in OSX
GetSecs;
WaitSecs(.2);
FlushEvents('keyDown');

% create data fid
datFid = fopen(datFile, 'w');

for b = 1:design.nBlocks
    block = design.blockOrder(b); %#ok<NASGU>
    
    if isfield(design.b(b),'train')
        ntTrain = length(design.b(b).train);
        ntTrial = length(design.b(b).trial);
    else
        ntTrain = 0;
        ntTrial = length(design.b(b).trial);
    end
    ntt = ntTrain + ntTrial;
    
    % declare iterators for trials
    t = 0; % trials
    gt = 0; % good/successful trials
    % declare variable fixBlock only at beginning
    if b==1 && t==0
        fixBlock = [];
    end
    %%%%%%%%%%%%
    % After saccade block, replace all posVec for subsequent fixation block
    %%%%%%%%%%%%
    if t == 0 && ~isempty(fixBlock)
        design.b(b) = fixBlock;
        fixBlock = [];
    end
    
    % test trials
    while t < ntt
        t = t + 1;
        trialDone = 0; %#ok<NASGU>
        if t <= ntTrain
            trial = t;
            td = design.b(b).train(trial);
        else
            trial = t-ntTrain;
            td = design.b(b).trial(trial);
        end
        
        if t == 1 || ~mod(trial,const.calibInt)           % calibration
            if ~const.TEST
                initDatapixx(0);
                calibresult = EyelinkDoTrackerSetup(el);
                if calibresult==el.TERMINATE_KEY
                    return
                end
                initDatapixx(5);
            end
            switch td.sacReq
                case  0
                    sacReqStr = 'Fixation';
                case  1
                    sacReqStr = 'Saccade';
            end
            perfFeedback(sprintf('Block %i of %i (%i trials left): %s.',b,design.nBlocks,ntt-t+1,sacReqStr),td.fixa.loc(1),td.fixa.loc(2));
        end
        
        % clean operator screen
        if const.TEST<2, Eyelink('command','clear_screen'); end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Eyelink Stuff Begins
        
        if ~const.TEST
            if Eyelink('isconnected')==el.notconnected		% cancel if eyeLink is not connected
                return
            end
        end
        
        if const.TEST<2
            % This supplies a title at the bottom of the eyetracker display
            Eyelink('command', 'record_status_message ''Block %d of %d, Trial %d of %d''', b, design.nBlocks, trial, ntt);
            % this marks the start of the trial
            Eyelink('message', 'TRIALID %d', trial);
        end
       
        ncheck = 0;
        fix    = 0;
        record = 0;
        while (fix~=1 || ~record) && const.TEST<2
            if ~record
                Eyelink('startrecording');	% start recording
                % You should always start recording 50-100 msec before required
                % otherwise you may lose a few msec of data
                WaitSecs(.1);
                if ~const.TEST
                    key=1;
                    while key~= 0
                        key = EyelinkGetKey(el);		% dump any pending local keys
                    end
                end
                % Eyelink('flushkeybuttons', 0 );		% reset keys and buttons from tracker
                
                err=Eyelink('checkrecording'); 	% check recording status
                if err==0
                    record = 1;
                    Eyelink('message', 'RECORD_START');
                else
                    record = 0;	% results in repetition of fixation check
                    Eyelink('message', 'RECORD_FAILURE');
                end
            end
            
            if fix~=1 && record
                Eyelink('command','clear_screen 0');
                % rubber([]);		% clean screen
                fix = checkFix(td);	% fixation is checked
                ncheck = ncheck + 1;
            end
            
            if fix~=1 && record
                % calibration, if maxCheck drift corrections did not succeed
                if ~const.TEST
                    initDatapixx(0);
                    calibresult = EyelinkDoTrackerSetup(el);
                    if calibresult==el.TERMINATE_KEY
                        return
                    end
                    initDatapixx(5);
                end
                record = 0;
            end
        end

        % Eyelink Stuff Ends
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if const.TEST<2
            Eyelink('message', 'TRIAL_START %d', trial);
            Eyelink('message', 'SYNCTIME');		% zero-plot time for EDFVIEW
        end
        
        % maximize priority of Matlab thread for trial execution
        scr.oldPriorityLevel = Priority(scr.priorityLevel);
        
        [data] = runSingleTrial(td);
        
            
        
        % set priority of Matlab thread back to normal
        Priority(scr.oldPriorityLevel);

        if ~const.TEST
            Eyelink('message', 'TRIAL_ENDE %d',  trial);
            Eyelink('stoprecording');
        end
        
        % go to next trial if fixation was not broken
        if strcmp(data,'fixBreak')
            trialDone = 0;
            
            feedback('Fixate, please.',td.fixa.loc(1),td.fixa.loc(2));
        elseif strcmp(data,'tooSlow')
            trialDone = 0;
            
            feedback('Faster, please.',td.fixa.loc(1),td.fixa.loc(2));
        else
            trialDone = 1;
            gt = gt +1;
            
            dataStr = sprintf('%i\t%i\t%s\n',b,trial,data); % print data to string
            fprintf(datFid,dataStr);                        % write data to datFile
            if ~const.TEST, Eyelink('message', 'TrialData %s', dataStr); end   % write data to edfFile
        end
        
        if const.TEST; fprintf(1,'\nTrial %i done\n\n',t-ntTrain); end
        
        if ~trialDone && (t-ntTrain)>0
            ntn = length(design.b(b).trial)+1;  % new trial number
            design.b(b).trial(ntn) = td;        % add trial at the end of the block
            ntt = ntt + 1;
            
            if const.TEST; fprintf(1,' ... trial added, now total of %i trials',ntt); end
        end
        WaitSecs(design.iti);
    end
    
    keyPress = perfFeedback(sprintf('Block %i of %i done.',b,design.nBlocks),td.fixa.loc(1),td.fixa.loc(2));
    
    % check if user pressed q for quit
    if keyPress == KbName('q')
        quitKey = perfFeedback('If you want to quit now, press y. Press any other key otherwise.',td.fixa.loc(1),td.fixa.loc(2));
        if quitKey == KbName('y')
            break
        end
    end
    
    % save design (including eyeData) of this block
    save(sprintf('%s_Block%i.mat',datFile(1:end-4),b),'design')
end

fclose(datFid); % close datFile

% end eye-movement recording
if ~const.TEST
    Screen(el.window,'FillRect',el.backgroundcolour);   % hide display
    WaitSecs(0.1);Eyelink('stoprecording');             % record additional 100 msec of data
end

rubber([]);
Screen('Drawtext', scr.myimg, 'Thank you, you have completed this part of the experiment.',100,100,visual.fgColor);
PsychProPixx('Flip',scr.myimg);
if const.TEST<2
    Eyelink('command','clear_screen');
    Eyelink('command', 'record_status_message ''ENDE''');
end
WaitSecs(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visibility of saccadic motion 2: Constant velocity %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 2016 by Martin Rolfs
% 
% Using a motion path discrimination task, this experiment tests if we can
% see saccade-like object movements provided certain combinations of
% movement duration and amplitude. 
% 

% In contrast to Version 02 (which used Gaussian velocity profiles with 
% ill-defined movement durations, Version 04 uses gamma-shaped velocity 
% profiles as suggested by Opstal & van Gisbergen (1987).

clear all; %#ok<*CLSCR>
clear mex;
clear functions;

addpath('Functions/','Data/');

home;
expStart=tic;

global const visual scr keys df %#ok<*NUSED>

const.TEST   = 2;   % test in dummy mode? 0=eyelink; 1=mouse; 2=no tracking
const.DOMEYE = 2;   % use dominant eye for fixation checks (1=left, 2=right)

% settings that impact the experiment
const.sloFactor= 1;% slow motion: draw every frame const.sloFactor times (1 = normal speed)

% define name of experiment (used in file names)
exptname='SLMD';

try
    newFile = 0;
    while ~newFile
        subjectCode = getSubjectCode(exptname);
        subjectCode = strcat('Data/',subjectCode);
        
        % create data file
        datFile = sprintf('%s.dat',subjectCode);
        if exist(datFile,'file')
            o = input('>>>> This file exists already. Should I overwrite it [y / n]? ','s');
            if strcmp(o,'y')
                newFile = 1;
            end
        else
            newFile = 1;
        end
    end
    
    % prepare screens
    prepScreen;
    
    % get response keys
    getKeyAssignment;
    
    % disable keyboard
    ListenChar(2);
    
    % prepare stimuli
    prepStim;
    
    % generate design
    design = genDesign(subjectCode);
    
    % initialize eyelink-connection
    if const.TEST<2
        [el, err]=initEyelinkNew(subjectCode(6:end));
        const.missingDataCode = el.MISSING_DATA;
        if err==el.TERMINATE_KEY
            return
        end
    else
        el=[];
    end
    
    % runtrials
    design = runTrials(design,datFile,el);
    
    % shut down everything
    reddUp;
catch me
    rethrow(me);
    reddUp; %#ok<UNRCH>
end

expDur=toc(expStart);

fprintf(1,'\n\nThis (part of the) experiment took %.0f min.',(expDur)/60);
fprintf(1,'\n\nOK!\n');


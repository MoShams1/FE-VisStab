clc
clear all
close all

tic

% #########################################################################

% SESSIOINS'S META DATA

subj = 'test ';  % keep it at four characters

timestamp = datetime('now');
timestamp = datestr(timestamp, 'yyyymmdd_HHMMSS');
save_file_name = ['task01_',timestamp,'_',subj,'.mat'];
save_directory = fullfile('..','data','cyc01',save_file_name);

% #########################################################################

% KEY PARAMETERS
% vel_coeffs_base = .2:.2:1.4;
vel_coeffs_base = 4 * ones(1,7);
phase_shift_base = [180, 180];
n_tr_per_cnd = 6;  % must be an even number
pause_dur_ms = 1000;  % pause at each reversal
flash_dur_ms = 50;
ref_rate = 480;
ncyc = 4;
gr_width_dva = 25; % 15,25,35
gr_height_dva = 5;
probe_replica_xoffset = -250;
probe_replica_yoffset = +100;

% #########################################################################

% SETUP SCREEN

%Check connection and open Datapixx if it's not open yet
isConnected = Datapixx('isReady');
if ~isConnected
    Datapixx('Open');
end

%Open a display on the Propixx
AssertOpenGL;
KbName('UnifyKeyNames');
screenID = 0;
[windowPtr,~] = Screen('OpenWindow', screenID, 0);

%Enable 1440 Hz mode (12 frames/flip), with sync flipping
% Datapixx('SetPropixxDlpSequenceProgram', 5);
Datapixx('SetPropixxDlpSequenceProgram', 2);
Datapixx('RegWrRd');

% PsychProPixx('SetupFastDisplayMode', windowPtr, 12, 0);
PsychProPixx('SetupFastDisplayMode', windowPtr, 4, 0);
stimulusBuffer = PsychProPixx('GetImageBuffer');

% #########################################################################

% SETUP STIMULUS PARAMETERS

ntrials = n_tr_per_cnd * length(vel_coeffs_base) * length(phase_shift_base);

%Set up some stimulus characteristics-- remember the final display will be
%halved resolution
dotRadius = 10;
dotColour = [255, 255, 255];
bkgColour = [.5,.5,.5]*255;
targetRadius = 100;
center = [960/2, 540/2];
ox = center(1);
oy = center(2);
                                           
% set probe parameters  
probe_vertical_offset = 70; 
probe_diam = dva2pix(1);  % probe diameter in dva
probeRect = [-probe_diam/2,-probe_diam/2,probe_diam/2,probe_diam/2]+[ox,oy,ox,oy];
red = [1,.4,.3]*255;
blue = [.1,.6,1]*255;
probeRect_rep = ...
    [-probe_diam/2,-probe_diam/2,probe_diam/2,probe_diam/2]+ ...
    [ox+probe_replica_xoffset,oy+probe_replica_yoffset, ...
    ox+probe_replica_xoffset,oy+probe_replica_yoffset];

% set grating parameters
cyc_dva = gr_width_dva / ncyc;
gr_width = dva2pix(gr_width_dva);
gr_height = dva2pix(gr_height_dva);
freq = ncyc/gr_width;  % cycles per pixel
phase_offset = 0;
contrast = 1;
squareRect = [-gr_width/2, -gr_height/2, gr_width/2, gr_height/2] + [ox,oy,ox,oy];
grating = CreateProceduralSineGrating(stimulusBuffer, gr_width, gr_height, [1,1,1,0]*.5);

% set motion parameters
pause_dur = pause_dur_ms * ref_rate / 1000;  % duration in frames

% gap period (inter-trial interval)
gap_dur_ms = 1000;
gap_dur = gap_dur_ms * ref_rate / 1000;
      
% set mouse/keyboard parameters
[mousex0,~] = GetMouse(windowPtr);  % initial mouse position
HideCursor();

% #########################################################################

% CREATE CONDITIONS

ind_shuffle = randperm(ntrials);

% create velocity conditions
vel_coeffs_vec = repelem(vel_coeffs_base, ntrials/length(vel_coeffs_base));
vel_coeffs_vec = vel_coeffs_vec(ind_shuffle);

% create phase-shift conditions
phase_shift_vec = repmat(repelem(phase_shift_base, ntrials/length(vel_coeffs_base)/length(phase_shift_base)), 1, length(vel_coeffs_base));
phase_shift_vec = phase_shift_vec(ind_shuffle);

% #########################################################################

% RUN SESSION

% disable keyboard
ListenChar(2);

% run opening screen
opening_text = '<spacebar> Begin      <escape> Abort';
% reset keyboard inputs
key_logic = zeros( 1,256);
while ~any(key_logic([KbName('space'), KbName('escape')]))
    Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);
    DrawFormattedText(stimulusBuffer, opening_text, 'center', 'center', [0 0 0])
    PsychProPixx('QueueImage', stimulusBuffer);
    % break the loop when space pressed
    [~, ~, key_logic] = KbCheck;
    if any(key_logic([KbName('space'), KbName('escape')]))
        break;
    end
end

for itrial = 1:ntrials
    
    % -----------------------------------
    
    % SET TRIAL-SPECIFIC PARAMETERS
    
    % extract phase shift and calculate max velocity per second
    phase_shift_deg = phase_shift_vec(itrial);
    amp_dva = gr_width_dva/ncyc * phase_shift_deg/360;
    vel_dva_per_s = mainsequence(amp_dva);
    vel_cyc_per_s = vel_dva_per_s / cyc_dva;
    
    % extract velocity coefficient, update the velocity, create motion
    % vector
    vel_coef = vel_coeffs_vec(itrial);    
    phase_vec_cyc = linspace(0, phase_shift_deg, ref_rate / (vel_cyc_per_s * vel_coef) * phase_shift_deg / 360);
    phase_vec_cyc_rev = fliplr(phase_vec_cyc);
    phase_vec_leg1 = [repelem(phase_vec_cyc(1),pause_dur), phase_vec_cyc(2:end-1)];
    phase_vec_leg2 = [repelem(phase_vec_cyc_rev(1),pause_dur), phase_vec_cyc_rev(2:end-1)];
    phase_vec_wrev = [phase_vec_leg1, phase_vec_leg2];  % w/ reversal
    
    % create flash vector
    flash_vec_leg1 = zeros(1,length(phase_vec_leg1));
    flash_vec_leg2 = zeros(1,length(phase_vec_leg2));
    flash_dur = flash_dur_ms * ref_rate / 1000;
    pause_wo_flash = pause_dur-flash_dur;
    flash_vec_leg1(pause_wo_flash/2+1:pause_wo_flash/2+flash_dur) = 1;
    flash_vec_leg2(pause_wo_flash/2+1:pause_wo_flash/2+flash_dur) = 2;
    flash_vec_wrev = [flash_vec_leg1, flash_vec_leg2];  % w/ reversal
    
    % -----------------------------------
    
    % RUN STIMULUS
    
    % reset space press but not escape press
    key_logic(KbName('space')) = 0;
    
    % run gap period
    for iframe = 1:gap_dur        
        Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);        
        PsychProPixx('QueueImage', stimulusBuffer);
    end
    
    counter = 1;
    
    while ~any(key_logic([KbName('space'), KbName('escape')]))
               
        %Clear our stimulusBuffer by creating an all-black background
        Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);
        
        % add fixation area 
        Screen('DrawLine', stimulusBuffer, [0 0 0], 0, 80, 1920, 80, 3);

        % draw grating
        phase = phase_offset + phase_vec_wrev(counter);
        Screen('DrawTexture', stimulusBuffer, grating, [], squareRect, [], [], [], [], [], [], ...
            [phase, freq, contrast, 0]);
        if flash_vec_wrev(counter) == 1
            % flash red probe
            Screen('FillOval', stimulusBuffer, red, probeRect-[0 probe_vertical_offset/2 0 probe_vertical_offset/2]);
        elseif flash_vec_wrev(counter) == 2
            % flash blue probe
            Screen('FillOval', stimulusBuffer, blue, probeRect+[0 probe_vertical_offset/2 0 probe_vertical_offset/2]);
        end

        % scan for mouse position
        [mousex,~] = GetMouse(windowPtr);
        % cal position change from the initial position
        mousex_dif = mousex-mousex0;
        mouse_dif_v = [mousex_dif,0,mousex_dif,0] / 5;

        % add replica probes
        Screen('FillOval', stimulusBuffer, red, probeRect_rep-mouse_dif_v);
        Screen('FillOval', stimulusBuffer, blue, probeRect_rep+mouse_dif_v);

        %Add the new image to our queue; the queue flips automatically once
        %4 frames have been added
        PsychProPixx('QueueImage', stimulusBuffer);

        counter = counter +1;

        %If we run out of target locations, loop back to the beginning
        if counter > length(phase_vec_wrev)
            counter = 1;
        end

        % break the loop when space or escape pressed
        [~, ~, key_logic] = KbCheck;
        if any(key_logic([KbName('space'), KbName('escape')]))
            break;
        end
    end
    
    % quit session if 'escape' pressed
    if key_logic(KbName('escape'))
        % re-activate keyboard
        ListenChar(0);
        break;
    end
    
    % -----------------------------------
    
    % SAVE DATA
    
    % store mouse position after space bar press
    new_data.itrial = itrial;
    new_data.ref_rate = ref_rate;
    new_data.phase_shift_deg = phase_shift_deg;
    new_data.amp_dva = amp_dva;
    new_data.velmax_dva_per_s = vel_dva_per_s;
    new_data.vel_coef = vel_coef;
    new_data.vel_dva_per_s = vel_dva_per_s * vel_coef;
    new_data.perceived_offset_pix = mousex_dif * 2;
    new_data.perceived_offset_dva = pix2dva(mousex_dif * 2);
        
    % save trial's response
    if itrial == 1
        data = new_data;
        save(save_directory, 'data')
    else
        load(save_directory, 'data');
        data = [data; new_data];
        save(save_directory, 'data')  
    end
end


%Close
Datapixx('SetPropixxDlpSequenceProgram', 0);
Datapixx('RegWrRd');

PsychProPixx('DisableFastDisplayMode', 1);
Screen('Closeall');

session_duration_min = toc/60

% #########################################################################

% FUNCTIONS

function pix = dva2pix(dva)
pix_per_dva = cal_pix_per_dva();
pix = round(dva * pix_per_dva);
end

function dva = pix2dva(pix)
pix_per_dva = cal_pix_per_dva();
dva = round(pix / pix_per_dva, 2);
end

function pix_per_dva = cal_pix_per_dva()
mon_width = 30.41;  % cm
mon_dist = 70;  % cm
pix_per_dva = atan(mon_width / (2 * mon_dist)) * 2 * 180 / pi;
end

function vmax = mainsequence(amp)
slope = 2.7;
intercept = 23;
c = 1.64;
vmax = (c * amp) / ((slope * amp) + intercept) * 1000;
end
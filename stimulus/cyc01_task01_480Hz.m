clc
clear all
close all

% #########################################################################

% SESSIOINS'S META DATA
subj = 'test';
n_tr_per_cnd = 20;

vel_portion_vec = .2:.2:1.4;
% vel_portion_vec = 1 * ones(1,6);
ntrials = n_tr_per_cnd * length(vel_portion_vec);

timestamp = datetime('now');
timestamp = datestr(timestamp, 'yyyymmdd_HHMMSS');
save_file_name = ['task01_',timestamp,'_',subj,'.mat'];
save_directory = fullfile('..','data','cyc01',save_file_name);

% #########################################################################

% KEY PARAMETERS
pause_dur_ms = 1000;  % pause at each reversal
flash_dur_ms = 50;
ref_rate = 480;

% #########################################################################
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
probe_diam = dva2pix(1);  % probe diameter in dva
probeRect = [-probe_diam/2,-probe_diam/2,probe_diam/2,probe_diam/2]+[ox,oy,ox,oy];
red = [1,.4,.3]*255;
blue = [.1,.6,1]*255;
probe_replica_xoffset = 150;
probe_replica_yoffset = -200;
probeRect_rep = ...
    [-probe_diam/2,-probe_diam/2,probe_diam/2,probe_diam/2]+ ...
    [ox+probe_replica_xoffset,oy+probe_replica_yoffset, ...
    ox+probe_replica_xoffset,oy+probe_replica_yoffset];

% set grating parameters
ncyc = 3;
gr_width_dva = 15;
gr_height_dva = 10;
cyc_dva = gr_width_dva / ncyc;
gr_width = dva2pix(gr_width_dva);
gr_height = dva2pix(gr_height_dva);
freq = ncyc/gr_width;  % cycles per pixel
phase_offset = 0;
contrast = .7;
squareRect = [-gr_width/2, -gr_height/2, gr_width/2, gr_height/2] + [ox,oy,ox,oy];
grating = CreateProceduralSineGrating(stimulusBuffer, gr_width, gr_height, [1,1,1,0]*.5);


% set motion parameters
pause_dur = pause_dur_ms * ref_rate / 1000;  % duration in frames
phase_shift_deg = 360;
% if cnd == 1
%     phase_shift_deg = 360;
% elseif cnd == 2
%     phase_shift_deg = 180;
% end
amp_dva = gr_width_dva/ncyc * phase_shift_deg/360;
vel_dva_per_s = mainsequence(amp_dva);
vel_cyc_per_s = vel_dva_per_s / cyc_dva;

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
vel_portion_coeffs = repelem(vel_portion_vec, n_tr_per_cnd);
vel_portion_coeffs = vel_portion_coeffs(ind_shuffle);

% create phase-shift conditions
phase_shift_vec = repmat(repelem([180, 360], n_tr_per_cnd/2), 1, length(vel_portion_vec));
phase_shift_vec = phase_shift_vec(ind_shuffle);

% #########################################################################

for itrial = 1:ntrials
    
    % #####################################################################
    
    % SET TRIAL-SPECIFIC PARAMETERS
    
    vel_coef = vel_portion_coeffs(itrial);
    
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
    
    % #####################################################################    
    
    % RUN STIMULUS
    
    % reset keyboard inputs
    key_logic = zeros(1,256);
    
    % run gap period
    for iframe = 1:gap_dur
        Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);
        PsychProPixx('QueueImage', stimulusBuffer);
    end
    
    counter = 1;
    
    while ~any(key_logic([KbName('space'), KbName('escape')]))

        %Clear our stimulusBuffer by creating an all-black background
        Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);

        % draw grating
        phase = phase_offset + phase_vec_wrev(counter);
        Screen('DrawTexture', stimulusBuffer, grating, [], squareRect, [], [], [], [], [], [], ...
            [phase, freq, contrast, 0]);
        if flash_vec_wrev(counter) == 1
            % flash red probe
            Screen('FillOval', stimulusBuffer, red, probeRect);
        elseif flash_vec_wrev(counter) == 2
            % flash blue probe
            Screen('FillOval', stimulusBuffer, blue, probeRect);
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
        break;
    end
    
    % #####################################################################    
    
    % SAVE DATA
    
    % store mouse position after space bar press
    new_data.itrial = itrial;
    new_data.ref_rate = ref_rate;
    new_data.phase_shift_deg = phase_shift_deg;
    new_data.amp_dva = amp_dva;
    new_data.vel_dva_per_s = vel_dva_per_s;
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
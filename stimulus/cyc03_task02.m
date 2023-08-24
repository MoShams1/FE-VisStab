
% Mo Shams 2023 <MShamsCBR@gmail.com>

% The grating moves 180 deg.
% The grating moves in two ways: uni-directional, or reversive.
% The direction of motion is unpredictable.
% Does the unperceivable motion induce shift?

clc
clear
close all

tic

% #########################################################################

% SESSIOINS'S META DATA

subj = 'test ';  % keep it at four characters

timestamp = datetime('now');
timestamp = datestr(timestamp, 'yyyymmdd_HHMMSS');
save_file_name = ['task02_',timestamp,'_',subj,'.mat'];
save_directory = fullfile('..','data','cyc03',save_file_name);

% #########################################################################

% KEY PARAMETERS
vel_coeffs_base = 8;
phase_shift_base = 180;
flash_order_base = [-1, 1];  % [-1] bottom-first,  [1] top-first
cycle_mode_base = [1, 2];  % [1] uni-directional,  [2] bi-directional
firstleg_dir_base = [-1, 1]; %  [-1] leftward,  [1] rightward
gr_width_base = 25;
contrast_base = [1];
n_tr_per_cnd = 2;
pause_dur_ms = 1000;  % pause at each reversal
flash_dur_ms = 50;
ref_rate = 1440;
ncyc = 4;
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


if ref_rate == 480
    %Enable 480 Hz mode (4 frames/flip), with sync flipping
    Datapixx('SetPropixxDlpSequenceProgram', 2);  % 480 Hz
    PsychProPixx('SetupFastDisplayMode', windowPtr, 4, 0);  % flip every 4 frames
elseif ref_rate == 1440
    %Enable 1440 Hz mode (12 frames/flip), with sync flipping
    Datapixx('SetPropixxDlpSequenceProgram', 5);  % 1440 Hz
    PsychProPixx('SetupFastDisplayMode', windowPtr, 12, 0);  % flip everz 12 frames
else
    disp('Invalid refresh rate.')
end

Datapixx('RegWrRd');
stimulusBuffer = PsychProPixx('GetImageBuffer');

% #########################################################################

% SETUP STIMULUS PARAMETERS

ntrials = n_tr_per_cnd...
    * length(vel_coeffs_base)...
    * length(phase_shift_base)...
    * length(flash_order_base)...
    * length(gr_width_base)...
    * length(cycle_mode_base)...
    * length(firstleg_dir_base)...
    * length(contrast_base);

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
probe_voffset = 50;

% set moving marker parameters
marker_y = dva2pix(7.5);
marker_width = dva2pix(.5);
marker_height = dva2pix(.5);

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

% create flash order conditions
flash_order_vec = repmat(repelem(flash_order_base, ntrials/length(vel_coeffs_base)/length(phase_shift_base)/length(flash_order_base)), 1, length(phase_shift_base)*length(vel_coeffs_base));
flash_order_vec = flash_order_vec(ind_shuffle);

% create grating width conditions
gr_width_vec = repmat(repelem(gr_width_base, ntrials/length(vel_coeffs_base)/length(phase_shift_base)/length(flash_order_base)/length(gr_width_base)), 1, length(phase_shift_base)*length(vel_coeffs_base)*length(flash_order_base));
gr_width_vec = gr_width_vec(ind_shuffle);

% create cycle mode conditions
cycle_mode_vec = repmat(repelem(cycle_mode_base, ntrials/length(vel_coeffs_base)/length(phase_shift_base)/length(flash_order_base)/length(gr_width_base)/length(cycle_mode_base)), 1, length(phase_shift_base)*length(vel_coeffs_base)*length(flash_order_base)*length(gr_width_base));
cycle_mode_vec = cycle_mode_vec(ind_shuffle);

% create first leg direction conditions
firstleg_dir_vec = repmat(repelem(firstleg_dir_base, ntrials/length(vel_coeffs_base)/length(phase_shift_base)/length(flash_order_base)/length(gr_width_base)/length(cycle_mode_base)/length(firstleg_dir_base)), 1, length(phase_shift_base)*length(vel_coeffs_base)*length(flash_order_base)*length(gr_width_base)*length(cycle_mode_base));
firstleg_dir_vec = firstleg_dir_vec(ind_shuffle);

% create contrast conditions
contrast_vec = repmat(repelem(contrast_base, ntrials/length(vel_coeffs_base)/length(phase_shift_base)/length(flash_order_base)/length(gr_width_base)/length(cycle_mode_base)/length(firstleg_dir_base)/length(contrast_base)), 1, length(phase_shift_base)*length(vel_coeffs_base)*length(flash_order_base)*length(gr_width_base)*length(cycle_mode_base)*length(firstleg_dir_base));
contrast_vec = contrast_vec(ind_shuffle);

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
    DrawFormattedText(stimulusBuffer, opening_text, 'center', 'center', [0 0 0]);
    PsychProPixx('QueueImage', stimulusBuffer);
    % break the loop when space pressed    
    [~, ~, key_logic] = KbCheck;    
    if any(key_logic([KbName('space'), KbName('escape')]))
        KbWait([], 1);
        break;
    end
end

pause_trials = linspace(1,ntrials+1, 4+1);  % to have (4 blocks w/ 3 breaks)
pause_trials(1) = [];
pause_trials(end) = [];

for itrial = 1:ntrials
    
    if any(itrial == pause_trials)
        passed_block = find(itrial == pause_trials);
        % run pause screen
        opening_text = ['Blocks done: ', num2str(passed_block), '/', num2str(length(pause_trials)+1)];
        command_text = '<spacebar> Continue';
        % reset keyboard inputs
        key_logic = zeros( 1,256);
        while ~any(key_logic([KbName('space'), KbName('escape')]))
            Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);
            DrawFormattedText(stimulusBuffer, opening_text, 'center', 'center', [0 0 0]);
            DrawFormattedText(stimulusBuffer, command_text, 'center', 200, [0 0 0]);
            PsychProPixx('QueueImage', stimulusBuffer);
            % break the loop when space pressed
            [~, ~, key_logic] = KbCheck;
            if any(key_logic([KbName('space'), KbName('escape')]))
                KbWait([], 1);
                break;
            end
        end
    end
    
    
    % -----------------------------------
    
    % SET TRIAL-SPECIFIC PARAMETERS
    
    % set grating parameters
    gr_width_dva = gr_width_vec(itrial);
    cyc_dva = gr_width_dva / ncyc;
    gr_width = dva2pix(gr_width_dva);
    gr_height = dva2pix(gr_height_dva);
    freq = ncyc/gr_width;  % cycles per pixel
    phase_offset = 0;
    contrast = contrast_vec(itrial);
    squareRect = [-gr_width/2, -gr_height/2, gr_width/2, gr_height/2] + [ox,oy,ox,oy];
    grating = CreateProceduralSineGrating(stimulusBuffer, gr_width, gr_height, [1,1,1,0]*.5);
    
    % extract phase shift and calculate max velocity per second
    phase_shift_deg = phase_shift_vec(itrial);
    amp_dva = gr_width_dva / ncyc * phase_shift_deg/360;
    vel_dva_per_s = mainsequence(amp_dva);
    vel_cyc_per_s = vel_dva_per_s / cyc_dva;
    
    % extract velocity coefficient, update the velocity, create motion
    % vector
    vel_coef = vel_coeffs_vec(itrial);
    phase_vec_cyc = linspace(0, phase_shift_deg, ref_rate / (vel_cyc_per_s * vel_coef) * phase_shift_deg / 360);
    phase_vec_cyc_rev = fliplr(phase_vec_cyc);
    phase_vec_leg1 = [repelem(phase_vec_cyc(1),pause_dur), phase_vec_cyc(2:end-1)];
    
    % apply cycle mode
    if cycle_mode_vec(itrial) == 2
        phase_vec_leg2 = [repelem(phase_vec_cyc_rev(1),pause_dur), phase_vec_cyc_rev(2:end-1)];
    else
        phase_vec_leg2 = phase_vec_leg1 + 180;  % bi-directional
    end    
    phase_vec_full = [phase_vec_leg1, phase_vec_leg2];  % uni-directional
    
    % apply first leg direction
    if firstleg_dir_vec(itrial) == 1
        phase_vec_full = -phase_vec_full;
    end
    
    % create flash vector
    flash_vec_leg1 = zeros(1,length(phase_vec_leg1));
    flash_vec_leg2 = zeros(1,length(phase_vec_leg2));
    flash_dur = flash_dur_ms * ref_rate / 1000;
    pause_wo_flash = pause_dur-flash_dur;
    flash_vec_leg1(pause_wo_flash/2+1:pause_wo_flash/2+flash_dur) = 1;
    flash_vec_leg2(pause_wo_flash/2+1:pause_wo_flash/2+flash_dur) = 2;
    flash_vec_full = [flash_vec_leg1, flash_vec_leg2];
    
    % create moving marker's jump time
    marker_times = find(diff(flash_vec_full) > 0);
    
    % randomize flash order
    flash_order = flash_order_vec(itrial);
    if flash_order == 1
        flash_upper = 1;
        flash_bottom = 2;
    else
        flash_upper = 2;
        flash_bottom = 1; 
    end
    
    % set moving marker's starting point
    marker_x = ox-(firstleg_dir_vec(itrial)*gr_width/2);
    % set moving marker's direction sign
    sign_flip = 1;
    
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
        phase = phase_offset + phase_vec_full(counter);
        Screen('DrawTexture', stimulusBuffer, grating, [], squareRect, [], [], [], [], [], [], ...
            [phase, freq, contrast, 0]);
        % add flashes
        if flash_vec_full(counter) == flash_upper
            % flash upper probe
            Screen('DrawLine', stimulusBuffer, [0 0 0 0], ox-5, oy-10-probe_voffset/2, ox, oy-probe_voffset/2, 5);
            Screen('DrawLine', stimulusBuffer, [0 0 0 0], ox, oy-probe_voffset/2, ox+5, oy-10-probe_voffset/2, 5);
            Screen('DrawLine', stimulusBuffer, [255 255 255 0], ox-5, oy-10-probe_voffset/2, ox, oy-probe_voffset/2, 1);
            Screen('DrawLine', stimulusBuffer, [255 255 255 0], ox, oy-probe_voffset/2, ox+5, oy-10-probe_voffset/2, 1);
            
        elseif flash_vec_full(counter) == flash_bottom
            % flash bottom probe
            Screen('DrawLine', stimulusBuffer, [0 0 0 0], ox-5, oy+10+probe_voffset/2, ox, oy+probe_voffset/2, 5);
            Screen('DrawLine', stimulusBuffer, [0 0 0 0], ox, oy+probe_voffset/2, ox+5, oy+10+probe_voffset/2, 5);
            Screen('DrawLine', stimulusBuffer, [255 255 255 0], ox-5, oy+10+probe_voffset/2, ox, oy+probe_voffset/2, 1);
            Screen('DrawLine', stimulusBuffer, [255 255 255 0], ox, oy+probe_voffset/2, ox+5, oy+10+probe_voffset/2, 1);
        end        
        
        % add moving markers        
        if ismember(counter-720, marker_times)
            marker_x = marker_x + sign_flip*firstleg_dir_vec(itrial)*gr_width/8;
            % flip the sign after each show in reversal condition
            if cycle_mode_vec(itrial) == 2
                sign_flip = -sign_flip;
            end
        end
        Screen('FillOval', stimulusBuffer, [0, 0, 0], [marker_x marker_y marker_x+marker_width marker_y+marker_height]);
        
        % scan for mouse position
        [mousex,~] = GetMouse(windowPtr);
        % cal position change from the initial position
        mousex_dif = (mousex-mousex0)/5;
        
        % add replica probes
        oxrep = ox+probe_replica_xoffset;
        oyrep = oy+probe_replica_yoffset;
        Screen('DrawLine', stimulusBuffer, [0 0 0 0], oxrep-5+mousex_dif/2, oyrep-10, oxrep+mousex_dif/2, oyrep, 5);
        Screen('DrawLine', stimulusBuffer, [0 0 0 0], oxrep+mousex_dif/2, oyrep, oxrep+5+mousex_dif/2, oyrep-10, 5);
        Screen('DrawLine', stimulusBuffer, [255 255 255 0], oxrep-5+mousex_dif/2, oyrep-10, oxrep+mousex_dif/2, oyrep, 1);
        Screen('DrawLine', stimulusBuffer, [255 255 255 0], oxrep+mousex_dif/2, oyrep, oxrep+5+mousex_dif/2, oyrep-10, 1);
        
        Screen('DrawLine', stimulusBuffer, [0 0 0 0], oxrep-5-mousex_dif/2, oyrep+10, oxrep-mousex_dif/2, oyrep, 5);
        Screen('DrawLine', stimulusBuffer, [0 0 0 0], oxrep-mousex_dif/2, oyrep, oxrep+5-mousex_dif/2, oyrep+10, 5);
        Screen('DrawLine', stimulusBuffer, [255 255 255 0], oxrep-5-mousex_dif/2, oyrep+10, oxrep-mousex_dif/2, oyrep, 1);
        Screen('DrawLine', stimulusBuffer, [255 255 255 0], oxrep-mousex_dif/2, oyrep, oxrep+5-mousex_dif/2, oyrep+10, 1);
        
        %Add the new image to our queue; the queue flips automatically once
        %4 (at 480 Hz) or 12 (at 1440 Hz) frames have been added
        PsychProPixx('QueueImage', stimulusBuffer);
        
        counter = counter +1;
        
        %If we run out of target locations, loop back to the beginning
        if counter > length(phase_vec_full)
            counter = 1;
        end
        
        % break the loop when space or escape pressed
        [~, ~, key_logic] = KbCheck;
        if any(key_logic([KbName('space'), KbName('escape')]))
            KbWait([], 1);
            break;
        end
    end
    
    % quit session if 'escape' pressed
    if key_logic(KbName('escape'))
        KbWait([], 1);
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
    new_data.dur_frames = length(phase_vec_cyc);
    new_data.dur_ms = length(phase_vec_cyc) / ref_rate * 1000;
    new_data.flash_order = flash_order;
    new_data.perceived_offset_pix = mousex_dif;
    new_data.perceived_offset_dva = pix2dva(mousex_dif);
    
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
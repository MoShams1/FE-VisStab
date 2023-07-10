clc
clear all
close all

cnd = 1;

%Check connection and open Datapixx if it's not open yet
isConnected = Datapixx('isReady');
if ~isConnected
    Datapixx('Open');
end

%Open a display on the Propixx
AssertOpenGL;
KbName('UnifyKeyNames');
screenID = 0;                                           %Change this value to change display
[windowPtr,~] = Screen('OpenWindow', screenID, 0);

%Enable 1440 Hz mode (12 frames/flip), with sync flipping
% Datapixx('SetPropixxDlpSequenceProgram', 5);
Datapixx('SetPropixxDlpSequenceProgram', 2);
Datapixx('RegWrRd');

PsychProPixx('SetupFastDisplayMode', windowPtr, 12, 0);
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
probe_dur = 40;  % duration in frames
probe_diam = dva2pix(1);  % probe diameter in dva
probeRect = [-probe_diam/2,-probe_diam/2,probe_diam/2,probe_diam/2]+[ox,oy,ox,oy];
red = [1,.4,.3]*255;
blue = [.1,.6,1]*255;
probe_replica_xoffset = -250;
probe_replica_yoffset = 0;
probeRect_rep = ...
    [-probe_diam/2,-probe_diam/2,probe_diam/2,probe_diam/2]+ ...
    [ox+probe_replica_xoffset,oy+probe_replica_yoffset, ...
    ox+probe_replica_xoffset,oy+probe_replica_yoffset];

% set grating parameters
if cnd == 1
    ncyc = 3;
elseif cnd == 2
    ncyc = 1.5;
end
gr_width_dva = 10;
gr_height_dva = 10;
gr_width = dva2pix(gr_width_dva);
gr_height = dva2pix(gr_height_dva);
freq = ncyc/gr_width;  % cycles per pixel
if cnd == 1
    phase_offset = 0;
elseif cnd == 2
    phase_offset = -90;
end
contrast = 5;
squareRect = [-gr_width/2, -gr_height/2, gr_width/2, gr_height/2] + [ox,oy,ox,oy];
grating = CreateProceduralSineGrating(stimulusBuffer, gr_width, gr_height, [0,0,0,0]);

% set motion parameters
ref_rate = 1440/3;
if cnd == 1
    phase_shift = 360;
elseif cnd == 2
    phase_shift = 180;
end
cyc_len_dva = gr_width_dva/ncyc;
speed_dva_per_s = mainsequence(cyc_len_dva);
% speed_cyc_per_s = speed_dva_per_s / cyc_len_dva;
speed_cyc_per_s = 1;
phase_vec_cyc = linspace(0, phase_shift, ref_rate/speed_cyc_per_s);  % one cycle
phase_vec_cyc_rev = fliplr(phase_vec_cyc);
phase_vec_leg1 = [repelem(phase_vec_cyc(1),probe_dur), phase_vec_cyc(2:end-1)];
phase_vec_leg2 = [repelem(phase_vec_cyc_rev(1),probe_dur), phase_vec_cyc_rev(2:end-1)];
phase_vec_wrev = [phase_vec_leg1, phase_vec_leg2];  % w/ reversal

% set mouse/keyboard parameters
[mousex0,~] = GetMouse(windowPtr);  % initial mouse position
% HideCursor();

% RUN THE TASK

% reset keyboard inputs
key_logic = zeros(1,256);

% run pause period
for iframe = 1:ref_rate
    Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);
    PsychProPixx('QueueImage', stimulusBuffer);
end

counter = 1;

while 1
    
    %Clear our stimulusBuffer by creating an all-black background
    Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);
    
    % draw grating
    phase = phase_offset + phase_vec_wrev(counter);
    Screen('DrawTexture', stimulusBuffer, grating, [], squareRect, [], [], [], [], [], [], ...
        [phase, freq, contrast, 0]);
    if phase_vec_wrev(counter) == 0
        % flash red probe
        Screen('FillOval', stimulusBuffer, red, probeRect);
    elseif phase_vec_wrev(counter) == phase_shift
        % flash blue probe
        Screen('FillOval', stimulusBuffer, blue, probeRect);
    end
    
    % scan for mouse position
    [mousex,~] = GetMouse(windowPtr);
    % cal position change from the initial position
    mousex_dif = mousex-mousex0;
    mouse_dif_v = [mousex_dif,0,mousex_dif,0];
            
    % add replica probes
    Screen('FillOval', stimulusBuffer, red, probeRect_rep-mouse_dif_v);
    Screen('FillOval', stimulusBuffer, blue, probeRect_rep+mouse_dif_v);
    
    %Add the new image to our queue; the queue flips automatically once
    %12 frames have been added
    PsychProPixx('QueueImage', stimulusBuffer);
    
    counter = counter +1;
    
    %If we run out of target locations, loop back to the beginning
    if counter > length(phase_vec_wrev)
        counter = 1;
    end
    
    %Keypress to exit
    [keyIsDown, ~, ~, ~] = KbCheck;
    if keyIsDown
        break
    end
end

%Close
Datapixx('SetPropixxDlpSequenceProgram', 0);
Datapixx('RegWrRd');

PsychProPixx('DisableFastDisplayMode', 1);
Screen('Closeall');

% #######################################################################################

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
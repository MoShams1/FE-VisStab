clc;
clear;
close all;

% skip synchronization test for Mac
Screen('Preference', 'SkipSyncTests', 1);

% set window parameters
screen_number = 0;
bg_color = [1 1 1]*255 / 2;
[win, dim] = Screen('OpenWindow', screen_number, bg_color);
ox = dim(3)/2;
oy = dim(4)/2;

% set motion parameters
ref_rate = 120;
speed = 2;  % dva per sec
phase_vec_base = linspace(0,180,speed*ref_rate);
phase_vec = [phase_vec_base(1:end-1), fliplr(phase_vec_base(2:end))];

% set grating parameters
ncyc = 3;
gr_width = dva2pix(speed * 2 * ncyc);
gr_height = dva2pix(10);
freq = ncyc/gr_width;
contrast = 5;
squareRect = [-gr_width/2, -gr_height/2, gr_width/2, gr_height/2] + [ox,oy,ox,oy];

% set probe parameters
probe_d = dva2pix(1);
probeRect = [-probe_d/2,-probe_d/2,probe_d/2,probe_d/2]+[ox,oy,ox,oy];

% set fixation mark parameters
text_color = [0 0 0];
text_y = 'center';
text_x = dva2pix(20);

iphase = 0;
for irep = 1:2
    for iphase = phase_vec

        % add fixation mark
        DrawFormattedText(win, '+', text_x, text_y, text_color);

        % add grating
        phase = iphase;
        gabor = CreateProceduralSineGrating(win, gr_width, gr_height, [0,0,0,0]);
        Screen('DrawTexture', win, gabor, [], squareRect, [], [], [], [], [], [], ...
            [phase, freq, contrast, 0]);

        if iphase == 0
            % flash red probe
            Screen('FillOval', win, [1,0,0]*255, probeRect)
        elseif iphase == 180
            % flash blue probe
            Screen('FillOval', win, [0,0,1]*255, probeRect)
        end

        HideCursor();
        Screen('Flip', win);

%         WaitSecs(.1);

    end
end

Screen('CloseAll');


function pix = dva2pix(theta)
mon_width = 30.41;  % cm
mon_dist = 70;  % cm
pix_per_deg = atan(mon_width/(2*mon_dist)) * 2 * 180 / pi;
pix = round(theta*pix_per_deg);
end
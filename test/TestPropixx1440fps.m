%% script to test whether the Propixx properly works at 1440 fps
% by Richard Schweitzer, 11/2022

clear all
close all

% try 5 Hz flicker to experience a nice infinite looming effect

%% Demo specifications
use_1440fps = 1;                % use Propixx? set 0 zero to test in dummy mode
desired_n_frames_per_polarity = 12; % how many frames per polarity?
demo_duration = 10;          % for how long should the demo run? (in seconds)
center_rect_width_pix = 200; % size of center rectangle for flicker (in pixels)
center_rect_height_pix = 200;
low_high_offset = 0.05;      % 0: maximum and minimum luminance, 0.5: no luminance change
skip_sync_tests = 0;        % set to 1 if you want skip ptb3 synch tests
use_flipmethod = 0;         % you should always use flipmethod 0, as only this one gives your reliable flip timestamps

%% Screen specifications
scr.dist  = 180.0;           % subject distance (cm)
scr.width = 150.0;           % physical width of the screen (cm)
if use_1440fps == 1  % half the fullHD resolution        
    scr.graphics_card_rate = 120; % refresh rate of graphics card
    scr.rate  = 12;             % number of stimulus updates per refresh
    scr.resx = 1920/2;
    scr.resy = 1080/2;
else % fullHD in the dummy mode
    scr.graphics_card_rate = 120; % refresh rate of graphics card
    scr.rate  = 1;             % number of stimulus updates per refresh
    scr.resx = 1920;
    scr.resy = 1080;
end
scr.fd = 1 / (scr.graphics_card_rate * scr.rate); % what's the duration of one frame?
scr.winCenterX = scr.resx / 2;
scr.winCenterY = scr.resy / 2;
scr.ppd = scr.dist * 2*tan(((1)/2)*pi/180) / (scr.width/scr.resx);

%% Setup screen
PsychDefaultSetup(2);
scr.id = max(Screen('Screens'));
scr.black = BlackIndex(scr.id);
scr.white = WhiteIndex(scr.id);
scr.gray = GrayIndex(scr.id);
scr.bg = scr.gray; % this is our background
if skip_sync_tests
    Screen('Preference', 'SkipSyncTests', 1); 
end
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
if use_1440fps == 1
    PsychDataPixx('Open');
    PsychImaging('AddTask', 'General', 'UseDataPixx');
    PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange'); 
    PsychImaging('AddTask', 'General', 'UseVirtualFramebuffer');
end
% open window
[scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.id, scr.bg);
scr.ifi = Screen('GetFlipInterval', scr.win);
scr.graphics_card_rate_empirical = round(1 / scr.ifi);
assert(scr.graphics_card_rate==scr.graphics_card_rate_empirical, ...
    'the measured frame rate is different from the specified frame rate!');
HideCursor;
if use_1440fps == 1
    % setup display mode
    PsychProPixx('SetupFastDisplayMode', scr.win, scr.rate, use_flipmethod, [], 0); % calibfilename=[], no benchmarking
    % Get a suitable offscreen window 'myimg' for drawing our stimulus:
    scr.myimg = PsychProPixx('GetImageBuffer');
    % enter dlp mode
    Datapixx('SetPropixxDlpSequenceProgram', 5);
    Datapixx('RegWrRd');
    WaitSecs(1);
end
% font for feedback
if use_1440fps == 0
    Screen('TextFont', scr.win, ...
        '-unregistered-latin modern sans-medium-r-normal--0-0-0-0-p-0-iso8859-1');
end
% Priority mode!
scr.topPriorityLevel = MaxPriority(scr.win);
Priority(scr.topPriorityLevel);
WaitSecs(0.1);

%% run the presentation sequence
% pre-allocate the data
frame_timings = NaN(ceil(demo_duration/scr.fd), 4);

% first flip as reference
first_flip = ClearScreenFull(scr, use_1440fps);
if use_flipmethod == 2 && first_flip == 1
    first_flip = GetSecs;
end

% run the presentation for the entire duration
flipped = 0; % is set to 1 once the flip has occurred
flipped_count = 0; % increment of 1 if a flip has occurred
draw_high = 1; % 1: high luminance, 0: low luminance
frame_i = 0; % counting the individual frames
polarity_frame_i = 0;
while (GetSecs-first_flip) <= demo_duration
    % 
    frame_i = frame_i + 1;
    polarity_frame_i = polarity_frame_i + 1;
    % clear screen
    ClearScreen(scr, use_1440fps);
    % now draw the center rectangle
    if draw_high == 1
        polarity_now = 1;
        DrawRect(scr, use_1440fps, scr.white-low_high_offset, ...
            [scr.winCenterX, scr.winCenterY], ...
            [center_rect_width_pix, center_rect_height_pix]);
        if polarity_frame_i >= desired_n_frames_per_polarity
            draw_high = 0;
            polarity_frame_i = 0;
        end
    else
        polarity_now = 0;
        DrawRect(scr, use_1440fps, scr.black+low_high_offset, ...
            [scr.winCenterX, scr.winCenterY], ...
            [center_rect_width_pix, center_rect_height_pix]);
        if polarity_frame_i >= desired_n_frames_per_polarity
            draw_high = 1;
            polarity_frame_i = 0;
        end
    end
    % draw to buffer
    preFlip_t = GetSecs - first_flip;
    if use_1440fps == 1
        flipped = PsychProPixx('QueueImage', scr.myimg);
        if use_flipmethod == 2 && flipped == 1
            flipped = GetSecs;
        end
    else
        flipped = Screen('Flip', scr.win);
    end
    if flipped ~= 0
        flipped_time = flipped - first_flip;
        flipped_count = flipped_count + 1;
    else
        flipped_time = NaN;
    end
    % save the data
    frame_timings(frame_i, :) = [frame_i, preFlip_t, flipped_time, polarity_now];
end

% last flip to clear the screen
last_flip = ClearScreenFull(scr, use_1440fps);
if use_flipmethod == 2 && last_flip == 1
    last_flip = GetSecs;
end
WaitSecs(0.1);

%% close Screen
ShowCursor;
sca;
if use_1440fps == 1
    % end high priority
    Priority(0);
    % go back to full HD mode
    Datapixx('SetPropixxDlpSequenceProgram', 0);
    Datapixx('RegWrRd');
    WaitSecs(0.1);
    Datapixx('Close');
end

%% some results
disp(['Number of flips: ', num2str(flipped_count)]);
disp(['Predicted number of flips: ', num2str(demo_duration/scr.ifi)]);

% do we have dropped frames?
flip_times = frame_timings(~isnan(frame_timings(:,3)), 3);
flip_counters = frame_timings(~isnan(frame_timings(:,3)), 1);
disp(['Any flip counters not dividable by 12: ', num2str(any(mod(flip_counters, 12)~=0))]);
flip_times_diff = [NaN; diff(flip_times)];
disp(['Number of dropped frames: ', num2str(sum(flip_times_diff>9))]);
% the time between drawings to the buffer:
preflip_times = frame_timings(:,2);
preflip_times_diff = [NaN; diff(frame_timings(:,2))];
% combine these in a plot
figure;
plot(flip_times, flip_times_diff*1000, '.', ...
    preflip_times, preflip_times_diff*1000, '.');




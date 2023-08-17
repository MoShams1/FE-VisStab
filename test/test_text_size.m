% Clear the workspace and the screen

clc
close all;
clearvars;


% Psychtoolbox setup
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1); % Skip some sync tests for better compatibility

% Get the screen number
screenNumber = max(Screen('Screens'));

% Define black and white colors
whiteColor = WhiteIndex(screenNumber);
blackColor = BlackIndex(screenNumber);

% Open the window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, whiteColor);

% Get the size of the window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Define the center of the screen
xCenter = screenXpixels / 2;
yCenter = screenYpixels / 2;

Screen('DrawLine', window, [0 0 0 0], 100, 100, 200, 200, 7);
Screen('DrawLine', window, [0 0 0 0], 200, 200, 300, 100, 7);

Screen('DrawLine', window, [1 1 1 0], 100, 100, 200, 200, 3);
Screen('DrawLine', window, [1 1 1 0], 200, 200, 300, 100, 3);


% Flip to the screen
Screen('Flip', window);

WaitSecs(3);

Screen('Closeall');

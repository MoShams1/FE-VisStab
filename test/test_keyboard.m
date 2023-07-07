addpath('/Users/mohammad/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/Psychtoolbox-3/Psychtoolbox/PsychBasic')

% Initialize Psychtoolbox
PsychDefaultSetup(2);

% Get the keyboard device index
devices = PsychHID('Devices');
keyboardIndex = [];
for i = 1:length(devices)
    if strcmp(devices(i).usageName, 'Keyboard')
        keyboardIndex = devices(i).index;
        break;
    end
end

if isempty(keyboardIndex)
    error('No keyboard device found.');
end

% Start listening for key presses
ListenChar(2);

fprintf('Press any key to test keyboard input...\n');

while true
    % Check for a key press
    [~, ~, keyCode] = KbCheck(keyboardIndex);
    if any(keyCode)
        break;
    end
end

fprintf('Key pressed: %s\n', KbName(find(keyCode)));

% Stop listening for key presses
ListenChar(0);

% Close any open PTB windows
sca;

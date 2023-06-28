clc, clear, close all

% skip syncronization test for mac
Screen('Preference', 'SkipSyncTests', 1);

% create window
screen_number = 0;
bg_color = [255 255 255] ./ 2;
[win, dim] = Screen('OpenWindow', screen_number, bg_color);
ox = dim(3)/2;
oy = dim(4)/2;

% create text
text_color = [0 0 0];
text_x = 'center';
text_y = 'center';
DrawFormattedText(win, '+', text_x, text_y, text_color);

% create square
squareSize = 150;
squareWidth = 5;
squareColor = [0 0 0];
squareRect = [-squareSize, -squareSize, squareSize, squareSize] + [ox, oy, ox, oy];
Screen('FrameRect', win, squareColor, squareRect, squareWidth);

HideCursor();
Screen('Flip', win);

WaitSecs(3);

Screen('CloseAll');
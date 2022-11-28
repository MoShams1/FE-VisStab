function [x,y,t] = getCoord

global const scr

if const.TEST
	[x,y,~] = GetMouse( scr.main );         % get gaze position from mouse	
    t = GetSecs*1000; % we need time in millisecond range
else
	evt = Eyelink('newestfloatsample');	
	x   = evt.gx(const.DOMEYE)/2;			
	y   = evt.gy(const.DOMEYE)/2;
    t   = evt.time;
end

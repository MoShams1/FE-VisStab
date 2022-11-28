function drawGoSignal(col,loc)
%
% 2010 by Martin Rolfs

global scr visual

pu = visual.ppd*0.1;
Screen('FillOval',scr.myimg,col,loc+round([-pu -pu pu pu]));


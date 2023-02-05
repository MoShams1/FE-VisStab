function drawFixation(col,loc)
%
% 2016 by Martin Rolfs

global scr visual

pu = visual.ppd*0.1;
Screen('FrameOval',scr.myimg,col,loc+round([-pu -pu pu pu]),pu);


function sacc = getSaccadeVector(sac,sacAmp,movDur)
%
% 2016 by Martin Rolfs

global visual scr

% calculate regular saccade duration for this amplitude
sacDur = scr.fd*round(((sac.durPerDeg*sacAmp+sac.durInt)/1000)/scr.fd);

if nargin<3
    movDur = sacDur;
end

% skewness
sacSkw = a * sacDur + b;
% gamma parameter
sacGam = 4/sacSkw^2;
% velocity
sacVel = sacAmp * (a*c)/(sacSkw-b);

% sample time according to frame duration
sFrames = 0:scr.fd:(scr.fd*round(movDur*sacDur/scr.fd));
tFrames = 0:scr.fd:(scr.fd*1000);

movAmp = sacAmp * visual.ppd;

curPos = round(movAmp * gamcdf(tFrames,sacGam,1/1000));
sacBeg = find(curPos == 0,1,'last');
curDur = (find(curPos < movAmp,1,'last') + sacBeg)*scr.fd;

% scaling parameter
sacBet = (movDur*sacDur/curDur)/1000;

% position to be used for gabor patch
eyePosVec = round(movAmp * gamcdf(sFrames,sacGam,sacBet));
eyeVelVec = round(movAmp * gampdf(sFrames,sacGam,sacBet));

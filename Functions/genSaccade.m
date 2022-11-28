function sac = genSaccade(sacPars,sacAmp,movDur)
%
% 2016 by Martin Rolfs

global visual scr

% calculate regular saccade duration for this amplitude
sac.sacAmp = sacAmp;
sac.sacDur = scr.fd*round(((sacPars.durPerDeg*sac.sacAmp+sacPars.durInt)/1000)/scr.fd);

if nargin<3
    sac.movDur = sac.sacDur;
else
    sac.movDur = movDur;
end

% skewness
sac.sacSkw = sacPars.vel_a * sac.sacDur + sacPars.vel_b;
% gamma parameter
sac.gamma = 4/sac.sacSkw^2;
% velocity
sac.sacVel = sac.sacAmp * (sacPars.vel_a*sacPars.vel_c)/(sac.sacSkw-sacPars.vel_b);

% sample time according to frame duration
slowFac = sac.movDur/sac.sacDur;
sFrames = 0:scr.fd:(scr.fd*round(slowFac*sac.sacDur/scr.fd));
tFrames = 0:scr.fd:(scr.fd*1000);

sac.movAmp = round(sac.sacAmp * visual.ppd);

% helper variables to get saccade profile to the right length
curPos = round(sac.movAmp * gamcdf(tFrames,sac.gamma,1/1000));
% current duration of the saccade (duration until position reaches end)
curDur = (find(curPos < sac.movAmp,1,'last') + 1)*scr.fd;

% scaling parameter
sac.beta = (slowFac*sac.sacDur/curDur)/1000;

% position to be used for gabor patch
sac.posVecNorm = gamcdf(sFrames,sac.gamma,sac.beta);
sac.velVecNorm = gampdf(sFrames,sac.gamma,sac.beta);
sac.posVecPixx = round(sac.movAmp*sac.posVecNorm);
sac.velVecPixx = round(sac.movAmp*sac.velVecNorm);

% duration of movement in frames
sac.fraDur = length(sac.posVecNorm);







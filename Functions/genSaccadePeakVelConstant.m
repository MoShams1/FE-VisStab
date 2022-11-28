function sac = genSaccadePeakVelConstant(sacPars,sacAmp,veloFac)
%
% 2016 by Martin Rolfs

global visual scr

% function describing velocity profile
constFun = @(t,value) value*ones(size(t));

% calculate regular saccade duration for this amplitude
sac.sacAmp = sacAmp;
sac.sacDur = scr.fd*round(((sacPars.durPerDeg*sac.sacAmp+sacPars.durInt)/1000)/scr.fd);

if nargin<3
    veloFac = 1;
end

% velocity
sac.sacVel1 = veloFac * sacPars.vel_c*sac.sacAmp/sac.sacDur;

% determine motion duration
sac.motDur = scr.fd*round((sac.sacAmp/sac.sacVel1)/scr.fd);

% sample time according to frame duration
t = 0:scr.fd:sac.motDur;

% movement amplitude in pixels
sac.movAmp = round(sac.sacAmp * visual.ppd);

% position to be used for gabor patch
v = constFun(t,1);
% normalize to a sum of 1
sac.velVecNorm = v /sum(v);
sac.posVecNorm = cumsum(sac.velVecNorm);
sac.velVecDegr = sac.sacAmp*sac.velVecNorm;
sac.posVecDegr = sac.sacAmp*sac.posVecNorm;
sac.velVecPixx = round(visual.ppd*sac.velVecDegr);
sac.posVecPixx = round(visual.ppd*sac.posVecDegr);

% duration of movement in frames
sac.fraDur = length(sac.posVecNorm);

function sac = genSaccadePeakVel(sacPars,sacAmp,veloFac)
%
% 2016 by Martin Rolfs

global visual scr

% function describing velocity profile
gammaFun = @(t,gamma,beta) (t/beta).^(gamma-1) .* exp(-t/beta);

% calculate regular saccade duration for this amplitude
sac.sacAmp = sacAmp;
sac.sacDur = scr.fd*round(((sacPars.durPerDeg*sac.sacAmp+sacPars.durInt)/1000)/scr.fd);

if nargin<3
    veloFac = 1;
end

% skewness
sac.sacSkw = sacPars.vel_a * sac.sacDur + sacPars.vel_b;
% gamma parameter
sac.gamma = 4/sac.sacSkw^2;
% velocity
sac.sacVel1 = veloFac * sac.sacAmp * (sacPars.vel_a*sacPars.vel_c)/(sac.sacSkw-sacPars.vel_b);
sac.sacVel2 = veloFac * sacPars.V0*(1-exp(-sac.sacAmp/sacPars.A0));
sac.sacVel3 = veloFac * sacPars.vel_c*sac.sacAmp/sac.sacDur;

% sample time according to frame duration
tFrames = 0:scr.fd:(scr.fd*1000000);

% movement amplitude in pixels
sac.movAmp = round(sac.sacAmp * visual.ppd);

t = tFrames;
v = gammaFun(t,sac.gamma,1);
%%% i = (sac.sacAmp * (v/sum(v))) / scr.fd;

% curPos and curDur are needed to adjust movement's amplitude & duration
% current position profile of movement
curPos = round(sac.movAmp * cumsum(v)/sum(v));
% current duration of the saccade (time until position reaches final pixel)
curDur = (find(curPos < round(sac.movAmp),1,'last') + 1)*scr.fd;

% duration scaling parameter
%%% sac.beta = (sac.movDur/curDur);
sac.beta = (sac.sacDur/curDur);

% position to be used for gabor patch
t = 0:scr.fd:(scr.fd*round(sac.sacDur/scr.fd));
v = gammaFun(t,sac.gamma,sac.beta);
% normalize to a sum of 1
sac.velVecNorm = v /sum(v);
% adjust for the overestimation of the duration of the saccade
sac.durFact = max(sac.velVecNorm*sac.sacAmp)/(sac.sacVel1*scr.fd);
% and for the velocity factor
sac.beta = sac.beta * sac.durFact;
t = 0:scr.fd:(scr.fd*round(sac.durFact*sac.sacDur/scr.fd));
v = gammaFun(t,sac.gamma,sac.beta);
% normalize to a sum of 1
sac.velVecNorm = v /sum(v);
sac.posVecNorm = cumsum(sac.velVecNorm);
sac.velVecDegr = sac.sacAmp*sac.velVecNorm;
sac.posVecDegr = sac.sacAmp*sac.posVecNorm;
sac.velVecPixx = round(visual.ppd*sac.velVecDegr);
sac.posVecPixx = round(visual.ppd*sac.posVecDegr);

% duration of movement in frames
sac.fraDur = length(sac.posVecNorm);

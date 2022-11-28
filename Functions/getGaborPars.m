function par = getGaborPars(num)
%
% 2016 by Martin Rolfs

global visual

if nargin < 1
    num = 1;
end

for n = 1:num
    par.amp(n) = 1;             % amplitude; -amp/2:+amp/2, so 1 means full contrast
    par.frq(n) = 1.0;           % spatial frequency [cycles/deg]    - a big number gives you
    par.ori(n) = 0.0*pi;        % orientation [radians] - 0 and pi are vertical, pi/2 and 3*pi/2 are horizontal
    par.pha(n) = 0.0*pi;        % phase [radians]
    par.sig(n) = 1/3;           % std.dev. of Gaussian envelope [deg]
    par.siz(n) = 2*4*par.sig(n);% extent of the stimulus from center to border [deg]
    par.asp(n) = 1;             % aspect ratio of x vs y
    
    % transform to pixels
    par.frqp(n) = par.frq(n)/visual.ppd;
    par.sigp(n) = par.sig(n)*visual.ppd;
    par.sizp(n) = ceil(par.siz(n)*visual.ppd);
    par.sizp(n) = par.sizp(n) + ~mod(par.sizp(n),2);
end

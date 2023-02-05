function sac = getStandardSaccadeParameters(set)
%
% 2016 by Martin Rolfs

switch set
    case 0
        % standard main sequence parameters (Collewijn et al., 1988)
        sac.V0 = 450;
        sac.A0 = 7.9;
        sac.durPerDeg = 2.7;
        sac.durInt = 23;
        % standard velocity profile parameters (van Opstal & van Gisbergen, 1987)
        sac.vel_a = 3.26;   % according to van Opstal & van Gisbergen
        sac.vel_b = 0.77;   % according to van Opstal & van Gisbergen
        sac.vel_c = 1.64;   % according to van Opstal & van Gisbergen
    otherwise
        error('Saccade parameter set not specified!')
end
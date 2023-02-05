%{

Plot relations between different saccade parameters investicated in the
classic literature.

Mohammad Shams <MShamsCBR@gmail.com>
Feb 3, 2023

%}

clc
clear
close all

color = lines(7);

%{

Saccade main sequence
Collewijn 1988

        Vm = V0[1-exp(-A/A0)]

Vm: peak velocity
A : saccade amplitude
V0: constant, the asymptotic velocity limit
A0: constant, saccade amplitute at which the velocity is 63% of the peak

%}

V0 = 450;
A0 = 7.9;

A = 0:.5:30;
Vm = V0*(1-exp(-A/A0));

figure('Units','normalized','OuterPosition',[.01 .5 .5 .4])
sgtitle('Collewijn et al. 1988')
subplot(1,2,1)
plot(A, Vm, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none')
xlabel("Saccade Amplitude (dva)")
ylabel("Saccade Peack Velocity (dva/s)")

%{

Saccade duration as a function of saccade amplitude
Collewijn 1988

        D = (slope x A) + intercept  [D in msec]

%}

slope = 2.7;
intercept = 23;

D = slope * A + intercept;

subplot(1,2,2)
plot(A, D, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none')
xlabel("Saccade Amplitude (dva)")
ylabel("Saccade Duration (ms)")


%{

Saccade skewness as a function of saccade duration
van Opstal & van Gisbergen 1987

        S = a x D + b  [D in sec]

%}

a = 3.26;
b = 0.77;

D = (0:100) / 1000;  % in sec

S = a * D + b;

figure('Units','normalized','OuterPosition',[.1 .1 .8 .4])
sgtitle('van Opstal & van Gisbergen 1987')
subplot(1,3,1)
plot(D, S, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none')
xlabel("Saccade Duration (ms)")
ylabel("Saccade Skewness")

%{

Saccade peak velocity as a function of saccade amplitude and duration
van Opstal & van Gisbergen 1987

        Vm x D = c x A  [D in sec]

%}

c = 1.64;
D = [40 80 120] / 1000;

subplot(1,3,2)
hold on
for i = 1:numel(D)
    Vm = c * A ./ D(i);
    h(i) = plot(A, Vm, 'o', 'MarkerFaceColor', color(i,:), 'MarkerEdgeColor', 'none');
end
xlabel("Saccade Amplitude (dva)")
ylabel("Saccade Peak Velocity (dva/s)")
legend(h, {['D = ',num2str(D(1))], ['D = ',num2str(D(2))], ['D = ',num2str(D(3))]},...
    'Location','northwest')

%{

Saccade main sequence
van Opstal & van Gisbergen 1987

        Vm = (a x c) / (S - b) x A

%}

a = 3.26;
b = 0.77;
c = 1.64;
S = [.9 1 1.1];

subplot(1,3,3)
hold on
for i = 1:numel(S)
    Vm = ((a * c) / (S(i) - b)) * A;
    h(i) = plot(A, Vm, 'o', 'MarkerFaceColor', color(i,:), 'MarkerEdgeColor', 'none');
end
xlabel("Saccade Amplitude (dva)")
ylabel("Saccade Peak Velocity (dva/s)")
legend(h, {['S = ',num2str(S(1))], ['S = ',num2str(S(2))], ['S = ',num2str(S(3))]},...
    'Location','northwest')

%{

Saccade main sequence
van Opstal & van Gisbergen 1987 and Collewijn 1988
        
        Vm x D = c x A x 1000 [D in msec]
        D = (slope x A) + intercept  [D in msec]
            =>
        Vm = (c x A) / ((slope x A) + intercept) * 1000

%}

slope = 2.7;
intercept = 23;
c = 1.64;
A = 0:.5:30;
Vm_Opstal = (c * A) ./ ((slope * A) + intercept) * 1000;

V0 = 450;
A0 = 7.9;
Vm_Collewijn = V0*(1-exp(-A/A0));

figure('Units','normalized','OuterPosition',[.65 .5 .5 .4])
subplot(1,2,1)
hold on
h1 = plot(A, Vm_Opstal, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');
h2 = plot(A, Vm_Collewijn, 'o', 'MarkerFaceColor', color(2,:), 'MarkerEdgeColor', 'none');
xlabel("Saccade Amplitude (dva)")
ylabel("Saccade Peak Velocity (dva/s)")
legend([h1, h2], {'van Opstal & van Gisbergen 1987', 'Collewijn et al. 1988'},...
    'Location','southeast')

%{

Saccade velocity profile
van Opstal & van Gisbergen 1987§

Vt = t ^ (gamma - 1) x exp(-t)

        gamma = 4 / S^2
        S = a x D + b  [D in sec]
        D = (slope x A + intercept) / 1000  [D in sec]
           =>
        gamma = 4 / [a/1000 x (slope x A + intercept) + b] ^ 2

%}

slope = 2.7;
intercept = 23;
a = 3.26;
b = 0.77;
c = 1.64;
V0 = 450;
A0 = 7.9;
A = 10;

D = (slope * A + intercept) / 1000;  % in sec
S = a * D + b;
gamma = 4 / (S .^ 2);

t = 0:.1:20;
alpha = 1;
beta = 1;
Vt = alpha * ((t/beta) .^ (gamma - 1)) .* exp(-t/beta);
Vm_Opstal = (c * A) ./ ((slope * A) + intercept) * 1000;
Vm_Collewijn = V0*(1-exp(-A/A0));
gain_Opstal = Vm_Opstal / max(Vt);
gain_Collewijn = Vm_Collewijn / max(Vt);

sgtitle(['Saccade Amplitude = ', num2str(A), ' dva'])
subplot(1,2,2)
hold on
plot(t, gain_Opstal * Vt, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');
plot(t, gain_Collewijn * Vt, 'o', 'MarkerFaceColor', color(2,:), 'MarkerEdgeColor', 'none');
xlabel("Time (ms)")
ylabel("Saccade Peak Velocity (dva/s)")



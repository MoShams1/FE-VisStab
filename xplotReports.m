%close('all');
clear;
home;

addpath('/local/locallab/Documents/MATLAB/Toolboxes');
addpath('/local/locallab/Documents/MATLAB/Toolboxes/Palamedes');
addpath('/local/locallab/Documents/MATLAB/Toolboxes/PalamedesDemos');

% datFile = 'Data/SLMDSO01.dat';
% datFile = 'Data/SLMDRS01.dat';
datFile = 'Data/SLMDJH01.dat';
% datFile = 'Data/SLMDZK01.dat';

data = load(datFile);

timBinCenter = -(30*12):12:(3*12);

frameOff = data(:,21)-data(:,20);

staAmp = data(:, 5);
sacDur = data(:, 6);
staHor = data(:, 7);
staVel = data(:, 8);
spdFac = data(:, 9);

curDir = data(:,12);
report = data(:,19);

allAmp = unique(staAmp);
allVel = unique(staVel);
% allRat = unique(aspRat);
allFac = unique(spdFac);

col = colormap('lines');  % green
%col = col(round(linspace(1,size(col,1)-10,length(allAmp))),:);

%Nelder-Mead search options
options = PAL_minimize('options');  %decrease tolerance (i.e., increase
options.TolX = 1e-09;              %precision).
options.TolFun = 1e-09;
options.MaxIter = 10000;
options.MaxFunEvals = 10000;

% general fitting settings
%searchGrid.alpha  = 1:.05:length(allRat);       % structure defining grid to
searchGrid.beta   = 10.^(-1:.05:2); % search for initial values
searchGrid.gamma  = 0.5;            % type help PAL_PFML_Fit for more information
searchGrid.lambda = 0:.005:.1;
PF = @PAL_Logistic;                 % PF function

paramsFree = [1 1 0 1]; %[threshold slope guess lapse] 1: free, 0:fixed

% generate predictions
V0 = 450;A0 = 7.9;durPerDeg = 2.7;durInt = 23;
predDurs = durPerDeg*allAmp+durInt;
predVels = V0*(1-exp(-allAmp/A0));

figure;
li = 0;   % legend index
for a = 1:length(allAmp)
    for v = 1:length(allVel)
        idx = staAmp==allAmp(a) & staVel == allVel(v);
        
        % calculate % correct;
        pCor(a,v) = mean(report(idx)==curDir(idx));
        
        % calculate d'
        nHit = sum(report(idx)==-1 & curDir(idx)==-1);
        nFA  = sum(report(idx)==-1 & curDir(idx)== 1);
        if nHit==sum(curDir(idx)==-1);nHit = nHit-1;elseif nHit==0;nHit = 1;end
        if nFA ==sum(curDir(idx)== 1);nFA  = nFA -1;elseif nFA ==0;nFA  = 1;end
        dprime(a,v) = norminv(nHit/sum(curDir(idx)==-1)) - norminv(nFA/sum(curDir(idx)== 1));
    end
    % fit psychometric function
    % paramsFitted = PAL_PFML_Fit((1:length(allRat)), nHor(h,:), nAll(h,:), searchGrid, paramsFree, PF,...
    %     'lapseLimits',[0 1],'guessLimits',0.5,'searchOptions',options);
    
    idxNaN = isnan(dprime(a,:));
    subplot(2,2,1);
    hold('on');
    plot(predVels([a a]),[0 1],'--','color',col(a,:));
    plot(allVel(~idxNaN),pCor(a,~idxNaN),'o-','color',col(a,:),'MarkerFaceColor',col(a,:),'LineWidth',2);
    
    subplot(2,2,2);
    hold('on');
    plot(predVels([a a]),[0 10.05],'--','color',col(a,:));
    li = li + 1;
    % hPlot(li) = plot(searchGrid.alpha,PF(paramsFitted,searchGrid.alpha),'-','color',colContin(h,:),'linewidth',2);
    %hPlot(li) = plot(allDur,pCor(a,:),'o-','color',col(a,:),'MarkerFaceColor',col(a,:),'LineWidth',2);
    hPlot(li) = plot(allVel(~idxNaN),dprime(a,~idxNaN),'o-','color',col(a,:),'MarkerFaceColor',col(a,:),'LineWidth',2);
    label{li} = sprintf('%.2f deg',allAmp(a));
    
    subplot(2,2,3);
    hold('on');
    plot([1 1],[0 1],'--','color',col(a,:));
    plot(allFac,pCor(a,~idxNaN),'o-','color',col(a,:),'MarkerFaceColor',col(a,:),'LineWidth',2);
    
    subplot(2,2,4);
    hold('on');
    plot([1 1],[0 10.05],'--','color',col(a,:));
    plot(allFac,dprime(a,~idxNaN),'o-','color',col(a,:),'MarkerFaceColor',col(a,:),'LineWidth',2);
end

subplot(2,2,1);
xlabel('Peak velocity [deg/s]');
xlim([min(allVel)*0.5 1.1*max(allVel)]);
ylabel('Proportion correct');
ylim([0.45 1.05]);

set(gca,'Xtick',0:100:1000,'Ytick',0:0.1:1);

subplot(2,2,2);
xlabel('Peak velocity [deg/s]');
xlim([min(allVel)*0.5 1.1*max(allVel)]);
ylabel('d''');
ylim([0 4]);

l = legend(hPlot,label);
set(l,'box','off');%,'pos',[0.6408 0.3830 0.2567 0.1279]);

subplot(2,2,3);
xlabel('Factor applied to v_{peak}');
xlim([1/3 2+1/6]);
ylabel('Proportion correct');
ylim([0.45 1.05]);

set(gca,'Xtick',allFac,'Ytick',0:0.1:1);

subplot(2,2,4);
xlabel('Factor applied to v_{peak}');
xlim([1/3 2+1/6]);
ylabel('d''');
ylim([0 4]);

set(gca,'Xtick',allFac,'Ytick',0:0.5:5);


set(gcf,'Pos',[200 200 600 600]);


figure;

plot(staAmp,staVel,'ko');
hold('on');
vpred = V0*(1-exp(-(allAmp)/A0));
plot(allAmp,vpred,'r.-');



figure;

hold('on');

h = hist(frameOff,timBinCenter);

idxCor = timBinCenter>=-6 & timBinCenter<12;
bar(timBinCenter(idxCor),h(idxCor),'g','barwidth',12)
idxNeg = timBinCenter<-6;
bar(timBinCenter(idxNeg),h(idxNeg),'r','barwidth',1)
idxPos = timBinCenter>12;
bar(timBinCenter(idxPos),h(idxPos),'y','barwidth',1)

fprintf(1,'\nTrial had too many  frames: %2.1f',100*sum(frameOff<-6)/length(frameOff));
fprintf(1,'\nTrial had too few   frames: %2.1f',100*sum(frameOff>=12)/length(frameOff));
fprintf(1,'\nTrial had correct # frames: %2.1f',100*sum(frameOff>=-6 & frameOff<12)/length(frameOff));

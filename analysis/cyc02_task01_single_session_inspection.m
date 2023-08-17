clc
clear
close all

load ../data/cyc02/task01_20230727_123026_MS01.mat

norm_shift = true;

phase_180 = ([data.phase_shift_deg]==180)';
phase_360 = ([data.phase_shift_deg]==360)';

amp = [data.amp_dva]';

vel_coef = [data.vel_coef]';

flash_order = [data.flash_order]';
shift = [data.perceived_offset_dva]';
shift_abs = [data.perceived_offset_dva]';
shift_abs(flash_order==1) = -shift_abs(flash_order==1);

velcoef_set = unique(vel_coef);

for icoef = 1:length(velcoef_set)
    ind = (vel_coef == velcoef_set(icoef)) & phase_180;
    shift_mat_180(:,icoef) = shift_abs(ind) ./ amp(ind);

    ind = (vel_coef == velcoef_set(icoef)) & phase_180 & flash_order == 1;
    shift_mat_180_1(:,icoef) = mean(shift(ind) ./ amp(ind));

    ind = (vel_coef == velcoef_set(icoef)) & phase_180 & flash_order == -1;
    shift_mat_180_n1(:,icoef) = mean(shift(ind) ./ amp(ind));
end

for icoef = 1:length(velcoef_set)
    ind = (vel_coef == velcoef_set(icoef)) & phase_360;
    shift_mat_360(:,icoef) = shift_abs(ind) ./ amp(ind);

    ind = (vel_coef == velcoef_set(icoef)) & phase_360 & flash_order == 1;
    shift_mat_360_1(:,icoef) = mean(shift(ind) ./ amp(ind));

    ind = (vel_coef == velcoef_set(icoef)) & phase_360 & flash_order == -1;
    shift_mat_360_n1(:,icoef) = mean(shift(ind) ./ amp(ind));
end

x = velcoef_set;
y180 = mean(shift_mat_180,1);
y360 = mean(shift_mat_360,1);
err180 = SE(shift_mat_180);
err360 = SE(shift_mat_360);

figure('units','normalized','outerposition',[.2 .3 .5 .45])
hold on
errorbar(x, y180, err180, '-bo', 'linewidth', 1)
errorbar(x, y360, err360, '-ro', 'linewidth', 1)
yline(0)
yline(1)
set(gca,'xscale','log')
xticks(x)
% xlim([.1 1.5])
if norm_shift
    line([0 1.4],[1 1],'color','k','linestyle','--')
%     ylim([-.1 1.3])
    xlabel({'Velocity','(proportion of Vmax)'})
    ylabel({'Illusory shift','(proportion of travel distance)'})
    legend 180-deg-shift 360-deg-shift location east
    cleanplot
    saveas(gcf, '../result/cyc02/ms01_rel_shift.png')
else
%     ylim([-1 8])
    xlabel 'Proportion of Vmax'
    ylabel 'Travel distance (dva)'
    legend 180-deg-shift 360-deg-shift location east
    cleanplot
    saveas(gcf, '../result/cyc02/ms01_abs_shift.png')
end

% figure
% hold on
% plot(x, shift_mat_180_1,'-bo', 'linewidth', 1)
% plot(x, shift_mat_180_n1, '-ro', 'linewidth', 1)
% set(gca,'xscale','log')
% 
% figure
% hold on
% plot(x, shift_mat_360_1,'-bo', 'linewidth', 1)
% plot(x, shift_mat_360_n1, '-ro', 'linewidth', 1)
% set(gca,'xscale','log')


k = 0.05/3;
for i = 1:6
    k = k * 3;
    disp(k)
end



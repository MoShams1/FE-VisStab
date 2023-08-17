clc
clear
close all

load ../data/cyc01/task01_20230712_125532_ms01.mat

norm_shift = true;

ind_phshift180 = ([data.phase_shift_deg]==180)';
ind_phshift360 = ([data.phase_shift_deg]==360)';

vel_vec_all = round([data.vel_dva_per_s])';
vel_vec_base_180 = unique(vel_vec_all(ind_phshift180));
vel_vec_base_360 = unique(vel_vec_all(ind_phshift360));

if norm_shift
    offsets = ([data.perceived_offset_dva])' ./ ([data.amp_dva])' / 5;
else
    offsets = ([data.perceived_offset_dva])' / 5;
end

for ivel = 1:length(vel_vec_base_180)
    ind_vel = vel_vec_all == vel_vec_base_180(ivel);
    offset_mat_180(:,ivel) = offsets(ind_vel);
end
for ivel = 1:length(vel_vec_base_360)
    ind_vel = vel_vec_all == vel_vec_base_360(ivel);
    offsets_dva = ([data.perceived_offset_dva])';
    offset_mat_360(:,ivel) = offsets(ind_vel);
end

x = unique([data.vel_coef]);
y180 = mean(offset_mat_180,1);
y360 = mean(offset_mat_360,1);
err180 = SE(offset_mat_180);
err360 = SE(offset_mat_360);

figure
hold on
errorbar(x, y180, err180, '-bo', 'linewidth', 1)
errorbar(x, y360, err360, '-ro', 'linewidth', 1)
line([0 1.4],[0 0],'color','k','linestyle','--')
xlim([.1 1.5])
if norm_shift
    line([0 1.4],[1 1],'color','k','linestyle','--')
    ylim([-.1 1.3])
    xlabel({'Velocity','(proportion of Vmax)'})
    ylabel({'Illusory shift','(proportion of travel distance)'})
    legend 180-deg-shift 360-deg-shift location east
    cleanplot
    saveas(gcf, '../result/cyc01/ms01_rel_shift.png')
else
    ylim([-1 8])
    xlabel 'Proportion of Vmax'
    ylabel 'Travel distance (dva)'
    legend 180-deg-shift 360-deg-shift location east
    cleanplot
    saveas(gcf, '../result/cyc01/ms01_abs_shift.png')
end




function [X, tX, Y, tY, sample_n, dur_resampled] = resample_saccade(x, y, t, desired_freq, samp_freq, smooth_range, smooth_method, sample_n)
    % x = horizontal gaze position, y = vertical gaze pos
    % t = timestamps of measurements, freq = sampling frequency desired (1440Hz
    % smooth_method & smooth_range = smoothing method and degree
    % sample_n = number of samples that we want, if not specified then
    % this value is according to the saccade duration and the desired freq
    
    % set smoothing default values
    if isempty(smooth_range)
        smooth_range = 5;
    end
    if isempty(smooth_method)
        smooth_method = 'moving';
    end
    % assert that vector have same length, otherwise break
    assert(length(x)==length(y));
    assert(length(x)==length(t));
    
    % how long is a frame at the desired frequency
    desired_framedur = (1000/desired_freq);
    % compute duration of saccade
    dur = max(t) - min(t);
    % Based on the desired frequency and the saccade duration, how many samples do we want?
    if isempty(sample_n)
        sample_n = ceil((dur/1000)*desired_freq);
    end
    % if no value is specified, then approximate the sampling frequency during the saccade time window
    if isempty(samp_freq)
        samp_freq = round((length(x)/dur)*1000);
    end
    % determine upsampling factor
    up_factor = round(desired_freq/samp_freq);
    
    % smooth data
    if strcmp(smooth_method, 'sgolay') % sgolay needs the degree as a parameter
        degree = 2; % quadratic sgolay filter
        yy = smooth(t, y, smooth_range, smooth_method, degree);
        xx = smooth(t, x, smooth_range, smooth_method, degree);
    else
        yy = smooth(t, y, smooth_range, smooth_method);
        xx = smooth(t, x, smooth_range, smooth_method);
    end
        
    % temporarily transform data to close-to-zero range to avoid edge
    % effects: http://de.mathworks.com/matlabcentral/answers/91767-why-do-i-obtain-edge-effects-or-oscillations-when-using-the-resample-function-to-perform-non-integer
    % first, we norm the data to the mean
    m_yy = mean(yy);
    m_xx = mean(xx);
    yy = yy - m_yy;
    xx = xx - m_xx;
    
    %%% include a pad of values at the beginning and end of each vector to
    %%% avoid edge effects in the resample function
    zeros_n = 10;
    zeros_step = 2;
    % time
    t_pad_begin = (t(1)-zeros_step*(zeros_n) : zeros_step : t(1)-zeros_step)'; 
    t_pad_end = (t(end)+zeros_step : zeros_step : t(end)+zeros_step*(zeros_n))'; 
    t = vertcat(t_pad_begin, t, t_pad_end);
    % positions
    yy = vertcat(repmat(yy(1),zeros_n,1), yy, repmat(yy(end),zeros_n,1));
    xx = vertcat(repmat(xx(1),zeros_n,1), xx, repmat(xx(end),zeros_n,1));
    
    %%% upsample to desired frequency
%     [Y, tY] = resample(yy, t, 1/desired_framedur, up_factor, 1);
%     [X, tX] = resample(xx, t, 1/desired_framedur, up_factor, 1);
    [Y, tY] = resample(yy, t, 1/desired_framedur, desired_freq, samp_freq);
    [X, tX] = resample(xx, t, 1/desired_framedur, desired_freq, samp_freq);
    % did everything go well? (it should)
    assert(length(X)==length(Y));
    assert(length(X)==length(tX));
    assert(length(tX)==length(tY));
    
    % transform resampled data back to normal coordinates
    Y = Y + m_yy;
    X = X + m_xx;
    
    % now remove the fuzzy ends with edge effects
    assert(sample_n<length(Y),'number of samples specified manually is too large');
    throw_out = idivide(int32(length(Y)-sample_n), 2);
    throw_out_mod = mod(int32(length(Y)-sample_n), 2);
    X = X((throw_out+throw_out_mod):(end-throw_out));
    tX = tX((throw_out+throw_out_mod):(end-throw_out));
    Y = Y((throw_out+throw_out_mod):(end-throw_out));
    tY = tY((throw_out+throw_out_mod):(end-throw_out));
    
    
    % check section:
    % Does the number of frames (X and Y) add up to the actual saccade duration?
    dur_resampled = length(Y)*desired_framedur;
      
end
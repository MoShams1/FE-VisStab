function [vx, vy] = compute_vel(x, y, t)
    % input: x and y coordinates of points
    % output: velocity between one point to another
    assert(length(x)==length(y))
    assert(length(x)==length(t))
    vx = [0];
    vy = [0];
    for i = 2:(length(x))
        vx(i) = (x(i) - x(i-1)) / (t(i) - t(i-1));
        vy(i) = (y(i) - y(i-1)) / (t(i) - t(i-1));
    end
    vx = vx';
    vy = vy';
end
function plot_peaks_on_signal(x, fs, locs, color)
    if nargin < 4
        color = 'r';
    end
    t = (0:length(x)-1)/fs;
    plot(t(locs), x(locs), [color 'o'], 'MarkerFaceColor', color);
end
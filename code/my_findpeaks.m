function [peaks, locs, peaks_builtin, locs_builtin] = my_findpeaks(x, minHeight, xaxis)

    %   minHeight   : minimum peak height

    if nargin < 2
        minHeight = -inf;
        [peaks_builtin, locs_builtin] = findpeaks(x);
    else 
        [peaks_builtin, locs_builtin] = findpeaks(x, 'MinPeakHeight', minHeight);
    end

    peaks = [];
    locs = [];

    for n = 2:length(x)-1
        if x(n) > x(n-1) && x(n) > x(n+1) && x(n) > minHeight
            peaks = [peaks, x(n)];
            locs = [locs, n];
        end
    end

    % Verification against built-in
    assert(isequal(locs, locs_builtin), 'Peak locations do not match MATLAB findpeaks');
    tol = 1e-12;
    assert(max(abs(peaks - peaks_builtin)) < tol, 'Peak values do not match MATLAB findpeaks');
    
    % Visualization
    if nargin >= 3
        hold on; 
        plot(xaxis(locs_builtin), peaks_builtin, 'ro', 'MarkerFaceColor','r');
        plot(xaxis(locs), peaks, 'bs', 'MarkerFaceColor','b');
        xlabel('Lag [s]');
        ylabel('Autocorrelation');
        legend('Autocorrelation','Peaks built-in','Peaks custom');
    end
end 
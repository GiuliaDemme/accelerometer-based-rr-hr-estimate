function h = plot_xy(x, y, plot_title, xlab, ylab, col)
% Simple helper to plot y versus x with labels and grid.
%
% Inputs:
%   x          : x-axis vector
%   y          : y-axis vector (same length as x)
%   plot_title : title string
%   xlab       : x-axis label string
%   ylab       : y-axis label string
%   col        : line color

if nargin < 6
    col = 'k'; % default: black
end 

    h = plot(x, y, col);
    xlabel(xlab);
    ylabel(ylab);
    title(plot_title);
    grid on;
end
function plot_acc_signal(x, fs, plot_title, mode)
    t = (0:size(x, 2) - 1) / fs;    % time axis
    figure;
    
    % ---------- 1D signal ----------
    if size(x, 1) == 1
        plot_xy(t, x, plot_title, 'Time [s]', 'Amplitude');
        return;
    end
    
    % ---------- 3D signal ----------
    if size(x, 1) ~= 3
        error('plot_acc_signal supports only 1D or 3D signals.');
    end

    switch mode
        % mode = 'overlay'  -> all axes on the same plot
        % mode = 'stacked'  -> one subplot per axis
        case 'overlay'
            plot_xy(t, x(1,:), plot_title, 'Time [s]', 'Acceleration', 'r'); hold on;    % X axis in red
            plot(t, x(2,:), 'g');                                                        % Y axis in green
            plot(t, x(3,:), 'b');                                                        % Z axis in blue
            legend('X','Y','Z');

        case 'stacked'
            ax = gobjects(3,1);

            ax(1) = subplot(3,1,1);
            plot_xy(t, x(1,:), plot_title, 'Time [s]', 'X', 'r');
            
            ax(2) = subplot(3,1,2);
            plot_xy(t, x(2,:), '', 'Time [s]', 'Y', 'g');

            ax(3) = subplot(3,1,3);
            plot_xy(t, x(3,:), '', 'Time [s]', 'Z', 'b');

            linkaxes(ax, 'x');
         
         otherwise
            error("Unknown plotting mode. Use 'overlay' or 'stacked'.");

    end
end

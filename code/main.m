%% LOAD DATA
data = readmatrix("../ex_data/person2/person2_fast.csv");

x = data(:, 2);
y = data(:, 3);
z = data(:, 4);
acc_signal = [x'; y'; z']; % 3xN matrix

% Estimate sampling frequency from the timestamps
time = data(:, 1);
fs = 1/mean(diff(time));

% Visualize
plot_acc_signal(acc_signal, fs, 'Raw accelerometer signal', 'overlay');

%% PREPROCESSING 

% Central trimming 
acc_signal = my_central_trimming(acc_signal, 60, fs);
plot_acc_signal(acc_signal, fs, 'After trimming', 'overlay');

% Normalization
acc_signal = my_normalization(acc_signal);
plot_acc_signal(acc_signal, fs, 'After normalization', 'stacked');

%% RESPIRATION RATE 

% Low-pass filter
fc = 0.7; 
[b, a] = butter(4, fc/(fs/2), 'low');

for axis = 1:3
    acc_signal_r(axis, :) = filtfilt(b, a, acc_signal(axis, :));
end

plot_acc_signal(acc_signal_r, fs, sprintf('Low-pass filtered accelerometer (fc = %.1f Hz)', fc), ...
    'stacked');

% PCA
[Xpca, lambdas] = my_pca(acc_signal_r);
respiratory_signal = Xpca(1, :);    % PC1: maximizes respiratory motion
plot_acc_signal(respiratory_signal, fs, 'Respiratory Signal (1st PCA component)');

%% Time-domain analysis - Autocorrelation 

% Compute autocorrelation
[R, lags] = my_autocorrelation(respiratory_signal);
Rpos = R(2:end);
lagpos = lags(2:end);
plot_acc_signal(Rpos, fs, 'Autocorrelation of Respiratory Signal');

% Find peaks 
minHeight = 0.1 * (max(Rpos) - min(Rpos));
[peaks, locs, peaks_builtin, locs_builtin] = my_findpeaks(Rpos, minHeight, lagpos/fs);

% Convert to respiratory rate
lag_peak = lagpos(locs(1));                 % lag in samples
RR_autocorrelation = 60 * fs / lag_peak;    % breaths/min

lag_peak_builtin = lagpos(locs_builtin(1));
RR_autocorrelation_builtin = 60 * fs / lag_peak_builtin;

% Custom vs. builtin 
tolRR = 0.05;  
assert(abs(RR_autocorrelation - RR_autocorrelation_builtin) < tolRR, 'RR mismatch: custom vs built-in beyond tolerance.');

fprintf("Respiratory Rate (breaths/min) - Autocorrelation built-in: %.2f\n", RR_autocorrelation_builtin);
fprintf("Respiratory Rate (breaths/min) - Autocorrelation custom: %.2f\n", RR_autocorrelation);

%% Frequency-domain analysis - PSD

% Physiological respiration band (Hz)
freq_min = 0.05;    % 3 breaths/min
freq_max = 0.7;     % 42 breaths/min

% Periodogram 
[P_per, f_per] = periodogram(respiratory_signal, [], [], fs);

% Welch
win_len = round(30 * fs);   % window lenght 
[P_wel, f_wel] = pwelch(respiratory_signal, hamming(win_len), round(0.5 * win_len), [], fs);

% Visualization
figure;
plot_xy(f_per, P_per, '', '', ''); hold on;
plot_xy(f_wel, P_wel, 'Respiratory PSD: Periodogram vs Welch', 'Frequency [Hz]', 'Power', 'r');
legend('Periodogram', 'Welch');
xlim([0 1]);

% Dominant peaks & RR
[RR_per, f_dom_per] = dominant_rr_from_psd(P_per, f_per, freq_min, freq_max);
[RR_wel, f_dom_wel] = dominant_rr_from_psd(P_wel, f_wel, freq_min, freq_max);

% Assert they agree (tolerance in Hz or breaths/min)
tolHz = 0.02;  % ~1.2 breaths/min
if abs(f_dom_per - f_dom_wel) < tolHz
    disp('Dominant frequencies disagree too much.')
end

fprintf("Respiratory Rate (breaths/min) - Periodogram: %.2f\n", RR_per);
fprintf("Respiratory Rate (breaths/min) - Welch: %.2f\n", RR_wel);

%% HEART RATE 

% Band-pass filter 
fc = [5 25];
[b, a] = butter(4, fc/(fs/2), 'bandpass');

do_axis_check = true;  % true only to visually compare axes
if do_axis_check
    acc_bp = zeros(size(acc_signal));
    for axis = 1:3
        acc_bp(axis,:) = filtfilt(b, a, acc_signal(axis,:));
    end
    plot_acc_signal(acc_bp, fs, 'Band-passed accelerometer (5–25 Hz)', 'stacked');
    xlim([47 52.5]);
end

% Select most informative axis: X, Y or Z axis and visualize
axis = acc_signal(3,:);
scg = filtfilt(b, a, axis);
plot_acc_signal(scg, fs, 'SCG (5–25 Hz)', 'overlay'); hold on;
xlim([47 52.5]);

%% Find peaks 

% Physiological constraint - Minimum Distance between Peaks 
maxHr = 120;                        % max 120 bpm
minDist = round((60/maxHr) * fs);   % ~50 samples at fs=100

% Find peaks
[peaks, locs] = findpeaks(scg, 'MinPeakDistance', minDist);

% Minimum Amplitude 
T = 0.5 * mean(peaks);              %% understand the fraction
peaks_cand = peaks(peaks > T);
locs_cand = locs(peaks > T);

% Visualize peaks
plot_peaks_on_signal(scg, fs, locs_cand, 'r');
yline(T, 'k--', 'T = 0.5·mean(peaks)');
xlim([47 52.5]);

%% Template & Cross-correlation

% Average template around each peak
W = round(0.5 * fs);    % 50 samples around each peak
beats = [];
locs_valid = [];

for k = 1:length(locs_cand)
    c = locs_cand(k);
    if c-W < 1 || c+W > length(scg)
        continue;
    end
    beats(end+1, :) = scg(c-W : c+W);
    locs_valid(end+1, :) = c;
end

% Build template
template = mean(beats, 1);
time_win = (-W:W)/fs;   % time axis related to the peak

% Visualize
figure;
h_beats = plot(time_win, beats.', 'Color', [0.8 0.8 0.8]); hold on;
h_template = plot_xy(time_win, template, 'SCG template around AO candidate peaks', ...
    'Time around detected peak [s]', 'SCG amplitude', 'r'); 
legend([h_beats(1), h_template], {'individual beats','average template'});

% Cross-correlation 
maxLagSearch = round(0.2 * fs);        % 200 ms in samples
lagTol = round(0.02 * fs);             % 20 ms in samples
keep = false(size(beats, 1), 1);

for k = 1:size(beats, 1)
    [xc, lags] = xcorr(beats(k,:), template, maxLagSearch, 'coeff');
    [~, idx] = max(xc);
    lagAtMax = lags(idx);
    keep(k) = (lagAtMax <= lagTol);
end

beats_keep = beats(keep, :);
locs_keep  = locs_valid(keep);

% Visualize peaks
plot_acc_signal(scg, fs, 'SCG (Z axis, 5–25 Hz)', 'overlay'); hold on;
plot_peaks_on_signal(scg, fs, locs_keep, 'r');
yline(T, 'k--', 'T = 0.5·mean(peaks)');
xlim([47 52.5]);

%% Final heart rate

% Beat-to-beat intervals e HR
IBI = diff(locs_keep) / fs;     % ao-ao intervals in seconds
HR_inst = 60 ./ IBI;            % bpm
HR_mean = mean(HR_inst);

figure;
t_hr = locs_keep(2:end) / fs;
plot_xy(t_hr, HR_inst, 'Beat-to-beat heart rate from SCG (AO–AO intervals)', ...
    'Time [s]', 'Heart Rate [bpm]', 'b');
figure;
histogram(HR_inst);
grid on;
xlabel('Heart Rate [bpm]');
ylabel('Count');
title('Distribution of beat-to-beat heart rate');

fprintf('HR mean (AO-AO) = %.2f bpm\n', HR_mean);
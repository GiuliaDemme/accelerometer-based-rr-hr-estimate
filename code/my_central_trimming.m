function x = my_central_trimming(x, total_dur, fs)
    num_samples = size(x, 2);
    num_samples_to_keep = total_dur * fs;

    if num_samples_to_keep >= num_samples
        error("Requested duration is longer than the input signal!");
    end

    start_idx = floor(num_samples/2) - floor(num_samples_to_keep/2) + 1;
    x = x(:, start_idx: start_idx + num_samples_to_keep - 1);
end
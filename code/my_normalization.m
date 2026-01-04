function x = my_normalization(x)
    for i = 1:size(x, 1)
        x(i, :) = (x(i, :) - mean(x(i, :))) / std(x(i, :)); % Normalize each axis
    end
end 
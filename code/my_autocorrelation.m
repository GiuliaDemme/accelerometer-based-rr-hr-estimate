function [R, lags] = my_autocorrelation(x)
    N = length(x);
    maxLag = N-1;

    R = zeros(1, maxLag+1);
    lags = 0:maxLag;

    for k = 0:maxLag
        s = 0;
        for n = 1:(N-k)
            s = s + x(n) * x(n+k);
        end
        R(k+1) = s / N;  % biased normalization
    end

    % Verification against built-in
    [Rb, lagsb] = xcorr(x, 'biased');
    idx = lagsb >= 0;
    Rb = Rb(idx);
    lagsb = lagsb(idx);

    % Check that lags match exactly
    assert(isequal(lags, lagsb), 'Lag mismatch in check');
    
    % Check that values match (within tolerance)
    tol = 1e-10;
    assert(max(abs(R - Rb)) < tol, 'Value mismatch in check');

end 





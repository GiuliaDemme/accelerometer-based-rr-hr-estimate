function [RR, f_dom, P_dom] = dominant_rr_from_psd(P, f, freq_min, freq_max)
% Find dominant frequency in a band and convert to RR.
%
% Inputs:
%   P        : PSD values
%   f        : frequency vector [Hz]
%   freq_min : lower bound [Hz]
%   freq_max : upper bound [Hz]
%
% Outputs:
%   RR       : respiratory rate [breaths/min]
%   f_dom    : dominant frequency [Hz]
%   P_dom    : PSD value at dominant frequency

    freq_range = (f >= freq_min) & (f <= freq_max);
    f_range = f(freq_range);
    P_range = P(freq_range);
 
    [P_dom, idx_max] = max(P_range);
    f_dom = f_range(idx_max);
    RR = 60 * f_dom;
end 
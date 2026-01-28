% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [log_v, log_m] = r_log(x, fact)
% 
% DESCRIPTION:
%   Computes the general logarithm function:
%        y = f(x) = fact * log2(x);
%   The following cases can be used:
%        fact = 1 for f(x) = log2(x)
%        fact = 10 * log10(2) for f(x) = 10 * log10(x)
%        fact = 20 * log10(2) for f(x) = 20 * log10(x)  
%
% INPUTS:
%   x    - real input array in Matlab Double Precision
%   fact - (optional) log2 scaling factor (default 10 * log10(2))
%
% OUTPUTS:
%   log_v - logarithm value in VSPA Single Precision
%   log_m - logarithm value in Matlab Double Precision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function [log_v, log_m] = r_log(x, fact)

% Default parameters
if (nargin < 2)
    fact = 10 * log10(2);
end

% Matlab implementation
log_m = fact * log2(x);

% VSPA implementation
log2_v = r_log2(r_single(x(:).'));
log2_v = float2fix(log2_v);
log2_v = typecast(uint32(log2_v), 'int32');
log2_v = double(log2_v) / 2^15;

log2_int_v = floor(log2_v);
log2_fra_v = log2_v - log2_int_v;

log_v = r_smad(fact, log2_int_v(:).', 0);
log_v = r_smad(fact, log2_fra_v(:).', log_v);
log_v = reshape(log_v(:), size(x));

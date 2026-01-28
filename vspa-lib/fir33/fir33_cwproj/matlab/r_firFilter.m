% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [ yr, ym, ir ] = r_firFilter(h, x, prec)
%R_FIRFILTER Bit-exact model for firFilter function.
%
% DESCRIPTION:
%   [yr, ym, ir] = r_firFilter(h, x) filters the complex data
%   in vector x, of length N, with the real filter described
%   by vector h, of length K, to create the filtered data yr in 16-bit
%   fixed-point precision and ym in Matlab precision. The length of
%   the filtered data is N-K+1.
%
% INPUTS:
%   h: real coefficients, in Matlab precision and in the range (-1, +1),
%      of length K.
%
%   x: complex data to be filtered, in Matlab precision and in the range
%      (-1, +1), of length N.
%
%   prec: data and taps precision:
%       'half': 16 bit floating point
%       'half_fixed': 16 bit fixed point
% 
% OUTPUTS:
%   yr: filtered complex data, in 16-bit fixed-point precision,
%       of length N-K+1.
%
%   ym: filtered complex data, in Matlab precision, of length N-K+1.
%
%   ir: structure of input arguments h, x in 16-bit fixed-point precision.

K = length(h);            % Number of filter coefficients.
N = length(x) - K + 1;    % Number of filtered complex data.

% --
% 16-bit fixed-point precision output:
% --

% s1: matrix of input data, obtained from rotating-right input data.
s1 = zeros(K, N);
for k = 1:K
    s1(k, :) = x(k:N + k - 1);
end

% s0: matrix of filter coefficients, obtained from replicating coefficients
%     for each MAC operation.
s0 = reshape(h(K:-1:1), [], 1)*ones(1, N);

% yr: bit-exact output, obtained from rounding the single precision output
%     to 16-bit fixed-point precision.
% Note that s0 and s1 inputs are also rounded to 16-bit fixed-point
% precision.
if strcmp(prec, 'half')
    yr = r_half_flt(r_smac(r_half_flt( s0 ), r_half_flt( s1 ), zeros( 1, N )));

    ir = struct;
    ir.x = r_half_flt(x);
    ir.h = r_half_flt(h);
else
    yr = r_half(r_smac(r_half( s0 ), r_half( s1 ), zeros( 1, N )));

    ir = struct;
    ir.x = r_half(x);
    ir.h = r_half(h(K:-1:1));
end

% --
% Matlab precision output:
% --
y = filter(h, 1, x.');
ym = y(K:end);

end

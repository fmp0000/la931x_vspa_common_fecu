% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y = spl_fun_core(x, optype, Mi, E, sn_on)
% DESCRIPTION:
%   Implements bit exact model for special AU functions on Ruby
% INPUTS:
%   x: input vector of real elements
%   optype: specifies type of operation defined by:
%       'LN': Natural log
%       'BERP': Bit Error Rate
%       'SQRT': Square root
%       'RSQRT': Reciprocal Square root
%       'RECIP': Reciprocal
%   Mi: Number of mantissa bits (including implicit bits)
%   E: Number of exponent bits
%   sn_on: 0=>sub-normalization OFF; 1=>sub-normalization ON
%
% OUTPUTS:
%   y: output vector with same dimensions as input vector
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = spl_fun_core(x, optype, Mi, E, sn_on)

%% config
M = Mi-1;   % explicit mantissa bits

% convert to precision
[t x_i] = convert_precision(x, Mi, E, sn_on);

%% addition code
switch(optype)
    case 'LN' 
        % natural logarithm
        resbits = 4;
    case 'BERP'
        % 1/(1+e^x)
        resbits = 5;
    case 'RSQRT'
        % reciprocal square root
        resbits = 7;
    otherwise
        % reciprocal, square root
        resbits = 10;
end

n = resbits;
if (n > M)
    n = M;
end

out_e = x_i.e;
out_m = x_i.m;
out_s = x_i.s;
if (n < M)
    out_m = bitor(floor(x_i.m/2^(M-n-1)), 1)*2^(M-n-1);
end

% rounded input value, sign ignored
x_int = convert_double(0, x_i.e, out_m, Mi-1, E, 1, sn_on);
y_int = zeros(size(x_int));
switch(optype)
    case 'LN' 
        % natural logarithm
        zind = (out_m==0 & out_e==0);
        x_int(zind) = 1e-10;
        y_int = log(x_int);
        negind = (sign(y_int) < 0);
        out_s(negind) = 1;
        out_s(~negind) = 0;
    case 'BERP'
        % 1/(1+e^x)
        % function approximated by breaking it into 3 segments
        seg1ind = (x_i.val <= 11647);
        seg2ind = (x_i.val >= 19872);
        seg3ind = ~(seg1ind | seg2ind);
        y_int(seg1ind) = 0.49853515625;
        y_int(seg2ind) = 0.0;
        y_int(seg3ind) = 1./(1+exp(x_int(seg3ind)));
    case 'SQRT'
        % square root
        y_int = sqrt(x_int);
    case 'RSQRT'
        % reciprocal square root
        zind = (out_m==0 & out_e==0);
        x_int(zind) = 1e-10;
        y_int = sqrt(1./x_int);
    case 'RECIP'
        zind = (out_m==0 & out_e==0);
        x_int(zind) = 1e-10;
        y_int = 1./x_int;
    otherwise
        error('Unknown op mode specified');
end

[t y_i] = convert_precision(y_int, Mi, E, sn_on);
y = convert_double(out_s, y_i.e, y_i.m, Mi-1, E, 1, sn_on);

return;

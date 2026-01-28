% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y_i = extend_precision(x_i, Mi, E, Aext, sn_on)
%
% DESCRIPTION:
%   Precision extends normalized inputs to unnormalized outputs
% 
% INPUTS:
%   x_i: Struct containing the following fields (each field is a
%   multi-dimensional matrix).
%       val: The precision converted numbers in integer format
%       s: sign field (in normalized format)
%       e: exponent field (in normalized format)
%       m: mantissa field (in normalized format)
%   Mi: number of implicit mantissa bits in precision format
%   E: number of exponent bits in precision format
%   Aext: number of additional accumulator bits (including impllicit bit)
%   sn_on: 0=>sub-normalization OFF; 1=>sub-normalization ON
%
% OUTPUTS:
%   y: output matrix of dimensions MxN.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y_i = extend_precision(x_i, Mi, E, Aext, sn_on)

M = Mi-1;   % explicit mantissa bits
N = M+E+1;  % total number of bits
Mext = M + Aext;
Next = N + Aext;

zind = (x_i.val == 0 | x_i.val == 2^(N-1));
nzind = ~zind;

input_dims = size(x_i.val);
y_i = struct('val', zeros(input_dims), 's', zeros(input_dims), 'e', zeros(input_dims), 'm', zeros(input_dims));
y_i.s = x_i.s;
y_i.e = x_i.e;

% add extra precision bits
y_i.m(zind) = 0;
y_i.m(nzind) = x_i.m(nzind)*2^(Aext-1);

% insert the implicit bit
if sn_on
    % if sub-normalization is enabled, set implicit bit to zero if e == 0
    sn_index = (x_i.e == 0);
    y_i.e(nzind&sn_index) = 1;
    
    n_index = (nzind & ~sn_index);
    y_i.m(n_index) = 2^(Mext-1) + y_i.m(n_index);
else
    y_i.m(nzind) = 2^(Mext-1) + y_i.m(nzind);
end

y_i.val = y_i.s*2^(Next-1) + y_i.e*2^Mext + y_i.m;

return;

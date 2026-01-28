% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y = convert_double(s, e, m, M, E, n_type, sn_on)
%
% DESCRIPTION:
%   Convert input sign, exponent, mantissa matrices to double matrices
% 
% INPUTS:
%   s: sign matrix
%   e: exponent matrix
%   m: mantissa matrix
%   M: number of mantissa bits in precision format
%   E: number of exponent bits in precision format
%   n_type: 1 => normalized (implicit bit present), 0 => unnormalized (no implicit bit)
%   sn_on (ignored if n_type = 0): 0=>sub-normalization OFF; 1=>sub-normalization ON
% OUTPUTS:
%   y: output double matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = convert_double(s, e, m, M, E, n_type, sn_on)

EBIAS = 2^(E-1);
s_factor = (s==0)*2 - 1;

y = zeros(size(s));

% detect the zero values
zind = (e == 0 & m == 0);

if ~n_type
    y = s_factor.*(m./2^M).*(2.^(e-EBIAS));
else
    if sn_on
        sn_index = (e==0);
        nsn_index = ~sn_index;
        y(sn_index) = s_factor(sn_index).*(m(sn_index)/2^M).*(2.^(1-EBIAS));
        y(nsn_index) = s_factor(nsn_index).*(1 + m(nsn_index)/2^M).*(2.^(e(nsn_index)-EBIAS));
    else
        y = s_factor.*(1 + m/2^M).*(2.^(e-EBIAS));
    end
end

% override and set the zero valued indices to zero
y(zind) = 0;

return;

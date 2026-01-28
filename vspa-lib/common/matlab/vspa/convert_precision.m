% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [Y X_q] = convert_precision(X, Mi, E, sn_on)
%
% INPUTS:
%   X: Matrix of real numbers
%   Mi: number of implicit mantissa bits in precision format
%   E: number of exponent bits in precision format
%   sn_on (OPTIONAL): 0=>sub-normalization OFF; 1=>sub-normalization ON [DEFAULT]
%
% OUTPUTS:
%   Y: Matrix of precision-converted real numbers (same dims as X)
%   X_q: struct containing the following fields
%       val: The precision converted numbers in integer format
%       s: sign field
%       e: exponent field
%       m: mantissa field
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Y X_q] = convert_precision(X, Mi, E, sn_on)

%% initialize conversion engine based on requested precision format
subnorm_on = 1;
if exist('sn_on', 'var')
    subnorm_on = sn_on;
end

M = Mi-1;   % explicit mantissa bits
N = M+E+1;  % total number of bits

maxE = 2^(2^E-1-2^(E-1));
maxM = 1 + (2^M-1)/2^M;
minE = 2^(-2^(E-1));
minM = 1 + 1/2^M;

MAX = maxM*maxE;
MIN = minM*minE;
MIN_N = 2^(1-2^(E-1));

EBIAS = 2^(E-1);

s_val = (X < 0);
s_factor = (s_val==0)*2 - 1;
abs_in = abs(X);
abs_in_old = abs_in; 

input_dims = size(X);
e_val = zeros(input_dims);
m_val = zeros(input_dims);
Y = zeros(input_dims);
if subnorm_on
    % convert to integer format representing quantized version of the input matrix
    abs_in = (abs_in <= MAX).*abs_in + (abs_in > MAX).*MAX;
    sn_index = find(abs_in < MIN_N);
    nsn_index = find(abs_in >= MIN_N);

    e_val(nsn_index) = floor(log2(abs_in(nsn_index)));
    e_val(sn_index) = -2^(E-1);
    eb_val = e_val + EBIAS;

    if ~isempty(nsn_index)
        m_val(nsn_index) = round(abs_in(nsn_index)./(2.^e_val(nsn_index))*2^M) - 2^M;
        Y(nsn_index) = s_factor(nsn_index).*(1 + m_val(nsn_index)/2^M).*(2.^e_val(nsn_index));
    end
    
    if ~isempty(sn_index)
        m_val(sn_index) = round(abs_in(sn_index)./(2^(1-2^(E-1)))*2^M);
        Y(sn_index) = s_factor(sn_index).*(m_val(sn_index)/2^M).*(2.^(1-2^(E-1)));
    end
else
    % convert to integer format representing quantized version of the input matrix
    abs_in = (abs_in <= MAX).*abs_in + (abs_in > MAX).*MAX;
    abs_in = (abs_in >= MIN).*abs_in + (abs_in < MIN).*MIN;

    e_val  = floor(log2(abs_in));
    eb_val = e_val + EBIAS;

    m_val  = round(abs_in./(2.^e_val)*2^M) - 2^M;
    m_val = m_val.*(abs_in_old >= (MIN - (2^-(EBIAS+Mi))));     %Zero Exception

    % convert back to floating point format
    Y = s_factor.*(1 + m_val/2^M).*(2.^e_val);
    Y = Y.*~(eb_val==0 & m_val==0);  %zero exception
end

% generate outputs in [s e m] format
X_q = struct('val', [], 's', [], 'e', [], 'm', []);
X_q.val =  s_val*2^(N-1) + eb_val*2^M + m_val;
X_q.s = s_val;
X_q.e = eb_val;
X_q.m = m_val;

%% done
return;

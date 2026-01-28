% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y_i = mult_core(x1_i_in, x2_i_in, Mi, E, Aext, sn_on)
%
% INPUTS:
%   x1_i: Struct containing the following fields (each field is a
%   multi-dimensional matrix). This is the multiplicand
%       val: The precision converted numbers in integer format
%       s: sign field (in normalized format)
%       e: exponent field (in normalized format)
%       m: mantissa field (in normalized format)
%   x2_i: Struct containing the following fields (each field is a
%   multi-dimensional matrix). This is the multiplier
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
%   y_i: struct containing the following fields (each field is a
%   multi-dimensional matrix with same dimensions as inputs). This is the
%   product
%       val: The precision converted numbers in integer format
%       s: sign field (in unnormalized format)
%       e: exponent field (in unnormalized format)
%       m: mantissa field (in unnormalized format)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y_i = mult_core(x1_i_in, x2_i_in, Mi, E, Aext, sn_on)

x1_i = x1_i_in;
x2_i = x2_i_in;

%% config
M = Mi-1;   % explicit mantissa bits
N = M+E+1;  % total number of bits
maxE = 2^E-1;
Mext = M + Aext;
Next = N + Aext;
EBIAS = 2^(E-1);
maxMe = 2^Mext - 1;
input_dims = size(x1_i.val);

%% compute product with extended precision on mantissa
y_i = struct('val', zeros(input_dims), 's', zeros(input_dims), 'e', zeros(input_dims), 'm', zeros(input_dims));
e_prod = zeros(input_dims);
m_prod = zeros(input_dims);

% sign of the product
s_prod = xor(x1_i.s, x2_i.s);

% restore the implicit bit in the mantissa
if (sn_on)
    sn_index = (x1_i.e == 0 & x1_i.m ~= 0);
    x1_i.e(sn_index) = 1;
    m1 = 2^M*(~sn_index) + x1_i.m;
    
    sn_index = (x2_i.e == 0 & x2_i.m ~= 0);
    x2_i.e(sn_index) = 1;
    m2 = 2^M*(~sn_index) + x2_i.m;
else
    m1 = 2^M + x1_i.m;
    m2 = 2^M + x2_i.m;
end

% check if either input is zero
z_ind = (x1_i.val == 0 | x1_i.val == 2^(N-1) | x2_i.val == 0 | x2_i.val == 2^(N-1));
e_prod(z_ind) = 0;
m_prod(z_ind) = 0;

nz_ind = ~z_ind;
e_prod(nz_ind) = x1_i.e(nz_ind) + x2_i.e(nz_ind) - EBIAS;
m_prod(nz_ind) = floor((m1(nz_ind).*m2(nz_ind))./2^(M-Aext+1));

if sn_on
    % if sub norm on we can accomodate more bits
    rI = find(m_prod > 0 & e_prod < 0);
    while ~isempty(rI)
        m_prod(rI) = floor(m_prod(rI)/2);
        e_prod(rI) = e_prod(rI) + 1;
        rI = find(m_prod > 0 & e_prod < 0);
    end
end

rI = find(m_prod >= 2^Mext & e_prod <= maxE);
while ~isempty(rI)
    m_prod(rI) = floor(m_prod(rI)/2);
    e_prod(rI) = e_prod(rI) + 1;
    rI = find(m_prod >= 2^Mext & e_prod <= maxE);
end

% final outputs
ovflow_ind = (e_prod > maxE);
y_i.val(ovflow_ind) = s_prod(ovflow_ind)*2^(Next-1) + maxE*2^Mext + maxMe;
y_i.s(ovflow_ind) = s_prod(ovflow_ind);
y_i.e(ovflow_ind) = maxE;
y_i.m(ovflow_ind) = maxMe;

unflow_ind = (e_prod < 0);
y_i.val(unflow_ind) = s_prod(unflow_ind)*2^(Next-1);
y_i.s(unflow_ind) = s_prod(unflow_ind);
y_i.e(unflow_ind) = 0;
y_i.m(unflow_ind) = 0;

reg_ind = ~(ovflow_ind | unflow_ind);
y_i.val(reg_ind) = s_prod(reg_ind)*2^(Next-1) + e_prod(reg_ind)*2^Mext + m_prod(reg_ind);
y_i.s(reg_ind) = s_prod(reg_ind);
y_i.e(reg_ind) = e_prod(reg_ind);
y_i.m(reg_ind) = m_prod(reg_ind);

return;

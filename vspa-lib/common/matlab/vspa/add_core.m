% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y_i = add_core(x1_i, x2_i, Mi, E, Aext, n_on, sn_on)
%
% INPUTS:
%   x1_i: Struct containing the following fields (each field is a
%   multi-dimensional matrix). This is the addend
%       val: The precision converted numbers in integer format
%       s: sign field (in unnormalized format)
%       e: exponent field (in unnormalized format)
%       m: mantissa field (in unnormalized format)
%   x2_i: Struct containing the following fields (each field is a
%   multi-dimensional matrix). This is the multiplier
%       val: The precision converted numbers in integer format
%       s: sign field (in unnormalized format)
%       e: exponent field (in unnormalized format)
%       m: mantissa field (in unnormalized format)
%   Mi: number of implicit mantissa bits in precision format
%   E: number of exponent bits in precision format
%   Aext: number of additional accumulator bits (including impllicit bit)
%   nn_on: 0=>unnormalized output; 1=>normalized output
%   sn_on: 0=>sub-normalization OFF; 1=>sub-normalization ON
%
% OUTPUTS:
%   y_i: struct containing the following fields (each field is a
%   multi-dimensional matrix with same dimensions as inputs). This is the
%   sum
%       val: The precision converted numbers in integer format
%       s: sign field (in normalized/unnormalized format)
%       e: exponent field (in normalized/unnormalized format)
%       m: mantissa field (in normalizedunnormalized format)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y_i = add_core(x1_i, x2_i, Mi, E, Aext, n_on, sn_on)

%% config
M = Mi-1;   % explicit mantissa bits
N = M+E+1;  % total number of bits
maxE = 2^E-1;
Mext = M + Aext;
Next = N + Aext;
maxM = 2^M - 1;
maxMe = 2^Mext - 1;
input_dims = size(x1_i.val);

%% addition code
y_i = struct('val', zeros(input_dims), 's', zeros(input_dims), 'e', zeros(input_dims), 'm', zeros(input_dims));
s_sum = zeros(input_dims);
e_sum = zeros(input_dims);
m_sum = zeros(input_dims);

% check for either or both inputs being zeros
z_ind1 = (x1_i.val == 0 | x1_i.val == 2^(Next-1)) & ~(x2_i.val == 0 | x2_i.val == 2^(Next-1));
z_ind2 = (x2_i.val == 0 | x2_i.val == 2^(Next-1)) & ~(x1_i.val == 0 | x1_i.val == 2^(Next-1));
z_ind12 = (x1_i.val == 0 | x1_i.val == 2^(Next-1)) & (x2_i.val == 0 | x2_i.val == 2^(Next-1));
z_ind = (z_ind1 | z_ind2 | z_ind12);
nz_ind = ~z_ind;

s_sum(z_ind12) = x1_i.s(z_ind12);
s_sum(z_ind1) = x2_i.s(z_ind1);
s_sum(z_ind2) = x1_i.s(z_ind2);

e_sum(z_ind) = x1_i.e(z_ind) + x2_i.e(z_ind);
m_sum(z_ind) = x1_i.m(z_ind) + x2_i.m(z_ind);
    
if n_on
    m_sz = m_sum(z_ind1 | z_ind2);
    e_sz = e_sum(z_ind1 | z_ind2);
    
    if sn_on
        % sub-normalization ON
        sn_index = (e_sz == 0);
        e_sz(sn_index) = 1;
        round_bit = bitand(m_sz(sn_index), 1);
        m_sz(sn_index) = floor(m_sz(sn_index)/2) + round_bit;
        
        rI = find((m_sz < 2^(Mext-1)) & (e_sz > 1), 1);
        while ~isempty(rI)
            m_sz(rI) = m_sz(rI)*2;
            e_sz(rI) = e_sz(rI) - 1;
            rI = find((m_sz < 2^(Mext-1)) & (e_sz > 1), 1);
        end
    else
        rI = find((m_sz < 2^(Mext-1)) & (e_sz >= 0), 1);
        while ~isempty(rI)
            m_sz(rI) = m_sz(rI)*2;
            e_sz(rI) = e_sz(rI) - 1;
            rI = find((m_sz < 2^(Mext-1)) & (e_sz >= 0), 1);
        end
    end
    
    round_bit = bitand(floor(m_sz./2^(Aext-2)), 1);
    m_sz = floor(m_sz./2^(Aext-1)) + round_bit;
    
    rn_index = (m_sz >= 2^Mi);
    m_sz(rn_index) = floor(m_sz(rn_index)/2);
    e_sz(rn_index) = e_sz(rn_index) + 1;
   
    % remove the implicit bit
    if (sn_on)
        sn_index = (e_sz == 1 & m_sz < 2^M);
        nsn_index = ~sn_index;
        e_sz(sn_index) = 0; % set the sn exponents to zeros
        m_sz(nsn_index) = m_sz(nsn_index) - 2^M;    % remove the implict bit for normal numbers
    else
        m_sz = m_sz - 2^M;
    end
    
    e_sum(z_ind1 | z_ind2) = e_sz;
    m_sum(z_ind1 | z_ind2) = m_sz;
end

% non zero addends
s1 = x1_i.s(nz_ind);
e1 = x1_i.e(nz_ind);
m1 = x1_i.m(nz_ind);
s2 = x2_i.s(nz_ind);
e2 = x2_i.e(nz_ind);
m2 = x2_i.m(nz_ind);

e_s = zeros(size(e1));
m_s = zeros(size(e1));
sticky_bit = zeros(size(e1));

g1_ind = (e2 > e1);
g2_ind = ~g1_ind;

e_s(g1_ind) = e2(g1_ind);
tmp = m1(g1_ind);
m1(g1_ind) = floor(m1(g1_ind)./2.^(e2(g1_ind)-e1(g1_ind)));
sticky_bit(g1_ind) = ((tmp - (m1(g1_ind).*2.^(e2(g1_ind)-e1(g1_ind)))) ~= 0);

e_s(g2_ind) = e1(g2_ind);
tmp = m2(g2_ind);
m2(g2_ind) = floor(m2(g2_ind)./2.^(e1(g2_ind)-e2(g2_ind)));
sticky_bit(g2_ind) = ((tmp - (m2(g2_ind).*2.^(e1(g2_ind)-e2(g2_ind)))) ~= 0);

s_s = s1;   % default

add_ind = (s1 == s2);
m2gtm1_ind = ((~add_ind) & (m2>m1));
m1gtm2_ind = ((~add_ind) & (m1>m2));
m1eqm2_ind = ((~add_ind) & (m1==m2));

m_s(add_ind) = m1(add_ind) + m2(add_ind);
m_s(m2gtm1_ind) = m2(m2gtm1_ind) - m1(m2gtm1_ind);
s_s(m2gtm1_ind) = s2(m2gtm1_ind);
m_s(m1gtm2_ind) = m1(m1gtm2_ind) - m2(m1gtm2_ind);
m_s(m1eqm2_ind) = 0;
s_s(m1eqm2_ind) = (e2(m1eqm2_ind) > e1(m1eqm2_ind)).*s2(m1eqm2_ind) + (e2(m1eqm2_ind) <= e1(m1eqm2_ind)).*s1(m1eqm2_ind);

if n_on
    seq_ind = (s1 == s2);
    
    % normalize output to regular precision
    step_ind1 = (m_s >= 2^(Mext));
    round_bit = bitand(floor(m_s(step_ind1)/2^(Aext-1)), 1);
    m_s(step_ind1) = floor(m_s(step_ind1)/2^Aext) + round_bit;
    e_s(step_ind1) = e_s(step_ind1) + 1;
    
    step_ind2 = (~step_ind1 & (m_s >= 2^(Mext-1)));
    round_bit = bitand(floor(m_s(step_ind2)/2^(Aext-2)), 1);
    m_s(step_ind2) = floor(m_s(step_ind2)/2^(Aext-1)) + bitand(round_bit, bitor(bitor(bitand(m_s(step_ind2), 1), seq_ind(step_ind2)), ~sticky_bit(step_ind2)));
    
    step_ind3 = (~(step_ind1 | step_ind2) & (m_s >= 2^(Mext-2)));
    round_bit = bitand(m_s(step_ind3), 1);
    m_s(step_ind3) = floor(m_s(step_ind3)/2^(Aext-2)) + bitand(round_bit, bitor(seq_ind(step_ind3), ~sticky_bit(step_ind3)));
    e_s(step_ind3) = e_s(step_ind3) - 1;
    
    if sn_on
        % sub-normalization ON
        sn_index = (e_s == 0);
        e_s(sn_index) = 1;
        round_bit = bitand(m_s(sn_index), 1);
        m_s(sn_index) = floor(m_s(sn_index)/2) + round_bit;
    
        step_ind_r = ~(step_ind1 | step_ind2 | step_ind3);
        mr = m_s(step_ind_r);
        er = e_s(step_ind_r);
    
        rI = find((mr < 2^(Mext-1)) & (er > 1));
        while ~isempty(rI)
            mr(rI) = mr(rI).*2;
            er(rI) = er(rI) - 1;
            rI = find((mr < 2^(Mext-1)) & (er > 1));
        end
    else
        step_ind_r = ~(step_ind1 | step_ind2 | step_ind3);
        mr = m_s(step_ind_r);
        er = e_s(step_ind_r);

        rI = find((mr < 2^(Mext-1)) & (er >= 0));
        while ~isempty(rI)
            mr(rI) = mr(rI).*2;
            er(rI) = er(rI) - 1;
            rI = find((mr < 2^(Mext-1)) & (er >= 0));
        end
    end

    mr = floor(mr/2^(Aext-1));
    m_s(step_ind_r) = mr;
    e_s(step_ind_r) = er;
    
    rn_index = (m_s >= 2^Mi);
    m_s(rn_index) = floor(m_s(rn_index)/2);
    e_s(rn_index) = e_s(rn_index) + 1;
    
    % remove the implicit bit
    if (sn_on)
        sn_index = (e_s == 1 & m_s < 2^M);
        nsn_index = ~sn_index;
        e_s(sn_index) = 0; % set the sn exponents to zeros
        m_s(nsn_index) = m_s(nsn_index) - 2^M;    % remove the implict bit for normal numbers
    else
        m_s = m_s - 2^M;
    end
    
    s_sum(nz_ind) = s_s;
    e_sum(nz_ind) = e_s;
    m_sum(nz_ind) = m_s;
    
    ovflow_ind = (e_sum > maxE);
    e_sum(ovflow_ind) = maxE;
    m_sum(ovflow_ind) = maxM;

    unflow_ind = (e_sum < 0);
    e_sum(unflow_ind) = 0;
    m_sum(unflow_ind) = 0;
    
    y_i.val = s_sum*2^(N-1) + e_sum*2^M + m_sum;
else
    % maintain output with extended precision
    rn_index = (m_s >= 2^(M+Aext));
    m_s(rn_index) = floor(m_s(rn_index)/2);
    e_s(rn_index) = e_s(rn_index) + 1;

    s_sum(nz_ind) = s_s;
    e_sum(nz_ind) = e_s;
    m_sum(nz_ind) = m_s;

    ovflow_ind = (e_sum > maxE);
    e_sum(ovflow_ind) = maxE;
    m_sum(ovflow_ind) = maxMe;

    unflow_ind = (e_sum < 0);
    e_sum(unflow_ind) = 0;
    m_sum(unflow_ind) = 0;
    
    y_i.val = s_sum*2^(Next-1) + e_sum*2^Mext + m_sum;
end

y_i.s = s_sum;
y_i.e = e_sum;
y_i.m = m_sum;

return;

% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y = ruby_emad(x1, x2, x3, Mi, E, Aext, sn_on)
%
% DESCRIPTION:
%   y = x1.*x2 + x3
%   Implements element by element (complex/real) multiply and add 
% 
% INPUTS:
%   x1: input matrix x1. Can be a scalar.
%   x2: input matrix x1. Can be a scalar.
%   x3: input matrix x1. Can be a scalar.
%   Mi: number of implicit mantissa bits in precision format
%   E: number of exponent bits in precision format
%   Aext: number of additional accumulator bits (including impllicit bit)
%   sn_on (OPTIONAL): 0=>sub-normalization OFF; 1=>sub-normalization ON [DEFAULT]
%
% OUTPUTS:
%   y: output matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = ruby_emad(x1, x2, x3, Mi, E, Aext, sn_on) 

%% config
if ~exist('sn_on', 'var')
    sn_on = 1;
end

% total number of bits
N = E + Mi;

%% input checks
% check and adjust dimensions
scx1 = isscalar(x1);
scx2 = isscalar(x2);
scx3 = isscalar(x3);
mat_form = ~(scx1 & scx2 & scx3);

if mat_form
    sz1 = size(x1);
    sz2 = size(x2);
    sz3 = size(x3);
    if ~scx1
        matsz = sz1;
    elseif ~scx2
        matsz = sz2;
    else
        matsz = sz3;
    end
    
    if scx1
        x1 = ones(matsz).*x1;
    elseif matsz == sz1
    else
        error('Input matrix dimension mismatch!');
    end

    if scx2
        x2 = ones(matsz).*x2;
    elseif matsz == sz2
    else
        error('Input matrix dimension mismatch!');
    end
    
    if scx3
        x3 = ones(matsz).*x3;
    elseif matsz == sz3
    else
        error('Input matrix dimension mismatch!');
    end
end

% check if real mode
real_mode = isreal(x1)&isreal(x2)&isreal(x1);

if real_mode
    %% real mode
    
    % convert to custom precision format
    [t x1q] = convert_precision(x1, Mi, E, sn_on);
    [t x2q] = convert_precision(x2, Mi, E, sn_on);
    [t x3q] = convert_precision(x3, Mi, E, sn_on);
    
    % compute (x1*x2 + x3)
    mult_out = mult_core(x1q, x2q, Mi, E, Aext, sn_on);
    res_out = add_core(mult_out, extend_precision(x3q, Mi, E, Aext, sn_on), Mi, E, Aext, 1, sn_on);
    
    % convert to native format
    y = convert_double(res_out.s, res_out.e, res_out.m, Mi-1, E, 1, sn_on);
else
    %% complex mode
    x1_r = real(x1);
    x1_i = imag(x1);
    x2_r = real(x2);
    x2_i = imag(x2);
    x3_r = real(x3);
    x3_i = imag(x3);

    % convert to custom precision format
    [t x1q_r] = convert_precision(x1_r, Mi, E, sn_on);
    [t x1q_i] = convert_precision(x1_i, Mi, E, sn_on);
    [t x2q_r] = convert_precision(x2_r, Mi, E, sn_on);
    [t x2q_i] = convert_precision(x2_i, Mi, E, sn_on);
    [t x3q_r] = convert_precision(x3_r, Mi, E, sn_on);
    [t x3q_i] = convert_precision(x3_i, Mi, E, sn_on);

    % compute real part of (x1*x2 + x3)
    mult0_out = mult_core(x1q_r, x2q_r, Mi, E, Aext, sn_on);
    mult1_out = mult_core(x1q_i, ch_sign(x2q_i, N), Mi, E, Aext, sn_on);
    sum_out = add_core(mult0_out, mult1_out, Mi, E, Aext, 0, sn_on);
    res_out = add_core(sum_out, extend_precision(x3q_r, Mi, E, Aext, sn_on), Mi, E, Aext, 1, sn_on);
    
    % convert to native format
    y_r = convert_double(res_out.s, res_out.e, res_out.m, Mi-1, E, 1, sn_on);

    % compute imag part of (x1*x2 + x3)
    mult0_out = mult_core(x1q_r, x2q_i, Mi, E, Aext, sn_on);
    mult1_out = mult_core(x1q_i, x2q_r, Mi, E, Aext, sn_on);
    sum_out = add_core(mult0_out, mult1_out, Mi, E, Aext, 0, sn_on);
    res_out = add_core(sum_out, extend_precision(x3q_i, Mi, E, Aext, sn_on), Mi, E, Aext, 1, sn_on);
    
    % convert to native format
    y_i = convert_double(res_out.s, res_out.e, res_out.m, Mi-1, E, 1, sn_on);

    y = complex(y_r, y_i);
end

return;

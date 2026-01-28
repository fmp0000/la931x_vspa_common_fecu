% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y = ruby_mac(x1, x2, x3, Mi, E, Aext, sn_on)
%
% DESCRIPTION:
%   y = x3 + x1(1, :).*x2(1, :) + ... + x1(nrows, :).*x2(nrows, :)
%   Implements element by element (complex/real) multiply and add 
% 
% INPUTS:
%   x1: input matrix of dimensions MxN.
%   x2: input matrix of dimensions MxN.
%   x3: input vector of dimensions 1xN.
%   Mi: number of implicit mantissa bits in precision format
%   E: number of exponent bits in precision format
%   Aext: number of additional accumulator bits (including impllicit bit)
%   sn_on (OPTIONAL): 0=>sub-normalization OFF; 1=>sub-normalization ON [DEFAULT]
%
% OUTPUTS:
%   y: output matrix of dimensions 1xN.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = ruby_mac(x1, x2, x3, Mi, E, Aext, sn_on) 

%% config
if ~exist('sn_on', 'var')
    sn_on = 1;
end

% total number of bits
N = E + Mi;

%% input checks
% check and adjust dimensions
sz1 = size(x1);
sz2 = size(x2);
sz3 = size(x3);
if (sz3(1) > 1)
    error('Input argument x3 must be a row vector.');
end

if ~(sz1(2)==sz2(2) && sz2(2)==sz3(2))
    error('Input arguments x1, x2, x3 must have equal number of columns.');
end

if ~(sz1(1)==sz2(1))
    error('Input arguments x1, x2 must have matching dimensions.');
end
n_rows = sz1(1);

% check if real mode
real_mode = isreal(x1)&isreal(x2)&isreal(x3);
if real_mode
    %% real mode
    % convert to custom precision format
    [t x1q] = convert_precision(x1, Mi, E, sn_on);
    [t x2q] = convert_precision(x2, Mi, E, sn_on);
    [t x3q] = convert_precision(x3, Mi, E, sn_on);
    
    % accumulate
    accum = extend_precision(x3q, Mi, E, Aext, sn_on);
    for ii = 1:n_rows
        cr_in1 = struct('val', x1q.val(ii, :), 's', x1q.s(ii, :), 'e', x1q.e(ii, :), 'm', x1q.m(ii, :));
        cr_in2 = struct('val', x2q.val(ii, :), 's', x2q.s(ii, :), 'e', x2q.e(ii, :), 'm', x2q.m(ii, :));
        mult_out = mult_core(cr_in1, cr_in2, Mi, E, Aext, sn_on);
        res_out = add_core(mult_out, accum, Mi, E, Aext, 1, sn_on);
        accum = add_core(mult_out, accum, Mi, E, Aext, 0, sn_on);
    end
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

    accum_r = extend_precision(x3q_r, Mi, E, Aext, sn_on);
    accum_i = extend_precision(x3q_i, Mi, E, Aext, sn_on);
    for ii = 1:n_rows
        cr_in1_r = struct('val', x1q_r.val(ii, :), 's', x1q_r.s(ii, :), 'e', x1q_r.e(ii, :), 'm', x1q_r.m(ii, :));
        cr_in1_i = struct('val', x1q_i.val(ii, :), 's', x1q_i.s(ii, :), 'e', x1q_i.e(ii, :), 'm', x1q_i.m(ii, :));
        cr_in2_r = struct('val', x2q_r.val(ii, :), 's', x2q_r.s(ii, :), 'e', x2q_r.e(ii, :), 'm', x2q_r.m(ii, :));
        cr_in2_i = struct('val', x2q_i.val(ii, :), 's', x2q_i.s(ii, :), 'e', x2q_i.e(ii, :), 'm', x2q_i.m(ii, :));
        
        % accumulate real part
        mult0_out = mult_core(cr_in1_r, cr_in2_r, Mi, E, Aext, sn_on);
        mult1_out = mult_core(cr_in1_i, ch_sign(cr_in2_i, N), Mi, E, Aext, sn_on);
        sum_out = add_core(mult0_out, mult1_out, Mi, E, Aext, 0, sn_on);
        res_out = add_core(sum_out, accum_r, Mi, E, Aext, 1, sn_on);   % store normalized version out
        accum_r = add_core(sum_out, accum_r, Mi, E, Aext, 0, sn_on);   % store unnormalized version in accumulator

        % convert to native format
        y_r = convert_double(res_out.s, res_out.e, res_out.m, Mi-1, E, 1, sn_on);

        % accumulate imag part
        mult0_out = mult_core(cr_in1_r, cr_in2_i, Mi, E, Aext, sn_on);
        mult1_out = mult_core(cr_in1_i, cr_in2_r, Mi, E, Aext, sn_on);
        sum_out = add_core(mult0_out, mult1_out, Mi, E, Aext, 0, sn_on);
        res_out = add_core(sum_out, accum_i, Mi, E, Aext, 1, sn_on);   % store normalized version out
        accum_i = add_core(sum_out, accum_i, Mi, E, Aext, 0, sn_on);   % store unnormalized version in accumulator

        % convert to native format
        y_i = convert_double(res_out.s, res_out.e, res_out.m, Mi-1, E, 1, sn_on);
    end
    y = complex(y_r, y_i);
end

return;

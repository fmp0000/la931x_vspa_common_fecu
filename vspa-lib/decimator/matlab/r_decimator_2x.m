% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [out_v, next_hist_v] = r_decimator_2x(inp, flt, ctrl, inp_hist)
% 
% DESCRIPTION:
%   Performs time domain down sampling (decimation) with a factor of 2x and 
%   performs FIR filtering to avoid spectrum aliasing. This function is
%   implemented in VSPA precision and used to implement 4x and 8x decimators.
%
% INPUTS:
%   inp  - Nx1 complex time domain input vector in double precision
%        - conversion to VSPA precision is performed inside this function
% 
%   flt  - Mx1 REAL filter coefficients in double precision
%        - the filter coefficients are given in the natural order h[0],[h1], ...
%          but the VPSA implementation will use these coefficients with the
%          inverted order
%        - conversion to VSPA precision is performed inside this function
%
%   ctrl - control structure with the following fields:
%             - input_prec  - input precision for VSPA implementation
%             - filter_prec - filter precision for VSPA implementation
%             - output_prec - output precision for VSPA implementation
%        - the allowed precisions are:
%             - 'half_fixed': 16 bit fixed point
%             - 'half'      : 16 bit floating point
%             - 'single'    : 32 bit floating point
%             - 'double'    : 64 bit floating point
%
%   inp_hist - Kx1 complex time domain input history array in VSPA
%              precision with K = filter length - 1 used for the VSPA 
%              implementation
%            - the history for first input block should be all '0' 
%            - the history for next input block should be the
%             'next_hist_v' obtained from previous function call
%            - if this array is not explicitly given, it is initialized
%              with '0's (default)
% 
% OUTPUTS:
%   out_v - Nx1 complex time domain output vector in VSPA precision
%
%   next_hist_v - Kx1 complex time domain input history array in VSPA
%                 precision for next block processing
%
% NOTE:
%   In case this function is not used for block processing but as a one time
%   all decimation then the function can be used as (default history is 0):
%   [out_v] = r_decimator_2x(inp, flt, ctrl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function [out_v, next_hist_v] = r_decimator_2x(inp, flt, ctrl, inp_hist)

% Input validation
if ~all(imag(flt) == 0)
    error('Decimation FIR filter must be REAL!');
end

if mod(length(flt), 2)
    error('Decimation FIR filter length must be even');
end

% If rows make columns
inp = inp(:);
flt = flt(:);

% Default history (if not given) is all '0'
if nargin < 4
    inp_hist = zeros(length(flt) - 1, 1);
end

% Input history size validation
if ~(all(size(inp_hist) == [length(flt) - 1, 1]))
    error('Decimation input history size is not valid');
end

% --------------------------- VSPA implementation -------------------------
% Convert input and input history precision
inp_v      = r_convert(inp,      ctrl.input_prec, 'input array');
inp_hist_v = r_convert(inp_hist, ctrl.input_prec, 'input history array');

% Convert filter precision
flt_v = r_convert(flt, ctrl.filter_prec, 'filter array');

% Lengths
inp_len = length(inp_v);
flt_len = length(flt_v);

% Invert filter order
flt_v_i = flipud(flt_v);

% Prepend the input history
inp_v_p = [inp_hist_v; inp_v];

% Compute
V = zeros(inp_len, 1);

for iter_idx = 0 : (flt_len / 2 - 1)
    
    % Take each iteration 2 filter coefficients
    h0 = flt_v_i(iter_idx * 2 + 1);
    h1 = flt_v_i(iter_idx * 2 + 2);
    
    % Each iteration shifts input data with 2 samples                                    
    inp_idx = iter_idx * 2 + 1;
    aux = inp_v_p(inp_idx : (inp_idx + inp_len - 1));
    
    % S0mode = 'S0i1r1i1r1'
    S0 = repmat([h0; h1], inp_len, 1);          
                                             
    % S1mode = 'S1i2i1r2r1'
    S1 = [ reshape(real(aux), 2, []); 
           reshape(imag(aux), 2, [])];
    S1 = S1(:);

    % Perform complex cmad/cmac
    % V = r_smad(S0(1:2:end), S1(1:2:end), V);
    % V = r_smad(S0(2:2:end), S1(2:2:end), V);
    
    % Emulate 'cmac' with 'r_smac' - closer to bit-exact    
    S0c = S0(1:2:end) + 1i * S0(2:2:end);
    S1c = S1(2:2:end) + 1i * S1(1:2:end);
    Vc  = 0 + 1i * V;
    Vc  = r_smac(S0c.', S1c.', Vc.');
    V   = imag(Vc(:)); 

end

% Complex format
out_v = V(1:2:end) + 1i * V(2:2:end);

% Convert output precision
out_v = r_convert(out_v, ctrl.output_prec, 'output array');

% Output history (last flt_len - 1 samples)
next_hist_v = inp_v_p((end - flt_len + 2) : end);


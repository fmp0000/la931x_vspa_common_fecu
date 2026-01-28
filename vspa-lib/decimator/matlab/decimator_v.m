% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [out_v, next_hist_v] = decimator_v(inp, flt, ctrl, inp_hist_v)
% 
% DESCRIPTION:
%   Performs time domain down sampling (decimation) with factors of 2x, 4x,
%   8x and performs FIR filtering to avoid spectrum aliasing. The 4x and 8x
%   decimators are implemented as cascaded 2x decimators while using the
%   same filter for each 2x decimator.
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
%             - factor      - decimation factor (2,4,8)
%        - the allowed precisions are:
%             - 'half_fixed': 16 bit fixed point
%             - 'half'      : 16 bit floating point
%             - 'single'    : 32 bit floating point
%             - 'double'    : 64 bit floating point
%
%   inp_hist_v - KxP complex time domain input history matrix in VSPA
%                precision with K = filter length - 1 and P = log2(factor)
%                used for the VSPA implementation
%              - this matrix holds the input history for each 2x decimator
%              - the history for first input block should be all '0' 
%              - the history for next input block should be the
%                'next_hist_v' obtained from previous function call
%              - if this matrix is not explicitly given, it is initialized
%                with '0's (default)
%
% OUTPUTS:
%   out_v - Nx1 complex time domain output vector in VSPA precision
% 
%   next_hist_v - KxP complex time domain input history matrix in VSPA
%                 precision for next block processing
%
% NOTE:
%   In case this function is not used for block processing but as a one time
%   all decimation then the function can be used as (default history is 0):
%   out_v = decimator_v(inp, flt, ctrl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function [out_v, next_hist_v] = decimator_v(inp, flt, ctrl, inp_hist_v)

% Input validation
if ~ismember(ctrl.factor, [2,4,8])
    error('Decimation factor %d not supported', ctrl.factor);
end

% If rows make columns
inp = inp(:);
flt = flt(:);

% Default history (if not given) is all '0'
if nargin < 4
    inp_hist_v = zeros(length(flt) - 1, log2(ctrl.factor));
end

% Input history size validation
if ~(all(size(inp_hist_v) == [length(flt) - 1, log2(ctrl.factor)]))
    error('Decimation input history size is not valid');
end

% --------------------------- VSPA implementation -------------------------
% Initialize input history for next block
next_hist_v = zeros(size(inp_hist_v));

% Cascade 2x decimators
out_v = inp;

for idx = 1 : log2(ctrl.factor)
    [out_v, next_hist_v(:,idx)] = r_decimator_2x(out_v, flt, ctrl, inp_hist_v(:,idx));
end


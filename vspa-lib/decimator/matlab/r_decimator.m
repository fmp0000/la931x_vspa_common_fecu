% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [out_v, out_m, next_hist_v, next_hist_m] = r_decimator(inp, flt, ctrl, inp_hist_v, inp_hist_m)
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
%   inp_hist_m - KxP complex time domain input history matrix in Matlab double
%                precision with K = filter length - 1 and P = log2(factor)
%                used for the Matlab implementation
%              - this matrix holds the input history for each 2x decimator
%              - the history for first input block should be all '0' 
%              - the history for next input block should be the
%                'next_hist_m' obtained from previous function call
%              - if this matrix is not explicitly given, it is initialized
%                with '0's (default)
%
% OUTPUTS:
%   out_v - Nx1 complex time domain output vector in VSPA precision
% 
%   out_m - Nx1 complex time domain output vector in Matlab double
%           precision
% 
%   next_hist_v - KxP complex time domain input history matrix in VSPA
%                 precision for next block processing
%
%   next_hist_m - KxP complex time domain input history matrix in Matlab
%                 double precision for next block processing
%
% NOTE:
%   In case this function is not used for block processing but as a one time
%   all decimation then the function can be used as (default history is 0):
%   [out_v, out_m] = r_decimator(inp, flt, ctrl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function [out_v, out_m, next_hist_v, next_hist_m] = r_decimator(inp, flt, ctrl, inp_hist_v, inp_hist_m)

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
if nargin < 5
    inp_hist_m = zeros(length(flt) - 1, log2(ctrl.factor));
end

% Input history size validation
if ~(all(size(inp_hist_v) == [length(flt) - 1, log2(ctrl.factor)]))
    error('Decimation input history size is not valid');
end
if ~(all(size(inp_hist_m) == [length(flt) - 1, log2(ctrl.factor)]))
    error('Decimation input history size is not valid');
end

% -------------------------- Matlab implementation ------------------------
% Initialize input history for next block
next_hist_m = zeros(size(inp_hist_m));

% Cascade 2x decimators
out_m = inp;

for idx = 1 : log2(ctrl.factor)
    
    % Prepend history
    inp_p = [inp_hist_m(:, idx); out_m];
    
    % Input history for next call
    next_hist_m(:, idx) = inp_p((end - length(flt) + 2) : end);
    
    % Filter input with prepended history
    out_m = filter(flt, 1, inp_p);
    
    % Remove first flt_len - 1 output samples
    out_m(1 : (length(flt) - 1)) = [];
    
    % Decimate
    out_m = out_m(1:2:end);
end

% --------------------------- VSPA implementation -------------------------
% Initialize input history for next block
next_hist_v = zeros(size(inp_hist_v));

% Cascade 2x decimators
out_v = inp;

for idx = 1 : log2(ctrl.factor)
    [out_v, next_hist_v(:,idx)] = r_decimator_2x(out_v, flt, ctrl, inp_hist_v(:,idx));
end


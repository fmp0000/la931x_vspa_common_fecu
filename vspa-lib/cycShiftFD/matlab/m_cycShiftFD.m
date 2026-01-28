% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [out_m] = m_cycShiftFD(inp_m, ctrl)
%
% DESCRIPTION: 
%   Function that perform cyclic shift in frequency domain
%   y = x .* exp(1i * 2 * pi * nco_freq * nco_k * (nco_phase + (0:n-1)), 
%   where n is the length of x. 
%  
% INPUTS:
%   inp_m  : Input in Matlab precision
%
%   ctrl   : Control structure with the following fields:
%            shift    - number of sampels to shift
% OUTPUTS:
%   y_mat:      Output sequence Matlab precision
%
% Attention: function support input and output as half_float precision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out_m] = m_cycShiftFD(inp_m, ctrl)


% Params
shift = ctrl.shift;
len_seq = length(inp_m);

% NCO_FREQ initialization
nco_freq  =  round((shift  * 2^32) / len_seq) / 2^32;
nco_phase = 0;
nco_k     = 1;
% ========================= Matlab model ==================================

out_m = inp_m.* exp(-1i * 2 * pi * nco_freq * nco_k * (nco_phase + (0:len_seq-1))).';



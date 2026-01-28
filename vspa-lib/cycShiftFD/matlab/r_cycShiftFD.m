% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [out_v, out_m] = r_cycShiftFD(inp_v, inp_m, ctrl)
%
% DESCRIPTION: 
%   Function that perform cyclic shift in frequency domain
%   y = x .* exp(1i * 2 * pi * nco_freq * (PhaseIn + (0:n-1)), 
%   where n is the length of x. 
%  
% INPUTS:
%   inp_v  : Input in VSPA precision
%
%   ctrl   : Control structure with the following fields:
%            shift    - number of sampels to shift
% (Optional) inp_prec - input_precision  
%            out_pre  - output_precision
% OUTPUTS:
%   y_vsp:      Output sequence VSPA precision 
%
% Attention: function support input and output as half_float precision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out_v] = r_cycShiftFD(inp_v, ctrl)


% Params
shift = ctrl.shift;
len_seq = length(inp_v);
size_inp_v = size(inp_v);

if (isfield(ctrl,'inp_prec') && isfield(ctrl,'out_prec'))
    inp_prec = ctrl.inp_prec;
    out_prec = ctrl.out_prec;
else
    inp_prec = 'half';
    out_prec = 'half';
end

% NCO_FREQ initialization
nco_freq  =  round((shift  * 2^32) / len_seq)/2^32;
nco_phase = 0;
nco_k     = 1;
% ========================== VSPA model ===================================
% Convert input precision

inp_v = r_convert(inp_v(:), inp_prec, 'input vector');

% Perform cyclic shift

nco_vec = r_nco(nco_freq*nco_k, length(inp_v), nco_phase).';
out_v = r_smad(inp_v, nco_vec, 0); 

% Convert output precision

out_v = r_convert(out_v(:), out_prec, 'output vector');
out_v = reshape(out_v, size_inp_v);


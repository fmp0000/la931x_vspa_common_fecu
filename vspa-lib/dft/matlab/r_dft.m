% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [dft_v] = r_dft(inp_v, ctrl)
% DESCRIPTION:
%   Function to perform DFT.
%
% INPUTS:
%   inp_v: Input in VSPA precision
%
%   ctrl:  Control structure with the following fields:
%        inp_prec - input_precision
%        out_pre  - output_precision
%        - the allowed precisions are:
%             - 'half_fixed': 16 bit fixed point
%             - 'half'      : 16 bit floating point
%             - 'single'    : 32 bit floating point
%             - 'double'    : 64 bit floating point
%        - default is set: inp_prec - half fixed
%                          out_prec - half
% OUTPUTS:
%   dft_v:    DFT sequence (VSPA precision).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dft_v] = r_dft(inp_v, ctrl)

% Params
N = length(inp_v);
if nargin < 2
    inp_prec = 'half_fixed';
    out_prec = 'half';
else
    inp_prec = ctrl.inp_prec;
    out_prec = ctrl.out_prec;
end
size_inp_v = size(inp_v);

% ========================== VSPA model ===================================
% Convert input precision

inp_v = r_convert(inp_v(:), inp_prec, 'input vector');
inp_v = reshape(inp_v, size_inp_v);

% NCO_FREQ initialization
nco_freq = round(2^31/N);

% Number of NCO vectors

s0_v = zeros(1, N);

% Compute exterior loop
for n = 0 : N-1
    
    nco_phase = 0;
    nco_k = 2*n;
    S0 = inp_v(n + 1);
    S1 = r_nco(nco_freq * nco_k / 2^32, N, nco_phase);
    S2 = s0_v;
    s0_v = r_smad(S0,S1,S2);
    
end
dft_v = s0_v.';
dft_v = dft_v(:);
dft_v = dft_v(1:N);

% Convert output precision

dft_v = r_convert(dft_v(:), out_prec, 'output vector');
dft_v = reshape(dft_v, size(dft_v));

end

% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [[dft_m] = m_dft(inp_m)
% DESCRIPTION:
%   Function to perform DFT.
%
% INPUTS:
%   inp_m: Input in Matlab precision
%
% OUTPUTS:
%   dft_m:    DFT sequence (Matlab precision).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dft_m] = m_dft(inp_m)

% ========================= Matlab model ==================================
dft_m = fft(inp_m).';

end

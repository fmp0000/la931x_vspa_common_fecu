% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y, y_bx] = fd_qec(x, x_m, a, b,  size)
% DESCRIPTION:
%            Implements the 11a, 11n and 11ac Frequency domin quadrature
%            error correction
% 
%   Input arguments:
%     x   : input buffer
%     x_m : mirror of input buffer
%     a   : weights for x
%     b   : weights for input x_m  
%     size: fft size
%
%   Return values:
%       y: compensated signal, matlab version.
%       y_bx: ompensated signal, bit exact version.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y, y_bx] = fd_qec(x_r , x_m, a, b)
y = x_r.*a + x_m.*b;
%% Bit exact
 y_tmp  = r_smad(x_r, a, zeros(size(x_r)));
 y_bx   = r_smad(x_m, b, y_tmp);

end

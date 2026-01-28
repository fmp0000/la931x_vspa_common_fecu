% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y_vsp, y_mat, dbg] = r_chp_chf_csp_vmult(x1,x2)
% DESCRIPTION: 
%               Elementwise vector-multiplication: y = x1.*x2.
%  
% INPUTS:
%   x1:          nx1 in complex, 16-bit half-precision fixed-point
%   x2:          nx1 in complex, 32-bit single-precision floating-point
%
% OUTPUTS:
%   y_vsp:      x1.*x2, nx1 in complex, 16-bit half-precision floating-point
%   y_mat:      x1.*x2, nx1 in complex, matlab double precision.
%   dbg:        y_vsp_fp32: x1.*x2, nx1 in complex, 32-bit single-precision floating-point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y_vsp, y_mat, dbg] = r_chp_chf_csp_vmult(x1,x2)

n = length(x1);
assert(n==length(x2),'size mismatch');
assert(iscolumn(x1) && iscolumn(x2),'x1 and x2 should be a column vector');

%% matlab
y_mat = x1.*x2;

%% vspa output
y_vsp_fp32  = r_smad(x1, x2, zeros(n,1));
y_vsp       = r_half_flt( y_vsp_fp32 );

%% debug info
dbg.y_vsp_fp32 = y_vsp_fp32;

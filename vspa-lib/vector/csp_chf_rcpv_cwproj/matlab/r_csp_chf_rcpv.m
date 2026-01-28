% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y_vsp, y_mat, dbg] = r_csp_chf_rcpv(x)
% DESCRIPTION: 
%               Elementwise vector-reciprocal: y = 1./x.
%  
% INPUTS:
%   x:          nx1 in complex, 16-bit half-precision fixed-point
%
% OUTPUTS:
%   y_vsp:      1./x, nx1 in complex, 32-bit single-precision floating-point
%   y_mat:      1./x, nx1 in complex, matlab double precision.
%   dbg:        y_vsp_fp16: 1./x, nx1 in complex, 16-bit half-precision floating-point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y_vsp, y_mat, dbg] = r_csp_chf_rcpv(x)

n = length(x);
assert(iscolumn(x),'x should be a column vector');

%% matlab
y_mat = conj(x) ./ abs(x).^2;

%% vspa output
xabs2       = real( r_smad(x', x.', zeros(1,n)) );
xabs2_inv	= r_rcp(xabs2, 'lo');
y_vsp       = r_smad(x', xabs2_inv, zeros(1,n)).';

%% debug info
dbg.y_vsp_fp16 = r_half_flt(y_vsp);

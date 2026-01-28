% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y_vsp, y_mat, dbg] = r_vAddSclr(x, alpha, out_prec)
% DESCRIPTION: 
%               y = x + alpha, where x,y are Nx1 vector, alpha is a scalar.
%  
% INPUTS:
%   x:          nx1 in real or complex.     Precision depends on out_prec.
%   alpha:      a real or complex scalar.   Precision depends on out_prec. 
%   out_prec:   0: single, 1: half, 2: half-fixed.
%
% OUTPUTS:
%   y_vsp:      nx1 vector. Real/complex type is the same as x. Precision depends on SP_HPswitch. 
%   y_mat:      nx1 in matlab double precision.
%   dbg:        not used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y_vsp, y_mat, dbg] = r_vAddSclr(x, alpha, out_prec)

n = length(x);
assert(iscolumn(x),'x should be a column vector');
assert(length(alpha)==1, 'alpha should be a scalar'); 

%% matlab
y_mat = x + alpha;

%% vspa output
tmp = r_smad(x, ones(size(x)), alpha*ones(size(x)));
if(out_prec==0)
    y_vsp = r_single(tmp);
elseif(out_prec==1)
    y_vsp=r_half_flt(tmp);
elseif(out_prec==2)    
    y_vsp=r_half(tmp);
else
    error('incorrect out_prec');
end

%% debug info
dbg = [];

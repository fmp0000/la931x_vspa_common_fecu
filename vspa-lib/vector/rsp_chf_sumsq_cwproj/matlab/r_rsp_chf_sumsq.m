% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y_vsp, y_mat, dbg] = r_rsp_chf_sumsq(x, offset_x)
% DESCRIPTION: 
%               Sum of squared: y = sum( abs( x ).^2 )
%  
% INPUTS:
%   x:          nx1 in complex, 16-bit half-precision fixed-point
%   offset_x:   offset of x relative to the starting point of DMEM line. This is needed for VSPA implementation BE check.
%               If x is vector-aligned, offset_x = 0;
%
% OUTPUTS:
%   y_vsp:      sum( abs( x ).^2 ), a scalar in real, 32-bit single-precision floating-point
%   y_mat:      sum( abs( x ).^2 ), a scalar in real, matlab double precision.
%   dbg:        not used
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y_vsp, y_mat, dbg] = r_rsp_chf_sumsq(x, offset_x)

n = length(x);
assert(iscolumn(x),'x should be a column vector');
assert(0<=offset_x && offset_x<=31,'offset of x should be in [0,31)');

%% matlab
y_mat = real( sum(abs(x).^2) );

%% vspa output

% re-arrange x according to VSPA implementation
if offset_x > 0 
    t1 = [x(end-offset_x+1:end); x(1:32-offset_x)];
    t2 = x(32-offset_x+1 : end-offset_x);
    x = [t1;t2];
end

% obtain one line
tmp     = reshape([x; zeros(ceil(n/32)*32-n,1)], 32, []).';
y_line  = real( r_smac( conj(tmp) , tmp, zeros(1,32) ) );

% sum this line
% To model cmac + wr.hlinecplx behaviour: Merge first, then accumulate
% Table 4-39: V[i][n] = (S0[i][n-4]*S1[i][n-4]) + (S0[i+1][n-4]*S1[i+1][n-4]) + V[i][n-1] for i=0,2,4,6,...,62
V = [0 0];
y1 = y_line(1:4:end).';
y2 = y_line(2:4:end).';
y3 = y_line(3:4:end).';
y4 = y_line(4:4:end).';
for k=1:8   
    merged(1) = r_smad( y1(k,:), 1, y2(k,:));
    merged(2) = r_smad( y3(k,:), 1, y4(k,:));
    V = r_smad( merged, [1 1], V );
end
y_vsp   = r_smad( V(1), 1, V(2) ); 

%% debug info
dbg = [];

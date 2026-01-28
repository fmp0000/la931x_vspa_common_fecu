% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y_vsp, y_mat, dbg] = r_mixer(x,PhaseIn,FreqIn)
% DESCRIPTION:  y = x .* exp(1j*2*pi* (FreqIn/2^32) * (PhaseIn + (0:n-1)), where n is the length of x. 
%  
% INPUTS:
%   x :         nx1 in complex, 16-bit half-precision fixed-point
%   PhaseIn:    input NCO phase represented as an unsigned 32-bit integer
%   FreqIn:     base NCO frequency represented as a 32-bit signed integer (in 1's complement format)
%
% OUTPUTS:
%   y_vsp:      y, nx1 in complex, 16-bit half-precision fixed-point
%   y_mat:      y, nx1 in complex, matlab double precision.
%   dbg:        PhaseOut: n, the NCO phase ready for mixing the next batch of input samples.
%
% Note: r_nco.m takes FreqIn/2^32 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y_vsp, y_mat, dbg] = r_mixer(x,PhaseIn,FreqIn)

n = length(x);
assert(iscolumn(x),'x should be a column vector');

%% matlab
y_mat = x.* exp(1j*2*pi* (FreqIn/2^32) * (PhaseIn + (0:n-1))).';

%% vspa output
m = conj( r_nco(FreqIn/2^32, length(x),PhaseIn) ).';
y_vsp = r_half( r_smad(x, m, 0) ); % Needs "conj" because "r_nco.m" generates exp( - 1j*2*pi* (FreqIn/2^32) * (PhaseIn + (0:n-1)) 

%% debug info
dbg.PhaseOut = mod(PhaseIn + n, 2^32);

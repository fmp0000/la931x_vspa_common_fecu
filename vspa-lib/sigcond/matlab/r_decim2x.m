% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [ybe yfp ipstruct]  = r_decim2x(x, h)
% 
% DESCRIPTION:
%   Polyphase 2x decimator bit exact implementation on VSPA with half fixed
%   precision real taps and half fixed precision complex input data. Output
%   is half fixed complex. 
%
% INPUTS:
%   x: Vector of complex input samples. In half fixed precision.
%
%   h: Lfx1 vector of real decimation filter coefficients. Lf is assumed to
%   be at highest rate and should be an even number. In half fixed
%   precision. 
% 
% OUTPUTS:
%   ybe: Vector of complex output samples (in VSPA half fixed precision). 
% 
%   yfp: Vector of complex output samples (in MATLAB double precision).
% 
%   ipstruct: Struct containing intermediate and rounded inputs with the
%   following fields
%       x: half fixed rounded input vector x
%       h: half fixed rounded and formatted taps
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ybe, yfp, ipstruct]  = r_decim2x(x, h)

%% adapt dimensions of input vectors
if ~isvector(x)
    error('Input data must be a vector.');
end
rowflag = 0;
if (size(x, 1) == 1)
    rowflag = 1;
end

x = reshape(x, [], 1);

%% calculate input vector sizes
Lfull = size(h, 1);
M = length(x) - Lfull + 1;

if mod(Lfull, 2) ~= 0
    error('Length of decimation taps vector, h, must be an integer multiple of 2');
end
L = Lfull/2;

%% initalize data structures
x_full = x;
x_full_rby = r_half(x_full);
ipstruct.x = x_full_rby;

h_phase0_taps = h(2:2:end, :);
h_phase1_taps = h(1:2:end, :);

h_phase0_taps_fp = h_phase0_taps(L:-1:1);
h_phase1_taps_fp = h_phase1_taps(L:-1:1);
h_phase0_taps_rby = r_half(h_phase0_taps_fp);
h_phase1_taps_rby = r_half(h_phase1_taps_fp);

ipstruct.h = reshape([h_phase0_taps_rby.'; h_phase1_taps_rby.'], [], 1);

x_in_fp = x_full;
x_in_rby = x_full_rby;

n_input_samples = M;
x_out_fp = zeros(ceil(n_input_samples/2), 1);
x_out_rby = zeros(ceil(n_input_samples/2), 1);

% decimate
for ii = 0:2:n_input_samples-1
    x_out_fp(ii/2 + 1) = x_in_fp(ii + (1:2:2*L)).'*h_phase0_taps_fp + x_in_fp(ii + (2:2:2*L)).'*h_phase1_taps_fp;

    temp1 = r_smac([x_in_rby(ii + (1:2:2*L)).'; x_in_rby(ii + (2:2:2*L)).'], [h_phase0_taps_rby.'; h_phase1_taps_rby.'], zeros(1, L));
    x_out_rby(ii/2 + 1) = r_smac(temp1.', ones(L, 1), 0);
end

yfp = x_out_fp;
ybe = r_half(x_out_rby);

% shape output vectors to be row/column vector based on input vector type
if rowflag
    yfp = reshape(yfp, 1, []);
    ybe = reshape(ybe, 1, []);
end

return;


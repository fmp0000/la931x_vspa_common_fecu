% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [out_v, out_m] = r_freq_domain_corr(inp_v, gain_v, phase_ramp_v, phase_init_v, inp_m, gain_m, phase_ramp_m, phase_init_m, ctrl)
%
% DESCRIPTION:
%   Frequency domain correction consisting in:
%       - frequency non-selective multiplication with a complex gain
%       - phase ramp correction for fractional timing correction
%
% INPUTS:
%   inp_v:         num_sbc x 1 x num_streams symbols   (VSPA precision)
%   gain_v:        complex gain applied to all symbols (VSPA precision)
%   phase_ramp_v:  phase ramp to pe applied            (VSPA precision)
%   phase_init_v:  initial phase of the ramp           (VSPA precision)
%   inp_m:         num_sbc x 1 x num_streams symbols   (Matlab precision)
%   gain_m:        complex gain applied to all symbols (Matlab precision)
%   phase_ramp_m:  phase ramp to pe applied            (Matlab precision)
%   phase_init_m:  initial phase of the ramp           (Matlab precision)
%   ctrl:          (Optional) control dynamic structure with the following fields:
%                 - inp_prec  - input precision (default Half Precision)
%                 - gain_prec - complex gain precision (default Single Precision)
%                 - out_prec  - output precision (default Half Precision)
%
% DESCRIPTION:
%   out_v:        num_sbc x 1 x num_streams output corrected symbols (VSPA   precision).
%   out_m:        num_sbc x 1 x num_streams output corrected symbols (Matlab precision).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out_v, out_m] = r_freq_domain_corr(inp_v, gain_v, phase_ramp_v, phase_init_v, inp_m, gain_m, phase_ramp_m, phase_init_m, ctrl)

% Parameters
num_sbc     = size(inp_m, 1);
num_streams = size(inp_m, 3);

% Convert phase ramps to double
phase_ramp_v = double(phase_ramp_v);
phase_ramp_m = double(phase_ramp_m);

% ---------------------- Matlab implementation ----------------------------
% Generate phase ramp
sbc_idx = phase_init_m + (0 : (num_sbc - 1));
phase_ramp_m = gain_m .* exp(-1i * 2 * pi * phase_ramp_m / 2^32 * sbc_idx);

% Apply phase ramp
for stream_idx = 1 : num_streams
    inp_m(:,1,stream_idx) = inp_m(:,1,stream_idx) .* phase_ramp_m(:);
end

% Matlab output
out_m = inp_m;

% ----------------------- VSPA implementation -----------------------------
% Default structure params
if (nargin <= 8)
    ctrl.inp_prec  = 'half';
    ctrl.gain_prec = 'single';
    ctrl.out_prec  = 'half';
end

% Convert input precision
temp = r_convert(inp_v(:), ctrl.inp_prec);
inp_v = reshape(temp, size(inp_v));

% Convert gain precision
gain_v = r_convert(gain_v, ctrl.gain_prec);

% Generate phase ramp
nco_freq_v  = phase_ramp_v / 2^32;
nco_phase_v = typecast(int32(phase_init_v), 'uint32');
nco_phase_v = double(nco_phase_v);
phase_ramp_v = r_nco(nco_freq_v, num_sbc, nco_phase_v);
phase_ramp_v = r_smad(phase_ramp_v, gain_v,0);
phase_ramp_v = r_half_flt(phase_ramp_v);

% Apply phase ramp
for stream_idx = 1 : num_streams
    inp_v(:,1,stream_idx) = r_smad(inp_v(:,1,stream_idx), phase_ramp_v(:), 0);
end

% Output precision conversion
temp = r_convert(inp_v(:), ctrl.out_prec);
out_v = reshape(temp, size(inp_v));

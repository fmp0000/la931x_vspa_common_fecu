% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y_vsp y_dbl output_struct] = r_dif_fft(x_dbl, inv_flag, prec_type, scale_out)
% 
% DESCRIPTION:
%   Computes N pt FFT using decimation in frequency (DIF) approach using
%   VSPA AU model
%
% INPUTS:
%   x_dbl: Nx1 complex FFT input vector
% 
%   inv_flag: 0 => FFT, 1 => IFFT.
%  
%   prec_type: Precision type for FFT
%       'half_fixed': 16 bit fixed point precision mode
%       'half': 16 bit floating point precision mode
%       'single': single precision mode
% 
%   scale_out (OPTIONAL): 0 => unscaled output, 1 => output is scaled by
%       1/N. DEFAULTS to 0.
% 
% OUTPUTS:
%   y_rby: Nx1 complex FFT output vector in VSPA precision
% 
%   y_rby: Output vector based on formula above as implemented in double
%   precision MATLAB
% 
%   rnd_ip_struct: struct containing precision rounded input values
%       x: rounded input vector, x
%       stage_out: Nxlog2(N) matrix containing output of each FFT stage
%       qns: Quantization noise to signal ratio for FFT on VSPA precision
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y_vsp, y_dbl, output_struct] = r_dif_fft(x_dbl, inv_flag, prec_type, scale_out)

%% input & output processing
if ~exist('scale_out', 'var')
    scale_out = 0;
end

N = length(x_dbl);
n_stages = log2(N);
output_struct = struct('stage_out', zeros(N, n_stages), 'x', zeros(N, 1), 'qns', 0);
br_index = bitrevorder(0:N-1)+1;

%% compute
scale_fact = 1;
if (scale_out == 1) && strcmp(prec_type, 'half_fixed')
    scale_fact = 2;
end

if inv_flag
    y_dbl = N*ifft(x_dbl)/(scale_fact^n_stages);
else
    y_dbl = fft(x_dbl)/(scale_fact^n_stages);
end

y_vsp = x_dbl;
n_samples_grp = N/2;
n_groups = 1;
freq = 1/N;
for stage_i = 1:n_stages
    if inv_flag
        twf = r_nco(-freq*n_groups, n_samples_grp, 0).';
    else
        twf = r_nco(freq*n_groups, n_samples_grp, 0).';
    end
    for group_i = 1:n_groups
        grp_offset = (group_i-1)*n_samples_grp*2;
        T1 = y_vsp(grp_offset + (1:n_samples_grp));
        T2 = y_vsp(grp_offset + n_samples_grp + (1:n_samples_grp));
        y_vsp(grp_offset + (1:n_samples_grp)) = r_smad(T2, 1, T1);
        y_vsp(grp_offset + n_samples_grp + (1:n_samples_grp)) = r_smad(-T2, twf, r_smad(T1, twf, 0));
    end
    if strcmp(prec_type, 'half_fixed')
        y_vsp = r_half(y_vsp/scale_fact);
    elseif strcmp(prec_type, 'half')
        y_vsp = r_half_flt(y_vsp);
    else    
        y_vsp = r_single(y_vsp);
    end
    output_struct.stage_out(:, stage_i) = y_vsp;
    n_samples_grp = n_samples_grp/2;
    n_groups = n_groups*2;
end

y_vsp(br_index) = y_vsp;
prec_error = y_dbl - y_vsp;
output_struct.qns = 10*log10(mean(abs(prec_error).^2)/mean(abs(y_dbl).^2));


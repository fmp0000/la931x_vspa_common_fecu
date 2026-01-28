% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y_rby y_dbl output_struct] = r_dit_fft(x_dbl, inv_flag, prec_type, scale_out)
% 
% DESCRIPTION:
%   Computes N pt FFT using decimation in time (DIT) approach using
%   VSPA AU model
%
% INPUTS:
%   x: Nx1 complex FFT input vector in VSPA precision
% 
%   inv_flag: 0=>FFT, 1=>IFFT
% 
%   prec_type: Precision type for FFT
%       'half_fixed': 16 bit fixed point precision mode
%       'single': single precision mode
%       'mixed': mixed precision mode
% 
%   scale_out: 0 => unscaled output, 1 => output is scaled by 1/N (only
%       valid for half-fixed precision)
% 
% OUTPUTS:
%   y_rby: Nx1 complex FFT output vector in VSPA precision
% 
%   y_rby: Output vector based on formula above as implemented in double
%   precision MATLAB
% 
%   rnd_ip_struct: struct containing precision rounded input values
%       stage_out: Nxlog2(N) matrix containing output of each FFT stage
%       qns: Quantization noise to signal ratio for FFT on VSPA precision
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y_rby, y_dbl, output_struct] = r_dit_fft(x, inv_flag, prec_type, scale_out)

%% input & output processing
N = length(x);
n_stages = log2(N);
n_vrastages = 9;

output_struct = struct('stage_out', zeros(N, n_stages), 'x', zeros(N, 1), 'qns', 0);

%% compute
n_scalestages = max(n_stages-n_vrastages, 0);

scale_fact = 1;
if strcmp(prec_type, 'half_fixed') && (scale_out == 1)
    scale_fact = 2;
end

if strcmp(prec_type, 'half_fixed')
    fft_scale_fact = scale_fact^n_stages;
elseif strcmp(prec_type, 'mixed')
    fft_scale_fact = scale_fact^n_scalestages;
else
    fft_scale_fact = 1;
end

if ~inv_flag
    y_dbl = fft(x)/fft_scale_fact;
else
    y_dbl = N*ifft(x)/fft_scale_fact;
end

y_rby = x(bitrevorder(0:N-1)+1);
n_samples_grp = 1;
n_groups = N/2;
freq = 1/N;
output_struct.twf_out = zeros(N, n_stages);
for stage_i = 1:n_stages
    if ~inv_flag
        twf = r_nco(freq*n_groups, n_samples_grp, 0).';
    else
        twf = r_nco(-freq*n_groups, n_samples_grp, 0).';
    end
    output_struct.twf_out(:, stage_i) = repmat(twf, n_groups*2, 1);
    
    for group_i = 1:n_groups
        grp_offset = (group_i-1)*n_samples_grp*2;
        T1 = y_rby(grp_offset + (1:n_samples_grp));
        T2 = y_rby(grp_offset + n_samples_grp + (1:n_samples_grp));
        
        y_rby(grp_offset + (1:n_samples_grp)) = r_smad(T2, twf, T1);
        y_rby(grp_offset + n_samples_grp + (1:n_samples_grp)) = r_smad(-T2, twf, T1);
    end
    
    if strcmp(prec_type, 'half_fixed')
        y_rby = r_half(y_rby/scale_fact);
    elseif strcmp(prec_type, 'mixed')
        if stage_i > (n_stages-n_scalestages)
            y_rby = r_half(y_rby/scale_fact);
        else
            y_rby = r_single(y_rby);
        end
    else
        y_rby = r_single(y_rby);
    end
    
    output_struct.stage_out(:, stage_i) = y_rby;
    n_samples_grp = n_samples_grp*2;
    n_groups = n_groups/2;
end

prec_error = y_dbl - y_rby;
output_struct.qns = 10*log10(mean(abs(prec_error).^2)/mean(abs(y_dbl).^2));


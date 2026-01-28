% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script regressionTestVectorGen

addpath ../../matlab;
clear;

%% config
fftsz_set = [128 512 1024 2048];
input_offset = 31;

% prec_type:
% 0=>HFL in, HFX out
% 1=>HFL in, SFL out (for FFT), HFL in, SFL intermediate, HFX out (for IFFT)
% 2=>SFL in, SFL out
%

% generate FFT test vectors
inv = 0;
for ii = 1:length(fftsz_set)
    N = fftsz_set(ii);
    
    prec_type = 0;
    ditfft_testbench(N, inv, prec_type, input_offset, sprintf('fft%d_type%d', N, prec_type));
        
    prec_type = 1;
    ditfft_testbench(N, inv, prec_type, input_offset, sprintf('fft%d_type%d', N, prec_type));
    
    prec_type = 2;
    if N == 512
        ditfft_testbench(N, inv, prec_type, input_offset, sprintf('fft%d_type%d', N, prec_type));
    end
end

% generate IFFT test vectors
inv = 1;
for ii = 1:length(fftsz_set)
    N = fftsz_set(ii);
    
    prec_type = 0;
    ditfft_testbench(N, inv, prec_type, input_offset, sprintf('ifft%d_type%d', N, prec_type));
    
    prec_type = 1;
    ditfft_testbench(N, inv, prec_type, input_offset, sprintf('ifft%d_type%d', N, prec_type));
    
    prec_type = 2;
    if N == 512
        ditfft_testbench(N, inv, prec_type, input_offset, sprintf('fft%d_type%d', N, prec_type));
    end
end

fprintf('DONE\n');

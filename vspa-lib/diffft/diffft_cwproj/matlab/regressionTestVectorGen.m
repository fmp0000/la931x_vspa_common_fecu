% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script regressionTestVectorGen

addpath ../../matlab;
clear;

%% config
fftsz_set = [64 128 256 512 1024 2048];
input_offset = 4096+32-65;

% prec_type:
% 0=>HFX in, SFL out
% 1=>HFX in, HFX out
% 2=>HFX in, HFL out
%

% generate FFT test vectors
inv = 0;
for ii = 1:length(fftsz_set)
    N = fftsz_set(ii);
    
    prec_type = 0;
    diffft_testbench(N, inv, prec_type, input_offset, sprintf('fft%d_type%d', N, prec_type));
        
    prec_type = 1;
    diffft_testbench(N, inv, prec_type, input_offset, sprintf('fft%d_type%d', N, prec_type));
    
    prec_type = 2;
    diffft_testbench(N, inv, prec_type, input_offset, sprintf('fft%d_type%d', N, prec_type));
end

% generate IFFT test vectors
inv = 1;
for ii = 1:length(fftsz_set)
    N = fftsz_set(ii);
    
    prec_type = 0;
    diffft_testbench(N, inv, prec_type, input_offset, sprintf('ifft%d_type%d', N, prec_type));
    
    prec_type = 1;
    diffft_testbench(N, inv, prec_type, input_offset, sprintf('ifft%d_type%d', N, prec_type));
    
    prec_type = 2;
    diffft_testbench(N, inv, prec_type, input_offset, sprintf('ifft%d_type%d', N, prec_type));
end

fprintf('DONE\n');

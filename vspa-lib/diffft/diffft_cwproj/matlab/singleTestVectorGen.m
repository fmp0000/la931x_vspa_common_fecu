% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script singleTestVectorGen

addpath ../../matlab;
clear;

%% config
N = 2048;
inv = 1;
input_offset = 4096+32-65;

% 0=>HFX in, SFL out
% 1=>HFX in, HFX out
% 2=>HFX in, HFL out
prec_type = 0; 
test_name = 'generic';
%

diffft_testbench(N, inv, prec_type, input_offset, test_name);

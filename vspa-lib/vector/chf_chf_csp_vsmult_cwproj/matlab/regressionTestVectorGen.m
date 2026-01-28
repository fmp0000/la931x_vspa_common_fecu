% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script singleTestVectorGen
% generates test vector one use case 

clear;

% Add path
addpath('..\..\matlab\');

% Set seed for reproducibility
rng(0);

N = 512;
n_batches = 4;
testname = 'vectorXscalar_512';
vectorXscalar_testbench(N,testname);

N = 2048;
n_batches = 4;
testname = 'vectorXscalar_2048';
vectorXscalar_testbench(N,testname);


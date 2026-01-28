% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script singleTestVectorGen
% generates test vector one use case 

clear;

% Add path
addpath('..\..\matlab\');

% Set seed for reproducibility
rng('default');

N = 512;
n_batches = 2;
testname = 'generic';
txiqcomp_testbench(N, n_batches, testname);

N = 512;
n_batches = 4;
testname = 'txiqcomp2_512';
txiqcomp2_testbench(N, n_batches, testname);




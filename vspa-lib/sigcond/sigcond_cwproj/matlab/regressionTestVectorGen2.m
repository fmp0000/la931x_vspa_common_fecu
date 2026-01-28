% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script regressionTestVectorGen
% generates test vectors for regressiong testing of signal conditioning
% processing chain
addpath('../../../common/matlab/utils');
addpath('../../../common/matlab/vspa');
addpath('../../matlab');

clear;

%% config
n_batches = 4;
freq = -23.3565247;                             % channel frequency in MHz
n_iqsstaps = 5;

fegain = 1;                                     % front end complex gain
dcoff = 0.1*complex(rand, rand);                % complex DC offset
%

%% test 1: N = 2560
N = 2560;

BW = 80;
testname = sprintf('test2_N%d_BW%d', N, BW);
sigcond2_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname);

%% test 2: N = 640
N = 640;

BW = 80;
testname = sprintf('test2_N%d_BW%d', N, BW);
sigcond2_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname);

BW = 40;
testname = sprintf('test2_N%d_BW%d', N, BW);
sigcond2_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname);

BW = 20;
testname = sprintf('test2_N%d_BW%d', N, BW);
sigcond2_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname);

%% test 3: N = 256
N = 256;

BW = 80;
testname = sprintf('test2_N%d_BW%d', N, BW);
sigcond2_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname);

BW = 40;
testname = sprintf('test2_N%d_BW%d', N, BW);
sigcond2_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname);

BW = 20;
testname = sprintf('test2_N%d_BW%d', N, BW);
sigcond2_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname);


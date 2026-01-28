% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2017 - 2025 the original authors
%
%**************************************************************************
% Scope:
% Test bench for bitRev
%
%**************************************************************************
%
% Revision History:
%  - version 1.0 : Jul 06 2017
%**************************************************************************



%% Test bench init
close all
clc
clear all

%% Paths to other folders
addpath('./../../../common/matlab/vspa')      %path to common functions
addpath('./../../matlab')                   %path the function to be tested


%% Reset Random Seed
seed=0;
rand('state',seed);
randn('state',seed);


%% Parameters
% path to reference design
cwProj = strrep([pwd '\..'],'\',filesep); %CW project is 1 level up

%% Signal generation & conditioning
fftsize=256;
data=[1:fftsize]';

%% save input vector for VSPA
[~, ~, ~]=mkdir(cwProj,'test_vectors');
disp('Saving input data for VSPA...')
dram1 = dmemCreate( 0, length(data) );
dram1 = dmemWriteReal( dram1, 0, data, 'uint' );
dmemSaveHexFile( dram1, strrep([cwProj,'\test_vectors\input.hex'],'\',filesep));

%% Matlab bit-exact
[out_ext] = r_bitRev(data);

%% save output signal
dram1 = dmemCreate( 0, length(out_ext) );
dram1 = dmemWriteReal( dram1, 0, out_ext, 'uint' );
dmemSaveHexFile( dram1, strrep([cwProj,'\test_vectors\bitRev_output_be.hex'],'\',filesep));

return;


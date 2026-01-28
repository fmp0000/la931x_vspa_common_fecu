% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2017 - 2025 the original authors
%**************************************************************************
% Scope:
% Test bench for bitRev128
%
%**************************************************************************
%
% Revision History:
%  - version 1.0 : 27 Jun 2017
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
input = (1:128).';

input_shift = [input(65:end); input(1:64)];

br_index = bitrevorder(0:127) + 1;
input_reOrd = input_shift(br_index);

%% save input vector for VSPA
[~, ~, ~]=mkdir(cwProj,'test_vectors');
disp('Saving input data for VSPA...')
dram1 = dmemCreate( 0, length(input_reOrd) );
dram1 = dmemWriteReal( dram1, 0, input_reOrd, 'uint' );
dmemSaveHexFile( dram1, strrep([cwProj,'\test_vectors\input_reOrd.hex'],'\',filesep));

%% Matlab bit-exact
[out_ext] = r_bitRev128( input_reOrd );

if isequal(out_ext, input)
    disp('Sanity Check PASS')
else
    disp('Sanity Check FAIL')
end
    

%% save output signal
dram1 = dmemCreate( 0, length(out_ext) );
dram1 = dmemWriteReal( dram1, 0, out_ext, 'uint' );
dmemSaveHexFile( dram1, strrep([cwProj,'\test_vectors\bitRev128_output_be.hex'],'\',filesep));

return;


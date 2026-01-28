% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2016 - 2025 the original authors
%**************************************************************************
% Scope:
% Test bench for bitRev256
%
%**************************************************************************
%
% Revision History:
%  - version 1.0 : 20 Dec 2016
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
dataSC = (1:234).'; % d0:d233
pilots = [111 121 222 232 333 343 444 454 555 565].'; % [P-103 P-75 ... P103]

input = ( 1:256 ).';

input_shift = [input(129:end); input(1:128)];

br_index = bitrevorder(0:255) + 1;
input_reOrd = input_shift(br_index);

%% save input vector for VSPA
[~, ~, ~]=mkdir(cwProj,'test_vectors');
disp('Saving input data for VSPA...')
dram1 = dmemCreate( 0, length(input_reOrd) );
dram1 = dmemWriteReal( dram1, 0, input_reOrd, 'uint' );
dmemSaveHexFile( dram1, strrep([cwProj,'\test_vectors\input_reOrd.hex'],'\',filesep));

%% Matlab bit-exact
[out_ext] = r_bitRev256( input_reOrd );

if isequal(out_ext, input)
    disp('Sanity Check PASS')
else
    disp('Sanity Check FAIL')
end
    

%% save output signal
dram1 = dmemCreate( 0, length(out_ext) );
dram1 = dmemWriteReal( dram1, 0, out_ext, 'uint' );
dmemSaveHexFile( dram1, strrep([cwProj,'\test_vectors\bitRev256_output_be.hex'],'\',filesep));

return;


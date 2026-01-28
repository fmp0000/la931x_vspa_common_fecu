% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2016 - 2025 the original authors
%**************************************************************************
% Scope:
% Test bench for bitRev64
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
dataSC = (1:48).'; % d0:d47 (where d0 = 1+0j)
pilots = [55 66 77 88].'; % [P-21 P-7 P7 P21]

input = [zeros(6,1); dataSC(1:5); pilots(1); dataSC(6:18); pilots(2); dataSC(19:24); ...
         0; dataSC(25:30); pilots(3); dataSC(31:43); pilots(4); dataSC(44:48); zeros(5,1)];

input_shift = [input(33:end); input(1:32)];

br_index = bitrevorder(0:63) + 1;
input_reOrd = input_shift(br_index);

%% save input vector for VSPA
[~, ~, ~]=mkdir(cwProj,'test_vectors');
disp('Saving input data for VSPA...')
dram1 = dmemCreate( 0, length(input_reOrd) );
dram1 = dmemWriteReal( dram1, 0, input_reOrd, 'uint' );
dmemSaveHexFile( dram1, strrep([cwProj,'\test_vectors\input_reOrd.hex'],'\',filesep));

%% Matlab bit-exact
[out_ext] = r_bitRev64( input_reOrd );

if isequal(out_ext, input)
    disp('Sanity Check PASS')
else
    disp('Sanity Check FAIL')
end
    

%% save output signal
dram1 = dmemCreate( 0, length(out_ext) );
dram1 = dmemWriteReal( dram1, 0, out_ext, 'uint' );
dmemSaveHexFile( dram1, strrep([cwProj,'\test_vectors\bitRev64_output_be.hex'],'\',filesep));

return;


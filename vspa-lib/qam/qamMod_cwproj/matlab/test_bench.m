% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2016 - 2025 the original authors
%**************************************************************************
% Scope:
% Test bench for freq domain tap generation function
% It tests different index for fdTapGen
%
%**************************************************************************
%
% Revision History:
%  - version 1.1 : Mar 10 2016
%
%**************************************************************************



%% Test bench init
close all;
clear;

%% Paths to other folders
% addpath c:/GITrepository/dfe-vspa-sw4/common/matlab/
addpath ../../../common/matlab/vspa    %path to common functions
addpath ../../../common/matlab/utils   %path to common utils
addpath('./../../matlab')              %path the function to be tested


%% Reset Random Seed
rng('default');

%% generate sigal
NoBits=32*32;
NoBits_64qam=32*32*3*2;
NoBits_1024qam=32*32*10;

input_bits=randi([0 1],NoBits,1);
input=reshape(input_bits,32,[])'*(2.^[0:31])';

input_bits_64qam=randi([0 1],NoBits_64qam,1);
input_64qam=reshape(input_bits_64qam,32,[])'*(2.^[0:31])';

input_bits_1024qam=randi([0 1],NoBits_1024qam,1);
input_1024qam=reshape(input_bits_1024qam,32,[])'*(2.^[0:31])';

%% Parameters 
target = 'CAS'; % CAS
setenv('target',target);

%% path to reference design
cwProj = strrep([pwd '\..'],'\',filesep); %CW project is 1 level up
setenv('CWPROJ',[pwd '\..'])
getenv('CWPROJ')

%% save input vector for VSPA
[~, ~, ~]=mkdir(cwProj,'test_vectors');


dram.base=0;
dram.data=zeros(NoBits/32,1);
dram = dmemWriteReal(dram, 0,input, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(NoBits_64qam/32,1);
dram = dmemWriteReal(dram, 0,input_64qam, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_64qam.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(NoBits_1024qam/32,1);
dram = dmemWriteReal(dram, 0,input_1024qam, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_1024qam.hex'],'\',filesep));


%% generate Matlab references
y_bx= r_qamMod(input_bits,1,1);
dram.base=0;
dram.data=zeros(NoBits/1,1);
dram = dmemWriteComplex(dram, 0,y_bx, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_bpsk_expected.hex'],'\',filesep));

y_bx= r_qamMod(input_bits,2,1/sqrt(2));
dram.base=0;
dram.data=zeros(NoBits/2,1);
dram = dmemWriteComplex(dram, 0,y_bx, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_qpsk_expected.hex'],'\',filesep));

y_bx= r_qamMod(input_bits,4,1/sqrt(10));
dram.base=0;
dram.data=zeros(NoBits/4,1);
dram = dmemWriteComplex(dram, 0,y_bx, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_16_expected.hex'],'\',filesep));


y_bx= r_qamMod(input_bits,8,1/sqrt(170));
dram.base=0;
dram.data=zeros(NoBits/8,1);
dram = dmemWriteComplex(dram, 0,y_bx, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_256_expected.hex'],'\',filesep));


y_bx= r_qamMod(input_bits_64qam,6,1/sqrt(42));
dram.base=0;
dram.data=zeros(32*32,1);
dram = dmemWriteComplex(dram, 0,y_bx, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_64_expected.hex'],'\',filesep));

y_bx= r_qamMod(input_bits_1024qam,10,1/sqrt(682));
dram.base=0;
dram.data=zeros(32*32,1);
dram = dmemWriteComplex(dram, 0,y_bx, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_1024_expected.hex'],'\',filesep));
%% -- Retrieve environment variables



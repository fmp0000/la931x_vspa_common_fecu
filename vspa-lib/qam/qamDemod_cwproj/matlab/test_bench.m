% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2016 - 2025 the original authors
%**************************************************************************
% Scope:
% Test bench for qam demod functions
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
% addpath ../../../../../vspalibrary/core_library %path to VSPA core library
addpath('./../../matlab')              %path the function to be tested


%% Reset Random Seed
rng('default');

%% generate sigal

snr=12.37;

snr_vec=rand(1,256)*16;
noise_var=1/snr;
input_bits=randi([0 1],1280*2,1);

sym_BPSK=r_qamMod(input_bits(1:512),1,1);
noise=sqrt(noise_var/2)*randn(size(sym_BPSK))+1i*sqrt(noise_var/2)*randn(size(sym_BPSK));
sym_BPSK=sym_BPSK+noise;

sym_QPSK=r_qamMod(input_bits(1:512),2,1/sqrt(2));
noise=sqrt(noise_var/2)*randn(size(sym_QPSK))+1i*sqrt(noise_var/2)*randn(size(sym_QPSK));
sym_QPSK=sym_QPSK+noise;

sym_16=r_qamMod(input_bits(1:512),4,1/sqrt(10));
noise=sqrt(noise_var/2)*randn(size(sym_16))+1i*sqrt(noise_var/2)*randn(size(sym_16));
sym_16=sym_16+noise;

sym_64=r_qamMod(input_bits(1:768),6,1/sqrt(42));
noise=sqrt(noise_var/2)*randn(size(sym_64))+1i*sqrt(noise_var/2)*randn(size(sym_64));
sym_64=sym_64+noise;

% sym_256=r_qamMod(input_bits(1:1024),8,1/sqrt(170));
sym_256=r_qamMod(input_bits(1:2048),8,1/sqrt(170));
noise=sqrt(noise_var/2)*randn(size(sym_256))+1i*sqrt(noise_var/2)*randn(size(sym_256));
sym_256=sym_256+noise;

sym_1024=r_qamMod(input_bits(1:1280),10,1/sqrt(682));
noise=sqrt(noise_var/2)*randn(size(sym_1024))+1i*sqrt(noise_var/2)*randn(size(sym_1024));
sym_1024=sym_1024+noise;
%% Parameters 
target = 'CAS'; % CAS
setenv('target',target);

%% path to reference design
cwProj = strrep([pwd '\..'],'\',filesep); %CW project is 1 level up
setenv('CWPROJ',[pwd '\..'])
getenv('CWPROJ');

%% save input vector for VSPA
path_test_vectors = '../test_vectors/';
[~,~,~]=mkdir(strrep([path_test_vectors],'/',filesep)); % test vector folder

%mkdir(cwProj, 'test_vectors');

OFFSET1=512;
OFFSET2=512;

dram.base=0;
dram.data=zeros(length(sym_BPSK)+OFFSET1,1);
dram = dmemWriteComplex(dram, 0,sym_BPSK, 'half' );
dram = dmemWriteComplex(dram, OFFSET1,sym_BPSK, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_bpsk.hex'],'\',filesep));

dram.data=zeros(length(sym_QPSK)+OFFSET1,1);
dram = dmemWriteComplex(dram, 0,sym_QPSK, 'half' );
dram = dmemWriteComplex(dram, OFFSET1,sym_QPSK, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_qpsk.hex'],'\',filesep));

dram.data=zeros(length(sym_16)+OFFSET1,1);
dram = dmemWriteComplex(dram, 0,sym_16, 'half' );
dram = dmemWriteComplex(dram, OFFSET1,sym_16, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_16.hex'],'\',filesep));

dram.data=zeros(length(sym_64)+OFFSET1,1);
dram = dmemWriteComplex(dram, 0,sym_64, 'half' );
dram = dmemWriteComplex(dram, OFFSET1,sym_64, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_64.hex'],'\',filesep));

dram.data=zeros(length(sym_256)+OFFSET1,1);
dram = dmemWriteComplex(dram, 0,sym_256, 'half' );
dram = dmemWriteComplex(dram, OFFSET1,sym_256, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_256.hex'],'\',filesep));

dram.data=zeros(length(sym_256),1);
dram = dmemWriteComplex(dram, 0,sym_256, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_256V2.hex'],'\',filesep));

dram.data=zeros(length(sym_1024)+OFFSET1,1);
dram = dmemWriteComplex(dram, 0,sym_1024, 'half' );
dram = dmemWriteComplex(dram, OFFSET1,sym_1024, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\input_1024.hex'],'\',filesep));


dram.data=zeros(length(snr_vec)/2,1);
dram = dmemWriteReal(dram, 0,snr_vec, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\snr.hex'],'\',filesep));



%% generate Matlab references for single channel processing
y_bx= r_qamDemod(sym_BPSK,1,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_bpsk_expected.hex'],'\',filesep));

y_bx= r_qamDemod(sym_QPSK,2,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_qpsk_expected.hex'],'\',filesep));

y_bx= r_qamDemodNr(sym_QPSK,2,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_qpsk_Nr_expected.hex'],'\',filesep));

y_bx= r_qamDemod(sym_16,4,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_16_expected.hex'],'\',filesep));

y_bx= r_qamDemod(sym_64,6,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_64_expected.hex'],'\',filesep));

y_bx= r_qamDemod(sym_256,8,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_256_expected.hex'],'\',filesep));

y_bx= r_qamDemodV2(sym_256,8,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_256_expectedV2.hex'],'\',filesep));

y_bx= r_qamDemodNr(sym_256,8,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_256_Nr_expected.hex'],'\',filesep));

y_bx= r_qamDemod(sym_1024,10,snr);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_1024_expected.hex'],'\',filesep));

y_bx= r_qamDemodV3(sym_256,8,snr_vec,1);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_256_V3_expected.hex'],'\',filesep));

y_bx= r_qamDemodV3(sym_64,6,snr_vec(1:128),1);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_64_V3_expected.hex'],'\',filesep));

y_bx= r_qamDemodV3(sym_16,4,snr_vec(1:128),1);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_16_V3_expected.hex'],'\',filesep));

y_bx= r_qamDemodV3(sym_QPSK,2,snr_vec,1);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_Qpsk_V3_expected.hex'],'\',filesep));

y_bx= r_qamDemodV4(sym_QPSK,2,snr_vec);
dram.base=0;
dram.data=zeros(length(y_bx)/2,1);
dram = dmemWriteReal(dram, 0, y_bx, 'half_fixed');
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_Qpsk_V4_expected.hex'],'\',filesep));

y_bx= r_qamDemodV3(sym_BPSK(1:256),1,snr_vec,1);
dram.base=0;
dram.data=zeros(length(y_bx)/4,1);
dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_Bpsk_V3_expected.hex'],'\',filesep));

% load ..\test_vectors\qamdemodtestvec16QAM.mat
% dram.data=zeros(1024,1);
% dram = dmemWriteComplex(dram, 0,qamIn(1024*9+(1:1024)), 'half' );
% dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\qamIn.hex'],'\',filesep));
% 
% dram.data=zeros(512,1);
% dram = dmemWriteReal(dram, 0,snr(1024*9+(1:1024)), 'half' );
% dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\snrIn.hex'],'\',filesep));
% 
% y_bx= r_qamDemodV3(qamIn,4,snr,0);
% dram.base=0;
% dram.data=zeros(length(y_bx)/4,1);
% dram = dmemWriteReal(dram, 0,y_bx(1:4:end)+y_bx(2:4:end)*2^8+y_bx(3:4:end)*2^16+y_bx(4:4:end)*2^24, 'uint' );
% dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\output_expected.hex'],'\',filesep));

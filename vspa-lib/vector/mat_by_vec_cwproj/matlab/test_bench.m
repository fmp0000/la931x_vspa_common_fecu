% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%**************************************************************************
%
% Revision History:
%
%**************************************************************************
%% Test bench init
close all;
clear;
clc;

%% Paths to other folders
% addpath c:/GITrepository/dfe-vspa-sw4/common/matlab/
addpath ../../../common/matlab/vspa    %path to common functions
% addpath ../../../common/matlab/utils   %path to common utils
% addpath ../../../../../vspalibrary/core_library %path to VSPA core library
addpath('./../../matlab')              %path the function to be tested


%% Reset Random Seed
% rng('default');

%% generate signal
L = 5;          % Number of DMEM lines used to store x1, x2, or xM
M = 111;         % size of a vector or number of xi vectors
offset = 192;   % The offset between x(i) and x(i+1)
X = (1/M) * (rand(L*32 , M) + 1j * rand(L*32 , M));
a_complex = rand(M,1) + 1j * rand(M,1);
a_real = real(a_complex);

%% processing
if mod(offset, 32) ~= 0
    error('offset should be multiple of 32')
end
if size(X,1) > offset
    error('offset has to be greater than or equal to the size of the input vectors x1, x2, ....')
elseif size(X,1) < offset
    X = [X ; zeros(offset-size(X,1) , size(X,2))];
end
x = reshape(X,[],1);
y_hfx1 = r_mat_by_vec_chfx_chfx_chfx(x , a_complex , offset , L , M);
y_hfx2 = r_mat_by_vec_chfx_chfx_chfl(x , a_complex , offset , L , M);
y_hfx3 = r_mat_by_vec_chfx_chfx_rhfx(x , a_real , offset , L , M);
y_hfx4 = r_mat_by_vec_chfx_chfx_rhfl(x , a_real , offset , L , M);
y_hfx5 = r_mat_by_vec_chfx_chfx_rfl(x , a_real , offset , L , M);
y_hfl1 = r_mat_by_vec_chfl_chfx_chfx(x , a_complex , offset , L , M);
y_hfl2 = r_mat_by_vec_chfl_chfx_chfl(x , a_complex , offset , L , M);
y_hfl3 = r_mat_by_vec_chfl_chfx_rhfx(x , a_real , offset , L , M);
y_hfl4 = r_mat_by_vec_chfl_chfx_rhfl(x , a_real , offset , L , M);
y_hfl5 = r_mat_by_vec_chfl_chfx_rfl(x , a_real , offset , L , M);
y_double_complex_coeff = reshape(X(1:32*L,:) * a_complex , [] , 1);
y_double_real_coeff = reshape(X(1:32*L,:) * a_real , [] , 1);

error1_r_mat_by_vec_chfx_chfx_chfx = sum(abs(y_hfx1-y_double_complex_coeff))
error2_r_mat_by_vec_chfx_chfx_chfl = sum(abs(y_hfx2-y_double_complex_coeff))
error3_r_mat_by_vec_chfx_chfx_rhfx = sum(abs(y_hfx3-y_double_real_coeff))
error4_r_mat_by_vec_chfx_chfx_rhfl = sum(abs(y_hfx4-y_double_real_coeff))
error5_r_mat_by_vec_chfx_chfx_rfl  = sum(abs(y_hfx5-y_double_real_coeff))
error6_r_mat_by_vec_chfl_chfx_chfx = sum(abs(y_hfl1-y_double_complex_coeff))
error7_r_mat_by_vec_chfl_chfx_chfl = sum(abs(y_hfl2-y_double_complex_coeff))
error8_r_mat_by_vec_chfl_chfx_rhfx = sum(abs(y_hfl3-y_double_real_coeff))
error9_r_mat_by_vec_chfl_chfx_rhfl = sum(abs(y_hfl4-y_double_real_coeff))
error10_r_mat_by_vec_chfl_chfx_rfl = sum(abs(y_hfl5-y_double_real_coeff))
%% save input vector for VSPA
cwProj = strrep([pwd '\..'],'\',filesep); %CW project is 1 level up
mkdir(cwProj, 'test_vectors');
if mod(M,2) == 1
    a_real_h=[a_real ; 0];
else
    a_real_h=a_real;
end

dram.base=0;
dram.data=zeros(offset*M,1);
dram = dmemWriteComplex(dram, 0, x, 'half_fixed' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\x.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(M,1);
dram = dmemWriteComplex(dram, 0, a_complex, 'half_fixed' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\a_chfx.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(M,1);
dram = dmemWriteComplex(dram, 0, a_complex, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\a_chfl.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(M,1);
dram = dmemWriteReal(dram, 0, a_real, 'single' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\a_rfl.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(ceil(M/2),1);
dram = dmemWriteReal(dram, 0, a_real_h, 'half_fixed' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\a_rhfx.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(ceil(M/2),1);
dram = dmemWriteReal(dram, 0, a_real_h, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\a_rhfl.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(1,1);
dram = dmemWriteReal(dram, 0, offset, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\offset.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(1,1);
dram = dmemWriteReal(dram, 0, L, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\L.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(1,1);
dram = dmemWriteReal(dram, 0, M, 'uint' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\M.hex'],'\',filesep));
%% save output vectors

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfx1, 'half_fixed' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y1_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfx2, 'half_fixed' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y2_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfx3, 'half_fixed' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y3_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfx4, 'half_fixed' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y4_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfx5, 'half_fixed' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y5_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfl1, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y6_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfl2, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y7_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfl3, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y8_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfl4, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y9_matlab.hex'],'\',filesep));

dram.base=0;
dram.data=zeros(L*32,1);
dram = dmemWriteComplex(dram, 0, y_hfl5, 'half' );
dmemSaveHexFile(dram, strrep([cwProj,'\test_vectors\y10_matlab.hex'],'\',filesep));


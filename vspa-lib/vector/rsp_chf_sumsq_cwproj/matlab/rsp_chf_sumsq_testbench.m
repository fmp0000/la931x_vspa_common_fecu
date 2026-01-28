% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
addpath('../../../common/matlab/utils');
addpath('../../../common/matlab/vspa');
addpath('../../matlab');

%% random seed, test_vector path
clear all; close all;
rng('default'); rng(60);
path_test_vectors = '../test_vectors/';
[~,~,~]=mkdir(strrep([path_test_vectors],'/',filesep)); % test vector folder

%% set up
L   = 32;               % number of DMEM lines of all input samples
l_B = [64 32];          % number of samples per batch
offset_x = 1;           % offset of x, measured in the number of entries
num_cHF_per_line = 32;  % number of complex 16-bit half-fixed per DMEM line in 16AU

%% bit-exactness check
N   = L * num_cHF_per_line;
x   = r_half(   complex(2*rand(N,1)-1,  2*rand(N,1)-1)  );    
dram= dmemCreate(0,N);     dram = dmemWriteComplex( dram, 0, x, 'half_fixed' );   dmemSaveHexFile( dram, strrep( [path_test_vectors 'x_in.hex']  ,'/',filesep) );    
for iB=1:length(l_B)
    B = l_B(iB);
    str_case = num2str(B,'B%d_');
        
    for k=1:N/B
        idx = (k-1)*B + (1:B);
        [y_vsp(k,iB), y_mat(k,iB), dbg] = r_rsp_chf_sumsq(x(idx), offset_x);
    end
    % sanity check
    if 1        
        disp(num2str(max(abs( y_mat(:,iB) - y_vsp(:,iB) )), 'max(abs( y_mat-y_vsp )): %3.2e'));
    end    
    
    %% save test vectors in hex
    disp('  Saving outputs ...');
    disp(str_case);
    
    dram = dmemCreate(0, N/B);     dram = dmemWriteReal( dram, 0, y_vsp(:,iB), 'single' );      dmemSaveHexFile( dram, strrep( [path_test_vectors str_case 'y_BE.hex']  ,'/',filesep) );
end

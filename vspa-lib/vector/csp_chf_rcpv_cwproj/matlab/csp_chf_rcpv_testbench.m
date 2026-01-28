% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%% random seed, test_vector path
clear all;
close all;
clc;

% Add paths
addpath('../../../common/matlab/utils');
addpath('../../../common/matlab/vspa');
addpath('../../matlab');

rng('default'); rng(60);
path_test_vectors = '../test_vectors/';
[~,~,~]=mkdir(strrep([path_test_vectors],'/',filesep)); % test vector folder

%% set up
l_L = [1 2 3 4 8 15 31];    % number of DMEM lines occupied by x.

num_cHF_per_line = 32;  % number of complex 16-bit half-fixed per DMEM line in 16AU

%% bit-exactness check
for iL=1:length(l_L)
    L   = l_L(iL);
    N   = L * num_cHF_per_line;
    if 1
        x   = r_half( complex(2*rand(N,1)-1, 2*rand(N,1)-1) ); % test bench
    else
        x   = r_half( complex((1:N).'/32768, (1:N).'/32768) ); % debug
    end
    str_case = num2str(L,'L%d_');
    
    [y_vsp, y_mat, dbg] = r_csp_chf_rcpv(x);
    
    % sanity check
    if 1
        figure;        
        subplot(121); err=(y_mat - y_vsp);  loglog(abs(real(err)),abs(imag(err)),'.'); title(num2str(N,'N=%d: y_{mat}-y_{vsp}'));  xlabel('abs(real)'); ylabel('abs(imag)')
        subplot(122); err=(x.*y_vsp -1);    loglog(abs(real(err)),abs(imag(err)),'.'); title(num2str(N,'N=%d: y_{vsp} .* x - 1')); xlabel('abs(real)'); ylabel('abs(imag)')
    end
    
    %% save test vectors in hex
    disp('  Saving outputs ...');
    disp(str_case);
    
    dram = dmemCreate(0,N);     dram = dmemWriteComplex( dram, 0, x, 'half_fixed' );    dmemSaveHexFile( dram, strrep( [path_test_vectors str_case 'x_in.hex']  ,'/',filesep) );
    dram = dmemCreate(0,N*2);   dram = dmemWriteComplex( dram, 0, y_vsp, 'single' );    dmemSaveHexFile( dram, strrep( [path_test_vectors str_case 'y_BE.hex']  ,'/',filesep) );
end
nCase = length(l_L);

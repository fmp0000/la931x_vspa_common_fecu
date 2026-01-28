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
L = 5;                  % number of DMEM lines occupied by x.
num_word_per_line = 32; % number of words per DMEM line in 16AU

%% bit-exactness check
N_word  = L * num_word_per_line;
N_chalf = N_word;
N_rhalf = N_word * 2;
N_csp   = N_word / 2;
N_rsp   = N_word;

x_rhf = r_half(     (2*rand(N_rhalf,1)-1 )/4);   alpha_rhf = r_half(     (2*rand(2,1)-1)/4 );
x_rhp = r_half_flt(  2*rand(N_rhalf,1)-1 );      alpha_rhp = r_half_flt(  2*rand(2,1)-1 );
x_rsp = r_single(    2*rand(N_rsp,  1)-1 );      alpha_rsp = r_single(    2*rand(2,1)-1 );

x_chf = r_half(    (complex(2*rand(N_chalf,1)-1, 2*rand(N_chalf,1)-1))/4 ); alpha_chf = r_half(    (complex(2*rand(2,1)-1, 2*rand(2,1)-1))/4 );
x_chp = r_half_flt( complex(2*rand(N_chalf,1)-1, 2*rand(N_chalf,1)-1) );    alpha_chp = r_half_flt( complex(2*rand(2,1)-1, 2*rand(2,1)-1) );
x_csp = r_single(   complex(2*rand(N_csp,  1)-1, 2*rand(N_csp,  1)-1) );    alpha_csp = r_single(   complex(2*rand(2,1)-1, 2*rand(2,1)-1) );

%% y = x + alpha
% out_prec = 0: single, 1: half, 2: half-fixed
% real
out_prec = 2;  [y_rhf.vsp, y_rhf.mat, dbg] = r_vAddSclr(x_rhf, alpha_rhf(2), out_prec);
out_prec = 1;  [y_rhp.vsp, y_rhp.mat, dbg] = r_vAddSclr(x_rhp, alpha_rhp(2), out_prec);
out_prec = 0;  [y_rsp.vsp, y_rsp.mat, dbg] = r_vAddSclr(x_rsp, alpha_rsp(2), out_prec);
% complex
out_prec = 2;  [y_chf.vsp, y_chf.mat, dbg] = r_vAddSclr(x_chf, alpha_chf(2), out_prec);
out_prec = 1;  [y_chp.vsp, y_chp.mat, dbg] = r_vAddSclr(x_chp, alpha_chp(2), out_prec);
out_prec = 0;  [y_csp.vsp, y_csp.mat, dbg] = r_vAddSclr(x_csp, alpha_csp(2), out_prec);

% sanity check
if 1
    y = y_rhf; disp('rhf: ');
    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
    mm = max(max(max(abs(y.mat./y.vsp - 1))));      disp(num2str(mm, '  max[ y_mat./y_vsp - 1 ]: %3.2e'));
    y = y_rhp; disp('rhp: ');
    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
    mm = max(max(max(abs(y.mat./y.vsp - 1))));      disp(num2str(mm, '  max[ y_mat./y_vsp - 1 ]: %3.2e'));
    y = y_rsp; disp('rsp: ');
    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
    mm = max(max(max(abs(y.mat./y.vsp - 1))));      disp(num2str(mm, '  max[ y_mat./y_vsp - 1 ]: %3.2e'));
    
    y = y_chf; disp('chf: ');
    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
    mm = max(max(max(abs(y.mat./y.vsp - 1))));      disp(num2str(mm, '  max[ y_mat./y_vsp - 1 ]: %3.2e'));
    y = y_chp; disp('chp: ');
    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
    mm = max(max(max(abs(y.mat./y.vsp - 1))));      disp(num2str(mm, '  max[ y_mat./y_vsp - 1 ]: %3.2e'));
    y = y_csp; disp('csp: ');
    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
    mm = max(max(max(abs(y.mat./y.vsp - 1))));      disp(num2str(mm, '  max[ y_mat./y_vsp - 1 ]: %3.2e'));
end

%% save test vectors in hex
disp('  Saving outputs ...');
str_op = 'add_';
str_case_in = num2str(L,'L%d_rhf_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, x_rhf, 'half_fixed' );    dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'x_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,1);        dram = dmemWriteReal( dram, 0, alpha_rhf, 'half_fixed' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'alpha_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, y_rhf.vsp, 'half_fixed' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'y_BE.hex']  ,'/',filesep) );

str_case_in = num2str(L,'L%d_rhp_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, x_rhp, 'half' );    dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'x_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,1);        dram = dmemWriteReal( dram, 0, alpha_rhp, 'half' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'alpha_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, y_rhp.vsp, 'half' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'y_BE.hex']  ,'/',filesep) );

str_case_in = num2str(L,'L%d_rsp_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, x_rsp, 'single' );    dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'x_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,2);        dram = dmemWriteReal( dram, 0, alpha_rsp, 'single' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'alpha_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, y_rsp.vsp, 'single' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'y_BE.hex']  ,'/',filesep) );

str_case_in = num2str(L,'L%d_chf_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteComplex( dram, 0, x_chf, 'half_fixed' );    dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'x_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,2);        dram = dmemWriteComplex( dram, 0, alpha_chf, 'half_fixed' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'alpha_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,N_word);   dram = dmemWriteComplex( dram, 0, y_chf.vsp, 'half_fixed' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'y_BE.hex']  ,'/',filesep) );

str_case_in = num2str(L,'L%d_chp_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteComplex( dram, 0, x_chp, 'half' );    dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'x_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,2);        dram = dmemWriteComplex( dram, 0, alpha_chp, 'half' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'alpha_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,N_word);   dram = dmemWriteComplex( dram, 0, y_chp.vsp, 'half' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'y_BE.hex']  ,'/',filesep) );

str_case_in = num2str(L,'L%d_csp_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteComplex( dram, 0, x_csp, 'single' );      dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'x_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,4);        dram = dmemWriteComplex( dram, 0, alpha_csp, 'single' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_case_in 'alpha_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,N_word);   dram = dmemWriteComplex( dram, 0, y_csp.vsp, 'single' );  dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'y_BE.hex']  ,'/',filesep) );

%% y = x * alpha
% SP_HPswitch = 0: single, 1: half, 2: half-fixed
% real
out_prec = 2;  [y_rhf.vsp, y_rhf.mat, dbg] = r_vMultiSclr(x_rhf, alpha_rsp(2), out_prec);
out_prec = 1;  [y_rhp.vsp, y_rhp.mat, dbg] = r_vMultiSclr(x_rhp, alpha_rsp(2), out_prec);
out_prec = 0;  [y_rsp.vsp, y_rsp.mat, dbg] = r_vMultiSclr(x_rsp, alpha_rsp(2), out_prec);

% sanity check
if 1
    y = y_rhf; disp('rhf: ');    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
    y = y_rhp; disp('rhp: ');    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
    y = y_rsp; disp('rsp: ');    mm = max(max(max(abs(y.mat - y.vsp))));         disp(num2str(mm, '  max[ y_mat - y_vsp ]:    %3.2e'));
end

%% save test vectors in hex
disp('  Saving outputs ...');
str_op = 'multi_';
str_case_in = num2str(L,'L%d_rhf_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, y_rhf.vsp, 'half_fixed' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'rhf_rsp_' 'y_BE.hex']  ,'/',filesep) );

str_case_in = num2str(L,'L%d_rhp_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, y_rhp.vsp, 'half' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'rhp_rsp_' 'y_BE.hex']  ,'/',filesep) );

str_case_in = num2str(L,'L%d_rsp_');   disp(str_case_in);
dram = dmemCreate(0,N_word);   dram = dmemWriteReal( dram, 0, y_rsp.vsp, 'single' );dmemSaveHexFile( dram, strrep( [path_test_vectors str_op str_case_in 'rsp_rsp_' 'y_BE.hex']  ,'/',filesep) );


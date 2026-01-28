% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function vectorXscalar_testbench(N, n_batches, n_iqsstaps, testname)
% custom  front end processing chain for WiFi
% DESCRIPTION:
%   Generates test vectors for signal conditioning processing chain
% 
% INPUTS:
%   N: Number of input samples per batch
%   n_batches: Number of batches
%   testname: Name of test
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vectorXscalar_testbench(N, testname)

%% config
offset = 31;

%% generate inputs
x_mat = complex(2*rand(N, 1)-1, 2*rand(N, 1)-1);
x_vsp = r_half_flt(x_mat);

a_mat = complex(2*rand(1, 1)-1, 2*rand(1, 1)-1);
a_vsp = r_single(a_mat);

%% generate bit-exact results
y_mat = x_mat*a_mat;
y_vsp = r_half_flt(r_smad(x_vsp, a_vsp, 0));
sqnr = 10*log10(mean(abs(y_mat).^2)/mean(abs(y_mat-y_vsp).^2));
fprintf('Vector times Scalar: SQNR = %.2f dB\n', sqnr);

% write input data
drCW = dmemCreate(0, N+32);
drCW = dmemWriteComplex(drCW, offset, x_vsp, 'half');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_x.hex', testname));
clear drCW;

drCW = dmemCreate(0, 2);
drCW = dmemWriteComplex(drCW, 0, a_vsp, 'single');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_a.hex', testname));
clear drCW;

% Write tester config structure
drCW = dmemCreate(0, 2);
drCW = dmemWriteReal(drCW, 0, [N; offset], 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_config.hex', testname));
clear drCW;

drCW = dmemCreate(0, N);
drCW = dmemWriteComplex(drCW, 0, y_vsp, 'half');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_output_y_ref.hex', testname));
clear drCW;

return;





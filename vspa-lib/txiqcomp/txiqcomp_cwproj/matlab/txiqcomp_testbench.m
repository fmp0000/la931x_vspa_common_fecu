% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function txiqcomp_testbench(N, n_batches, n_iqsstaps, testname)
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
function txiqcomp_testbench(N, n_batches, testname)

%% config
ci = 0.98;
cq = 0.9;
ci2q = 0.1;
di = rand - 0.5;
dq = rand - 0.5;
fn_type = 1;

%% generate inputs
% generate input waveform
dcoff = complex(di, dq);
n_samples_in1 = N*n_batches;

% x = exp(-sqrt(-1)*2*pi*(0:n_samples_in1-1)'*0.2/Fs);
x = complex(rand(n_samples_in1, 1), rand(n_samples_in1, 1));
x = x/rms(x)*10^(-12/20) + dcoff;
x_vsp = r_half(x);

%% generate bit-exact results
Nout = N;

% generate normalized frequency and round to 2^32 representation
y_out_i = r_smac(real(x_vsp).', repmat(r_single(ci), 1, n_samples_in1), repmat(r_single(-di), 1, n_samples_in1));
y_out_q = r_smac([real(x_vsp).'; imag(x_vsp).'], repmat([r_single(ci2q); r_single(cq)], 1, n_samples_in1), repmat(r_single(-dq), 1, n_samples_in1));
y_out = reshape(r_half(complex(y_out_i, y_out_q)), [], 1);
y_out_dbl = complex(-di + real(x_vsp)*ci, -dq + real(x_vsp)*ci2q  + imag(x_vsp)*cq);
sqnr = 10*log10(mean(abs(y_out_dbl).^2)/mean(abs(y_out_dbl - y_out).^2));
fprintf('SQNR for TX IQ Compensation = %.2f dB\n', sqnr);

%% generate CW test vectors
for jj = 1:n_batches
    drCW = dmemCreate(0, N);
    drCW = dmemWriteComplex(drCW, 0, x_vsp((jj-1)*N + (1:N)), 'half_fixed');
    dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_x_batch%d.hex', testname, jj));
    clear drCW;
end

for jj = 1:n_batches
    drCW = dmemCreate(0, Nout);
    drCW = dmemWriteComplex(drCW, 0, y_out((jj-1)*Nout + (1:Nout)), 'half_fixed');
    dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_output_y_batch%d_ref.hex', testname, jj));
    clear drCW;
end

% Write tester config structure
drCW = dmemCreate(0, 3);
drCW = dmemWriteReal(drCW, 0, [N; n_batches; fn_type], 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_config.hex', testname));
clear drCW;

% set input structure
drCW = dmemCreate(0, 6);
iqtaps_vector = r_single([-di -dq 0 ci2q ci cq]);
drCW = dmemWriteReal(drCW, 0, iqtaps_vector, 'single');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_txiqcompstruct.hex', testname));
clear drCW;

return;





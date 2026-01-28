% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function txiqcomp_testbench(N, n_batches, testname)
% custom  front end processing chain for WiFi
% DESCRIPTION:
%   Generates test vectors for TX IQ compensation.
% 
% INPUTS:
%   N: Number of input samples per batch
%   n_batches: Number of batches
%   testname: Name of test
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function txiqcomp2_testbench(N, n_batches, testname)

% Generate random real gain
gain = 0.5 + rand;

% Generate random DC offset
di = rand - 0.5;
dq = rand - 0.5;
dcoff = complex(di, dq);

% Config
fn_type = 2;

% IQ imbalance params
n_iqsstaps = 5;									% Number of IQ taps
frac_delay = -0.2;                              % fraction delay of q branch wrt i branch
alpha      = 0.9;								% IQ impairment: alpha
psi        = 0.1;								% IQ impairment: psi

% Generate input
num_samples = N * n_batches;
x = complex(rand(num_samples, 1), rand(num_samples, 1));
x_rms = sqrt(sum(abs(x).^2));
x_mat = x/x_rms*10^(-12/20) + dcoff;
x_vsp = r_half(x_mat);

% Generate I/Q imbalance taps
f1 = 1/alpha;
f2 = -tan(psi)/alpha;
f4 = sec(psi);

if n_iqsstaps == 4
    iqimb_ssdelayfilt = fir1(3, 150/160).';
else
    if frac_delay == 0
        h = [0 0 1 0 0];
    else
        if frac_delay < 0
            frac_n0 = 1 - abs(frac_delay);
        else
            frac_n0 = frac_delay;
        end
        n = (-2+frac_n0:1:2+frac_n0);
        B = 0.5;
        fsT = 2*(1-B);
        %h = sinc(n/fsT).*cos(pi*B*n/fsT)./(1-(2*B*n/fsT).^2);
        h = sinc(n/fsT).*cos(pi*B*n/fsT)./(1-(2*B*n/fsT).^2);
    end
    iqimb_ssdelayfilt = h/sum(h);
end

len_ssfilt = length(iqimb_ssdelayfilt);     
del_ssfilt = floor((len_ssfilt-1)/2);            % delay of SS delay filter

iqimb_f1 = f1;
iqimb_ssdelayfilt = f4*iqimb_ssdelayfilt;
iqimb_f2 = f2;
if frac_delay <= 0
    iqimb_intdelay = del_ssfilt;
else
    iqimb_intdelay = del_ssfilt - 1;
end

% Call IQ compensation
txiqcomp_struct.gain              = gain;
txiqcomp_struct.dcoff             = -dcoff;
txiqcomp_struct.iqimb_ssdelayfilt = iqimb_ssdelayfilt;
txiqcomp_struct.iqimb_f1          = iqimb_f1;
txiqcomp_struct.iqimb_f2          = iqimb_f2;
txiqcomp_struct.iqimb_intdelay    = iqimb_intdelay;

[y_vsp, y_mat] = r_txiqcomp2(x_vsp, x_mat, txiqcomp_struct);

% Print error between models
sqnr = 10*log10(mean(abs(y_mat).^2)/mean(abs(y_mat-y_vsp).^2));
fprintf('SQNR for txiqcomp2 = %.2f dB\n', sqnr);

% Write input batches
for jj = 1:n_batches
    drCW = dmemCreate(0, N);
    drCW = dmemWriteComplex(drCW, 0, x_vsp((jj-1)*N + (1:N)), 'half_fixed');
    dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_x_batch%d.hex', testname, jj));
    clear drCW;
end

% Write output reference
for jj = 1:n_batches
    drCW = dmemCreate(0, N);
    drCW = dmemWriteComplex(drCW, 0, y_vsp((jj-1)*N + (1:N)), 'half_fixed');
    dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_output_y_batch%d_ref.hex', testname, jj));
    clear drCW;
end

% Write tester config structure
drCW = dmemCreate(0, 4);
drCW = dmemWriteReal(drCW, 0, [N; n_batches; fn_type], 'uint');
drCW = dmemWriteReal(drCW, 3, gain, 'single');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_config.hex', testname));
clear drCW;

% Create IQ compensation taps buffer
len_iqtaps = length(iqimb_ssdelayfilt);
itaps_vec = zeros(1, len_iqtaps);
itaps_vec(iqimb_intdelay+1) = iqimb_f1;
iqtaps_vector = [itaps_vec(end:-1:1); reshape(iqimb_ssdelayfilt(end:-1:1), 1, [])];
iqtaps_vector = r_single([0; iqimb_f2; reshape(iqtaps_vector, [], 1)]);

% Write input structure
drCW = dmemCreate(0, 17);
drCW = dmemWriteReal(drCW, 0, iqtaps_vector, 'single');
drCW = dmemWriteReal(drCW, 12, iqimb_intdelay*2+1, 'uint');
drCW = dmemWriteComplex(drCW, 13, -dcoff, 'single');

dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_txiqcompstruct.hex', testname));
clear drCW;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return;

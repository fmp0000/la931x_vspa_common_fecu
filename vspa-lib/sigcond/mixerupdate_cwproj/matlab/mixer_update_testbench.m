% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script mixer_update_testbench
addpath('..\..\..\common\matlab\vspa')
addpath('..\..\matlab\')

clear;

%% config
type = 2;
n_blocks = 2;
B = 128;
Fs = 160;
F = 2;
delta_F = -0.1;

curr_gain = 1;
curr_DCoff = complex(2*rand-1, 2*rand-1);

%% code
N = B*n_blocks;

starting_phase = 2^28;
normfreq = F/Fs;
normfreq = round(normfreq*2^32)/2^32;
normdeltafreq = round(delta_F/Fs*2^32)/2^32;

% MATLAB double precision
init_phase = exp(-sqrt(-1)*2*pi*starting_phase*normfreq);
x_ideal = [init_phase*exp(-sqrt(-1)*2*pi*(0:N-1)'*normfreq); init_phase*exp(-sqrt(-1)*2*pi*N*normfreq)*exp(-sqrt(-1)*2*pi*(0:N-1)'*(normfreq+normdeltafreq))];

% NCO single precision
normphase = starting_phase;
temp1 = reshape(r_nco(normfreq, N+1, normphase), [], 1);

normfreq2 = normfreq + normdeltafreq;
normphase2 = 0;
multphase = r_single(temp1(N+1));
new_gain = r_smad(curr_gain, multphase, 0);
new_DCoff = r_smad(curr_DCoff, multphase, 0);

x_nco = r_single([temp1(1:N); r_smad(reshape(r_nco(normfreq2, N, normphase2), [], 1), multphase, 0)]);

% create random initial states for the filters
xfilt_state = complex(rand(96,1)-0.5, rand(96,1)-0.5);
xfilt_state = r_half(xfilt_state/rms(xfilt_state)*10^(-12/20));
xfilt_state_upd = xfilt_state;
xfilt_state_upd(1:32) = r_half(r_smad(xfilt_state(1:32), multphase, 0));

figure(1);
subplot(2, 1, 1) ; plot(1:2*N, real(x_ideal), 'r+-', 1:2*N, real(x_nco), 'bo-'); 
title('Real');
grid on;
subplot(2, 1, 2) ; plot(1:2*N, imag(x_ideal), 'r+-', 1:2*N, imag(x_nco), 'bo-'); 
title('Imaginary');
grid on;

nco_freq = (normfreq >= 0).*round(normfreq*2^32) + (normfreq < 0).*(2^32 + round(normfreq*2^32));
nco_phase = normphase;
nco_deltafreq = (normdeltafreq >= 0).*round(normdeltafreq*2^32) + (normdeltafreq < 0).*(2^32 + round(normdeltafreq*2^32));

drCW = dmemCreate(0, 2*N*2);
drCW = dmemWriteComplex(drCW, 0, x_nco, 'single');
dmemSaveHexFile(drCW, sprintf('../test_vectors/output_x_ref.hex'));
clear drCW;

drCW = dmemCreate(0, 2);
drCW = dmemWriteReal(drCW, 0, [type; nco_deltafreq], 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/input_config.hex'));
clear drCW;

drCW = dmemCreate(0, 116);
drCW = dmemWriteComplex(drCW, 0, xfilt_state, 'half_fixed');
drCW = dmemWriteReal(drCW, 101, [nco_freq; nco_phase], 'uint');
drCW = dmemWriteComplex(drCW, 97, [curr_gain, curr_DCoff], 'single');
dmemSaveHexFile(drCW, sprintf('../test_vectors/input_mixerstruct.hex'));
clear drCW;

nco_freq_upd = (normfreq2 >= 0).*round(normfreq2*2^32) + (normfreq2 < 0).*(2^32 + round(normfreq2*2^32));

drCW = dmemCreate(0, 116);
if type == 1
    drCW = dmemWriteComplex(drCW, 0, xfilt_state, 'half_fixed');
else
    drCW = dmemWriteComplex(drCW, 0, xfilt_state_upd, 'half_fixed');
end
drCW = dmemWriteReal(drCW, 101, [nco_freq_upd; 0], 'uint');
drCW = dmemWriteComplex(drCW, 97, [new_gain, new_DCoff], 'single');
dmemSaveHexFile(drCW, sprintf('../test_vectors/output_mixerstruct_ref.hex'));
clear drCW;






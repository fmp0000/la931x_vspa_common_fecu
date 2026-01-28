% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
addpath('..\..\..\common\matlab\vspa')
%% test fir filter

clear;

%% config
N = 2048*20;
M = 2048;
L = 33;
prec = 'half_fixed';
mode = 'real';
type = 0;
in_offset = 9;
%

%% generate test vectors
if strcmp(mode, 'real')
    h = fir1(L-1, 0.6);
else
    h = complex(0.5*fir1(L-1, 0.6), 0.5*fir1(L-1, 0.4));
end

x = 1/2*complex(1-2*rand(N, 1), 1-2*rand(N, 1));
%z = complex(0.000030517578125:0.000030517578125:N*0.000030517578125, 0.000030517578125:0.000030517578125:N*0.000030517578125);
%x=z.'

[y_vsp, y_mat, dbg_s] = r_firFilter(h, x, prec);

figure(1);
[PxxV, FxxV] = pwelch(y_vsp, blackman(2048), round(0.4*2048), 2048, 122.88e6, 'centered', 'power');
[PxxM, FxxM] = pwelch(y_vsp, blackman(2048), round(0.4*2048), 2048, 122.88e6, 'centered', 'power');
plot(FxxV*1e-6, 10*log10(PxxV), 'r', FxxM*1e-6, 10*log10(PxxM), 'b'); 
title('VSP and MAT Output Spectrum'); xlabel('MHz'); ylabel('Power (dB)');
legend('VSP', 'MAT');
grid on;
axis([-100/2 100/2 -120 0]);

figure(2);
plot(1:N-L+1, real(y_mat), 'b*-', 1:N-L+1, real(y_vsp), 'ro-');
grid on;

qns = 10*log10( mean(abs(y_vsp-y_mat).^2)/mean(abs(y_mat).^2));
fprintf('QNS for FIR filter output = %.2f dB\n', qns);

% create test_vectors
drInVec = dmemCreate(0, 128);
if strcmp(mode, 'real')
    if mod(L, 2) == 0
        drInVec = dmemWriteReal(drInVec, 0, dbg_s.h, prec);
    else
        drInVec = dmemWriteReal(drInVec, 0, [dbg_s.h 0], prec);
    end
else
    drInVec = dmemWriteComplex(drInVec, 0, dbg_s.h, prec);
end
filename = sprintf('../test_vectors/firFilter_input_h.hex');
dmemSaveHexFile(drInVec, filename);
clear drInVec;

drInVec = dmemCreate(0, 4);
drInVec = dmemWriteReal(drInVec, 0, [M L type in_offset], 'uint');
filename = sprintf('../test_vectors/firFilter_input_config.hex');
dmemSaveHexFile(drInVec, filename);
clear drInVec;

drInVec = dmemCreate(0, 64+M);
drInVec = dmemWriteComplex(drInVec, in_offset, dbg_s.x(1:M+L-1), prec);
filename = sprintf('../test_vectors/firFilter_input_x.hex');
dmemSaveHexFile(drInVec, filename);
clear drInVec;

drOutVec = dmemCreate(0, M);
drOutVec = dmemWriteComplex(drOutVec, 0, y_vsp(1:M), prec);
filename = sprintf('../test_vectors/firFilter_output_y_ref.hex');
dmemSaveHexFile(drOutVec, filename);
clear drOutVec;

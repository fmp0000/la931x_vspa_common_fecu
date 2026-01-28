% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script ditfft_testbench
function ditfft_testbench(N, inv, prec_type, input_offset, test_name)

%% config
% 0=>HFL in, HFX out
% 1=>HFL in, SFL out (for FFT), HFL in, SFL intermediate, , HFX out (for IFFT)
% 2=>SFL in, SFL out
% 

%% generate test input and output vectors
br_index = bitrevorder(0:N-1)' + 1;
x_dbl = complex(2*rand(N, 1)-1, 2*rand(N, 1)-1);

switch prec_type
    case 0
        x_vsp = r_half_flt(x_dbl);
        inputprec = 'half';
        fftprec = 'half_fixed';
        outprec = 'half_fixed';
        scaleout = 1;
        output_size_words = N;
        input_size_words = N;
        
    case 1
        x_vsp = r_half_flt(x_dbl);
        inputprec = 'half';
        fftprec = 'single';
        scaleout = 1;
        if inv
            outprec = 'half_fixed';
            output_size_words = N;
        else
            outprec = 'single';
            output_size_words = 2*N;
        end
        input_size_words = N;

    case 2
        x_vsp = r_single(x_dbl);
        inputprec = 'single';
        fftprec = 'single';
        outprec = 'single';
        scaleout = 0;
        output_size_words = 2*N;
        input_size_words = 2*N;

    otherwise
        error('Unknown precision type');
end

[fftout_vsp, ~, opstruct] = r_dit_fft(x_vsp, inv, fftprec, scaleout);
fprintf('FFT QNS = %.2f dB\n', opstruct.qns);

if (prec_type == 1) && (inv == 1)
    fftout_vsp = r_half(r_smad(r_single(1/N), fftout_vsp, 0));
end

%% create cw data files
fft_config = [N; inv; prec_type; input_offset];
drCW = dmemCreate(0, 4);
drCW = dmemWriteReal(drCW, 0, fft_config, 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_config.hex', test_name));
clear drCW;

drCW = dmemCreate(0, input_size_words+32);
drCW = dmemWriteComplex(drCW, input_offset, x_vsp(br_index), inputprec);
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_x.hex', test_name));
clear drCW;

drCW = dmemCreate(0, output_size_words);
% drCW = dmemWriteComplex(drCW, 0, opstruct.stage_out(:, 10), fftprec);
drCW = dmemWriteComplex(drCW, 0, fftout_vsp, outprec);
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_output_y_ref.hex', test_name));
clear drCW;

return;

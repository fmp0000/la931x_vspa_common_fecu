% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% function diffft_testbench
function diffft_testbench(N, inv, prec_type, input_offset, test_name)

%% config
circbuffsize = 4096+32;
%

%% generate test input and output vectors
br_index = bitrevorder(0:N-1)' + 1;

x_dbl = complex(2*rand(N, 1)-1, 2*rand(N, 1)-1);

switch prec_type
    case 0
        x_vsp = r_half(x_dbl);
        inputprec = 'half_fixed';
        fftprec = 'single';
        outprec = 'single';
        scaleout = 0;
        output_size_words = 2*N;
        
        circ_index = mod(input_offset + (0:N-1), circbuffsize) + 1;
        x_in_buffer(circ_index) = x_vsp;
        
    case 1
        x_vsp = r_half(x_dbl);
        inputprec = 'half_fixed';
        fftprec = 'half_fixed';
        outprec = 'half_fixed';
        scaleout = 1;
        output_size_words = N;
        
        circ_index = mod(input_offset + (0:N-1), circbuffsize) + 1;
        x_in_buffer(circ_index) = x_vsp;

    case 2
        x_vsp = r_half(x_dbl);
        inputprec = 'half_fixed';
        fftprec = 'half';
        outprec = 'half';
        scaleout = 0;
        output_size_words = N;
        
        circ_index = mod(input_offset + (0:N-1), circbuffsize) + 1;
        x_in_buffer(circ_index) = x_vsp;

    otherwise
        error('Unknown precision type');
end

[fftout_vsp, ~, opstruct] = r_dif_fft(x_vsp, inv, fftprec, scaleout);
fprintf('FFT QNS = %.2f dB\n', opstruct.qns);


%% create cw data files
fft_config = [N; inv; prec_type; input_offset];
drCW = dmemCreate(0, 4);
drCW = dmemWriteReal(drCW, 0, fft_config, 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_config.hex', test_name));
clear drCW;

drCW = dmemCreate(0, circbuffsize);
drCW = dmemWriteComplex(drCW, 0, x_in_buffer, inputprec);
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_x.hex', test_name));
clear drCW;

drCW = dmemCreate(0, output_size_words);
% drCW = dmemWriteComplex(drCW, 0, opstruct.stage_out(:, 3), fftprec);
drCW = dmemWriteComplex(drCW, 0, fftout_vsp(br_index), outprec);
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_output_y_ref.hex', test_name));
clear drCW;

return;


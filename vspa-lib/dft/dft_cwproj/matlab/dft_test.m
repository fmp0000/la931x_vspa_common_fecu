% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
clear all;
close all;
clc;

% Add paths
addpath('../../../common/matlab/utils');
addpath('../../../common/matlab/vspa');
addpath('../../matlab');

% Get tesplan
dft_testplan;

% Make in/ref directories
if ~isdir(TC_IN_PATH)
    mkdir(TC_IN_PATH);
end
if ~isdir(TC_REF_PATH)
    mkdir(TC_REF_PATH);
end

% Generate testvectors
for tcInd = 1 : length(TC_ARRAY)
    
    % Current testcase name
    tcName = TC_ARRAY(tcInd).tcName;
    fprintf('-> Generating testcase %s ...\n', tcName);
    
    % Random generator seed for testvector reproducibility
    rng(tcInd);

    % Testcase directories
    tcInDir  = [TC_IN_PATH,  tcName, '/'];
    tcOutDir = [TC_OUT_PATH, tcName, '/'];
    tcRefDir = [TC_REF_PATH, tcName, '/'];
    
    % Create directories
    if ~isdir(tcInDir)
        mkdir(tcInDir);
    end
    if ~isdir(tcRefDir)
        mkdir(tcRefDir);
    end
    
    % Testcase parameters
    n_dft     = TC_ARRAY(tcInd).n_dft;
    inp_prec  = TC_ARRAY(tcInd).inp_prec;
    out_prec  = TC_ARRAY(tcInd).out_prec;
    
    % Control parameters
    ctrl.inp_prec = inp_prec;
    ctrl.out_prec = out_prec;
    
    % Input generation
    in = rand(1,n_dft) + 1i* rand(1,n_dft);
    
    % DFT perform

    [dft_seq_m] = m_dft(in);
    [dft_seq_v] = r_dft(in,ctrl);
    
    % Verify the difference between the models
    m_v_err_lin = mean(abs(dft_seq_m - dft_seq_v))/mean(abs(dft_seq_m));
    m_v_err_pwr = mean(abs(dft_seq_m - dft_seq_v) .^ 2);
    m_v_sig_pwr = mean(abs(dft_seq_m) .^ 2);
    sqnr_log = 10 * log10(m_v_sig_pwr / m_v_err_pwr);
    fprintf('\t Matlab vs VSPA model: mean abs error = %e \n', m_v_err_lin);
    fprintf('\t Matlab vs VSPA model: SQNR = %4.2f [dB]\n', sqnr_log);
    if (m_v_err_lin > 1e-1)
        error('Matlab vs VSPA model mismatch for %s !', tcName);
    end
    
    % ---------------------- Export input data ----------------------------
    % Export input
    filePath = [tcInDir, 'input.bin'];   
    vspaExportComplex(in, inp_prec, filePath);
    
     % Export control structure
    filePath = [tcInDir, 'ctrl.bin'];
    inp_precIdx = find(strcmp(PREC_TYPES, inp_prec)) - 1;
    out_precIdx = find(strcmp(PREC_TYPES, out_prec)) - 1;
    ctrl_data = [n_dft, inp_precIdx, out_precIdx];
    vspaExportReal(ctrl_data, 'uint', filePath);
    
    % --------------------- Export reference data -------------------------  
    % Export VSPA model reference dot product
    filePath = [tcRefDir, 'out.bin'];
    vspaExportComplex(dft_seq_v, out_prec, filePath);
    
    % Debug error
    if 0
        err = abs(dft_seq_m - dft_seq_v) ./ abs(dft_seq_m);
        figure('Color', 'w');
        plot(err); grid;
        keyboard();
    end
end

fprintf('\n Testcase generation done ...\n\n\n');

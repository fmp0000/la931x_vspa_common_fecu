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
cycShiftFD_testplan;

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
    inp_len     =  TC_ARRAY(tcInd).len;
    inp_shift   =  TC_ARRAY(tcInd).shift;
    num_cHF_per_line  = 32;
    
    % Control parameters
    ctrl.shift = inp_shift;
    
    % Generate random input
    inp = randn(inp_len, 1) + 1i * randn(inp_len, 1);
    
    % Perform cyclic shift

    [y_mat] = m_cycShiftFD(inp, ctrl);
    [y_vsp] = r_cycShiftFD(inp, ctrl);

	% Verify the difference between the models
    m_v_err_pwr = mean(abs(y_mat - y_vsp) .^ 2);
    m_v_sig_pwr = mean(abs(y_mat) .^ 2);
    sqnr_log = 10 * log10(m_v_sig_pwr / m_v_err_pwr);
    fprintf('\t Matlab vs VSPA model: SQNR = %4.2f [dB]\n', sqnr_log);
    
    %  ---------------------- Export input data ----------------------------
    % Export input
    filePath = [tcInDir, 'inp.bin'];
    vspaExportComplex(inp, 'half', filePath);
    
    % Export control structure
    filePath = [tcInDir, 'ctrl.bin'];
    ctrl_data = [inp_shift, inp_len];
    vspaExportReal(ctrl_data, 'uint', filePath);
    
    % --------------------- Export reference data -------------------------
    % Export reference output
    filePath = [tcRefDir, 'out.bin'];
    vspaExportComplex(y_vsp, 'half', filePath);
      
end

fprintf('\n Testcase generation done ...\n\n\n');

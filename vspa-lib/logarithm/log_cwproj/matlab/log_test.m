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
log_testplan;

% ========================= Generate testcases ============================
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
    inputLen = TC_ARRAY(tcInd).inputLen;
    logFact  = TC_ARRAY(tcInd).logFact;
    
    % ------------------------- Generate input ---------------------------- 
    % Generate input (+/- 50 dB)
    inp = logspace(-5, 5, inputLen);
    
    % ------------------------- Compute log -------------------------------    
    % Compute log
    [log_v, log_m] = r_log(inp, logFact);
    
    % Verify the difference between the models
    m_v_err = max(abs(log_m(:) - log_v(:)));
    fprintf('\t Matlab vs VSPA model: max abs error = %e \n', m_v_err);
    if (m_v_err > LOG_ERR_MAX)
        error('Matlab vs VSPA model mistmatch for %s !', tcName);
    end

    % ---------------------- Export input data ----------------------------
    % Export input data
    filePath = [tcInDir, 'input.bin'];
    vspaExportReal(inp, 'single', filePath);
    
    % Export control structure
    filePath = [tcInDir, 'ctrl.bin'];   
    ctrl_data = [inputLen, typecast(single(logFact), 'uint32')];
    vspaExportReal(ctrl_data, 'uint', filePath);
    
    % Export reference
    filePath = [tcRefDir, 'out.bin'];
    vspaExportReal(log_v, 'single', filePath);

    % ------------------- NON-BIT EXACT VALIDATION ------------------------
    % Since Matlab model is not exactly bit-exact:
    % if testcases were run verify here
    if isdir(tcOutDir)
        
        % Validation reference - Matlab model
        log_ref_v = log_m;
        
        % Import VSPA output
        filePath = [tcOutDir, 'out.bin'];
        log_out_v = vspaImportReal(filePath, 'single');

        % Verify error
        m_v_err = max(abs(log_ref_v(:) - log_out_v(:)));
        fprintf('\t VSPA implementation: max abs error = %e \n', m_v_err);
        if (m_v_err > LOG_ERR_MAX)
            error('VSPA implementation mistmatch for %s !', tcName);
        end

        % If test passed, replace reference with output
        filePath = [tcRefDir, 'out.bin'];
        vspaExportReal(log_out_v, 'single', filePath);
    end
    
end

fprintf('\n Testcase generation done ...\n');




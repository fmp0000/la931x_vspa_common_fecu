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
dot_prod_testplan;

% Params
INP1_PREC = 'half_fixed';
INP2_PREC = 'half_fixed';
OUT_PREC  = 'single';

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
    inputLen  = TC_ARRAY(tcInd).inputLen;
    allocType = TC_ARRAY(tcInd).allocType;
    
    % ---------------------- Generate random input ------------------------   
    inp1 = randn(inputLen, 1) + 1i * randn(inputLen, 1);
    inp2 = randn(inputLen, 1) + 1i * randn(inputLen, 1);
    
    % Normalize input for Half Fixed precision
    if strcmp(INP1_PREC, 'half_fixed')
        inp1_abs = max(abs(inp1(:)));
        inp1 = inp1 ./ inp1_abs .* (1 - 2^(-15));
    end
    if strcmp(INP2_PREC, 'half_fixed')
        inp2_abs = max(abs(inp2(:)));
        inp2 = inp2 ./ inp2_abs .* (1 - 2^(-15));
    end
    
    % Dot product params
    dot_prod_ctrl.inp1_prec = INP1_PREC;
    dot_prod_ctrl.inp2_prec = INP2_PREC;
    dot_prod_ctrl.out_prec  = OUT_PREC;
    
    % Dot product
    [dot_prod_v, dot_prod_m] = r_dot_prod(inp1, inp2, dot_prod_ctrl);
    
    % Verify the difference between the models
    m_v_dot_prod_err = mean(abs(dot_prod_m - dot_prod_v)) / mean(abs(dot_prod_m));
    fprintf('\t Matlab vs VSPA model: mean abs rel error = %e \n', m_v_dot_prod_err);
    if (m_v_dot_prod_err > 1e-4)
        error('Matlab vs VSPA model mismatch for %s !', tcName);
    end
    
    % ---------------------- Export input data ----------------------------
    % Export input1
    filePath = [tcInDir, 'input1.bin'];
    vspaExportComplex(inp1, INP1_PREC, filePath);
    
    % Export input2
    filePath = [tcInDir, 'input2.bin'];
    vspaExportComplex(inp2, INP2_PREC, filePath);
    
    % Export control structure
    if strcmp(allocType, 'circular')
        inputAlloc = 0;
    else
        inputAlloc = 1;
    end
    
    filePath = [tcInDir, 'ctrl.bin'];   
    ctrl_data = [inputLen, inputAlloc];
    vspaExportReal(ctrl_data, 'uint', filePath);
    
    % --------------------- Export reference data -------------------------  
    % Export VSPA model reference dot product
    filePath = [tcRefDir, 'dot_prod.bin'];
    vspaExportComplex(dot_prod_v, OUT_PREC, filePath);
    
end

fprintf('\n Testcase generation done ...\n\n\n');

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
matrix_testplan;

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
    vecPrec   = TC_ARRAY(tcInd).vecPrec;
    matPrec   = TC_ARRAY(tcInd).matPrec;
    outPrec   = TC_ARRAY(tcInd).outPrec;
    dim1      = TC_ARRAY(tcInd).dim1;
    dim2      = TC_ARRAY(tcInd).dim2;
    dim3      = TC_ARRAY(tcInd).dim3;
    matInterp = TC_ARRAY(tcInd).matInterp;
       
    % ---------------------- Generate random input ------------------------
    % Generate random input vector batch & normalize for Half Fixed
    vec = randn(dim1, dim2) + 1i .* randn(dim1, dim2);
    if strcmp(vecPrec, 'half_fixed')
        vec_amp = max(abs(vec(:)));
        vec     = vec ./ vec_amp .* (1 - 2^(-15));
    end
    
    % Generate random input matrix batch & normalize for Half Fixed
    matDim1 = dim1 / matInterp;
    mat = randn(matDim1, dim3, dim2) + 1i .* randn(matDim1, dim3, dim2);
    if strcmp(matPrec, 'half_fixed')
        mat_amp = max(abs(mat(:)));
        mat     = mat ./ mat_amp .* (1 - 2^(-15));
    end
    
    % ---------------------- Matrix multiplication ------------------------
    % Control structure
    ctrl.vec_prec   = vecPrec;
    ctrl.mat_prec   = matPrec;
    ctrl.out_prec   = outPrec;
    ctrl.mat_interp = matInterp;
    
    % Perform matrix multiplication
    [out_v, out_m] = r_mat_bmult(vec, mat, ctrl);

    % Verify the difference between the models
    m_v_err = mean(abs(out_m(:) - out_v(:)));
    fprintf('\t Matlab vs VSPA model: mean abs error = %e \n', m_v_err);
    if m_v_err > 1e-2
        error('Matlab vs VSPA model mistmatch for %s !', tcName);
    end

    % ---------------------- Export input data ----------------------------
    % Export vector batch
    filePath = [tcInDir, 'vec.bin'];
    vspaExportComplex(vec(:), vecPrec, filePath);
    
    % Export matrix batch
    filePath = [tcInDir, 'mat.bin'];
    vspaExportComplex(mat(:), matPrec, filePath);
    
    % Export control structure
    filePath = [tcInDir, 'ctrl.bin'];   
    vecPrecIdx = find(strcmp(PREC_TYPES, vecPrec)) - 1;
    matPrecIdx = find(strcmp(PREC_TYPES, matPrec)) - 1;
    outPrecIdx = find(strcmp(PREC_TYPES, outPrec)) - 1;
    ctrl_data  = [vecPrecIdx, matPrecIdx, outPrecIdx, dim1, dim2, dim3, matInterp];
    vspaExportReal(ctrl_data, 'uint', filePath);
    
    % --------------------- Export reference data -------------------------  
    % Export VSPA model reference
    filePath = [tcRefDir, 'out.bin'];
    vspaExportComplex(out_v(:), outPrec, filePath);
    
end

fprintf('\n Testcase generation done ...\n\n\n');


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
atan_testplan;

% Fixed params
ATAN_COEFF_PATH = '../../src/atan_coeff.txt';
ATAN_COEFF_PREC = 'single';

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
    numCoeff = TC_ARRAY(tcInd).numCoeff;
    inpPrec  = TC_ARRAY(tcInd).inpPrec;
    outPrec  = TC_ARRAY(tcInd).outPrec;
    inpType  = TC_ARRAY(tcInd).inpType;
    
    % ------------------------- Generate input ---------------------------- 
    if strcmp(inpType, 'RANDOM')
        
        % Random complex input
        inp = complex(randn(inputLen, 1), randn(inputLen, 1));
        
    elseif strcmp(inpType, 'LINEAR')
        
        % Full circle linear phase
        inp = exp(1i * linspace(-pi,pi,inputLen).');

    elseif strcmp(inpType, 'PHASE_CC')   
        
        % Corner case phase values
        phase_cc = repmat(INP_PHASE_TEST(:), ceil(inputLen / length(INP_PHASE_TEST)), 1);
        phase_cc = phase_cc(1 : inputLen);
        inp = exp(1i .* phase_cc);
        
    else
        
        % Corner case complex values
        complex_cc = repmat(INP_CPLX_TEST(:), ceil(inputLen / length(INP_CPLX_TEST)), 1);
        complex_cc = complex_cc(1 : inputLen);
        inp = complex_cc;
    end
    
    % Normalize input values for Half Fixed precision
    if strcmp(inpPrec, 'half_fixed')
        inp_re = abs(real(inp));
        inp_im = abs(imag(inp));
        inp_max = max([inp_re(:); inp_im(:)]);
        HF16_MAX = 1 - 2^(-15);
        inp_sc_idx = abs(inp) > HF16_MAX;
        inp_sc_re = real(inp(inp_sc_idx)) / inp_max * HF16_MAX;
        inp_sc_im = imag(inp(inp_sc_idx)) / inp_max * HF16_MAX;
        inp(inp_sc_idx) = complex(inp_sc_re, inp_sc_im);
    end
    
    % ------------------------- Compute atan2 -----------------------------
    % Atan params
    atan2_ctrl.inp_prec   = inpPrec;
    atan2_ctrl.coeff_prec = ATAN_COEFF_PREC;
    atan2_ctrl.num_coeff  = numCoeff;
    atan2_ctrl.out_prec   = outPrec;
    
    % Compute atan2
    [atan2_v, coeff_v, atan2_m] = r_atan2(inp, atan2_ctrl);
    
    % Verify the difference between the models
    m_v_err = max(abs(atan2_m(:) - atan2_v(:)));
    fprintf('\t Matlab vs VSPA model: max abs error = %e \n', m_v_err);
    if m_v_err > 1e-3
        error('Matlab vs VSPA model mistmatch for %s !', tcName);
    end

    % ---------------------- Export input data ----------------------------
    % Export input
    filePath = [tcInDir, 'input.bin'];
    vspaExportComplex(inp, atan2_ctrl.inp_prec, filePath);
    
    % Export control structure
    inpPrecIdx = find(strcmp(ATAN_PREC, inpPrec)) - 1;
    outPrecIdx = find(strcmp(ATAN_PREC, outPrec)) - 1;
    filePath = [tcInDir, 'ctrl.bin'];   
    ctrl_data = [inputLen, inpPrecIdx, outPrecIdx];
    vspaExportReal(ctrl_data, 'uint', filePath);
    
    % --------------------- Export reference data -------------------------  
    % Export VSPA model reference dot product
    filePath = [tcRefDir, 'atan_ref.bin'];
    vspaExportReal(atan2_v, atan2_ctrl.out_prec, filePath);
    
end

% Export TCL info
filePath = [TCL_PATH, 'test_macro.tcl'];
fid = fopen(filePath, 'wt');
fprintf(fid, '# Matlab auto generated file for testing. Do not edit!\n');
fprintf(fid, 'set ATAN_NUM_COEFF { ');
for tcInd = 1 : length(TC_ARRAY)
    fprintf(fid, [num2str(TC_ARRAY(tcInd).numCoeff), ' ']);
end
fprintf(fid, '}');
fclose(fid);

fprintf('\n Testcase generation done ...\n');

% ====================== Write coefficients to file =======================
% Defines
define_header = '#if (ATAN2_NUM_COEFF == %d) \n';
define_footer = '#endif \n';

% Open file
fh = fopen(ATAN_COEFF_PATH, 'wt');

for num_coeff = ATAN_NUM_COEFF_ARRAY

    % ---------------------- Get max abs error ----------------------------
    % Derive the max abs error for each in/out precision for full circle
    % Also generate the coefficients
    max_abs_err  = zeros(length(ATAN_PREC), length(ATAN_PREC));
    mean_abs_err = zeros(length(ATAN_PREC), length(ATAN_PREC));
    inp_cplx = 0.9 * exp(1i .* linspace(-pi,pi,10000));
    
    for inp_prec_idx = 1 : length(ATAN_PREC)
        for out_prec_idx = 1 : length(ATAN_PREC)
            
            % Atan params
            atan2_ctrl.inp_prec   = ATAN_PREC{inp_prec_idx};
            atan2_ctrl.coeff_prec = ATAN_COEFF_PREC;
            atan2_ctrl.out_prec   = ATAN_PREC{out_prec_idx};
            atan2_ctrl.num_coeff  = num_coeff;
            
            % Generate coefficients
            [atan2_v, coeff_v, atan2_m] = r_atan2(inp_cplx, atan2_ctrl);
            
            % Store
            max_abs_err(inp_prec_idx, out_prec_idx)  = max(abs(atan2_v(:) - atan2_m(:)));
            mean_abs_err(inp_prec_idx, out_prec_idx) = mean(abs(atan2_v(:) - atan2_m(:)));
        end
    end

    % --------------------- Write coefficients ----------------------------
    % Write header
    fprintf(fh, sprintf(define_header, num_coeff));

    % Write error performance for each in/out precision
    for inp_prec_idx = 1 : length(ATAN_PREC)
        for out_prec_idx = 1 : length(ATAN_PREC)
            fprintf(fh, '// inp_prec = %-10s   out_prec = %-10s', ATAN_PREC{inp_prec_idx}, ATAN_PREC{out_prec_idx});
            fprintf(fh, '   max_abs_error = %10.9f',    max_abs_err(inp_prec_idx, out_prec_idx));
            fprintf(fh, '   mean_abs_error = %10.9f \n', mean_abs_err(inp_prec_idx, out_prec_idx));
        end
    end
    
    % Write comment
    fprintf(fh, '// coeff = ');
    for idx = 1 : (length(coeff_v) - 1)
        fprintf(fh, '%f, ', coeff_v(idx));
    end
    fprintf(fh, '%f \n', coeff_v(end));

    % Write hex values
    sizeHW = length(coeff_v) * precSize(ATAN_COEFF_PREC);   % Size (in Half Words)
    sizeFW = sizeHW / 2;                                    % Size (in Full Words)
    dmemIn = dmemCreate(0, sizeFW);
    dmemIn = dmemWriteReal(dmemIn, 0, coeff_v(:), ATAN_COEFF_PREC);

    for idx = 1 : length(dmemIn.data)
        
        % Hex value
        hex_str = dec2hex(uint32(dmemIn.data(idx)), 8);

        % Write 2 times each coefficient
        fprintf(fh, '0x%08s, ', hex_str);
        fprintf(fh, '0x%08s',   hex_str);
        if (idx ~= length(dmemIn.data))
            fprintf(fh, ', ');
        else
            fprintf(fh, '\n');
        end
    end

    % Write footer
    fprintf(fh, define_footer);
    fprintf(fh, '\n');
end
    
% Write macro validation sequence
fprintf(fh, '#if !((%d <= ATAN2_NUM_COEFF ) && (ATAN2_NUM_COEFF <= %d)) \n', ATAN_NUM_COEFF_ARRAY(1), ATAN_NUM_COEFF_ARRAY(end));
fprintf(fh, '#error "The number of coefficients is not supported!" \n');
fprintf(fh, '#endif \n');
fclose(fh);

fprintf('\n Atan coefficients written to file ...\n\n\n');

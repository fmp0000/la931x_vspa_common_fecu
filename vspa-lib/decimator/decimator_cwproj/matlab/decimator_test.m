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
decimator_testplan;

% Filter coefficient path
FILTER_PATH = '../../src/decimator_filter.txt';

%--------------------------- FILTER DESIGN --------------------------------
FILTER_BUFF = cell(size(FILTER_LEN_BUFF));

for flt_idx = 1 : length(FILTER_LEN_BUFF)

    % Filter design (FIR, half-band, linear phase, real)
    flt_len = FILTER_LEN_BUFF(flt_idx);
    Freq = [0, 0.25, 0.25, 0.5] * 2; 
    Amp  = [1,    1,    0,   0];
    flt = firls(flt_len - 1, Freq, Amp);
    
    % Store
    FILTER_BUFF{flt_idx} = flt(:);
    
end

%------------------------- TESTCASE GENERATION ----------------------------
% Make in/ref directories
if ~isdir(TC_IN_PATH)
    mkdir(TC_IN_PATH);
end
if ~isdir(TC_REF_PATH)
    mkdir(TC_REF_PATH);
end

% Generate each testvector
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
    decimFact = TC_ARRAY(tcInd).decimFact;
    numBlocks = TC_ARRAY(tcInd).numBlocks;
    outputLen = TC_ARRAY(tcInd).outputLen;
    filterLen = TC_ARRAY(tcInd).filterLen;
    
    % Derive input length of one block (samples)
    inputLen  = outputLen * decimFact;
    
    % ---------------------- Generate random input ------------------------
    % Generate random complex input (Half Fixed)
    inp = randn(inputLen, numBlocks) + 1i * randn(inputLen, numBlocks);
    
    % Normalize input for Half Fixed precision
    inp_amp = max(abs(inp(:)));
	inp = inp ./ inp_amp .* (1 - 2^(-15));
    
    % Filter index
    flt_idx = find(FILTER_LEN_BUFF == filterLen);
    
    % Filter coefficients
    flt = FILTER_BUFF{flt_idx};
    
    % ------------------------- Call Decimator ----------------------------
    % Decimator params
    ctrl.input_prec  = 'half_fixed';
    ctrl.filter_prec = FILTER_PREC;
    ctrl.output_prec = 'half_fixed';
    ctrl.factor      = decimFact;
    
    % Initialize input history for first input block decimation
    inp_hist_v = zeros(filterLen - 1, log2(decimFact));
    inp_hist_m = zeros(filterLen - 1, log2(decimFact));
    
    % Intialize output arrays
    out_v = zeros(outputLen, numBlocks);
    out_m = zeros(outputLen, numBlocks);
    
    % Decimate block-wise
    for block_idx = 1 : numBlocks
        
        % Call decimator for current input block
        [out_v(:,block_idx), next_hist_v] = decimator_v(inp(:,block_idx), flt, ctrl, inp_hist_v);
        [out_m(:,block_idx), next_hist_m] = decimator_m(inp(:,block_idx), flt, ctrl, inp_hist_m);
        
        % Input history for next call
        inp_hist_v = next_hist_v;
        inp_hist_m = next_hist_m;
    end 
    
    % Verify the difference between the models
    m_v_err = mean(abs(out_m(:) - out_v(:)));
    fprintf('\t Matlab vs VSPA model mean absolute error = %e \n', m_v_err);
    if (m_v_err > 1e-4)
        error('Matlab vs VSPA model mistmatch for %s !', tcName);
    end
    
    % ---------------------- Export input data ----------------------------
    % Export input
    filePath = [tcInDir, 'input.bin'];
    vspaExportComplex(inp(:), ctrl.input_prec, filePath);
    
    % Export control structure
    filePath = [tcInDir, 'ctrl.bin'];   
    ctrl_data = [decimFact, numBlocks, outputLen];
    vspaExportReal(ctrl_data, 'uint', filePath);
    
    % --------------------- Export reference data -------------------------  
    % Export VSPA model output as reference
    filePath = [tcRefDir, 'output.bin'];
    vspaExportComplex(out_v(:), ctrl.output_prec, filePath);
    
end

% Export TCL info
filePath = [TCL_PATH, 'test_macro.tcl'];
fid = fopen(filePath, 'wt');
fprintf(fid, '# Matlab auto generated file for testing. Do not edit!\n');
fprintf(fid, 'set DECIM_TEST_FLT_LEN { ');
for tcInd = 1 : length(TC_ARRAY)
    fprintf(fid, [num2str(TC_ARRAY(tcInd).filterLen), ' ']);
end
fprintf(fid, '}');
fclose(fid);

fprintf('\n Testcase generation done ...\n');

% ----------------------- Write filters to file ---------------------------
% Defines
define_header = '#if DECIM_FLT_LEN == %d \n';
define_footer = '#endif \n';

% Open file
fh = fopen(FILTER_PATH, 'wt');

% Filter length
for flt_idx = 1 : length(FILTER_LEN_BUFF)
    
    flt_len = FILTER_LEN_BUFF(flt_idx);
    flt     = FILTER_BUFF{flt_idx};
    
    % Invert filter order (not necessary for linear phase)
    flt = flt(:);
    flt = flipud(flt);

    % Define header
    fprintf(fh, sprintf(define_header, flt_len));
    
    % Write comment
    fprintf(fh, '// ');
    for idx = 1 : (length(flt) - 1)
        fprintf(fh, '%f, ', flt(idx));
    end
    fprintf(fh, '%f \n', flt(end));
    
    % Write hex values
    sizeHW = flt_len * precSize(FILTER_PREC);       % Size (in Half Words)
    sizeFW = sizeHW / 2;                            % Size (in Full Words)
    dmemIn = dmemCreate(0, sizeFW);
    dmemIn = dmemWriteReal(dmemIn, 0, flt(:), FILTER_PREC);

    for idx = 1 : length(dmemIn.data)
        hex_str = dec2hex(uint32(dmemIn.data(idx)), 8);
        fprintf(fh, '0x%08s', hex_str);
        if (idx ~= length(dmemIn.data))
            fprintf(fh, ', ');
        else
            fprintf(fh, '\n');
        end
    end
    
    % Define footer
    fprintf(fh, define_footer );
    
    fprintf(fh, '\n');

end

% Write macro validation sequence
fprintf(fh, '#if !((%d <= DECIM_FLT_LEN) && (DECIM_FLT_LEN <= %d) && ((DECIM_FLT_LEN %% 2) == 0)) \n', FILTER_LEN_BUFF(1), FILTER_LEN_BUFF(end));
fprintf(fh, '#error "Decimator filter length is not supported!" \n');
fprintf(fh, '#endif \n');
fclose(fh);

fprintf('\n Filter coefficients written to file ...\n\n\n');

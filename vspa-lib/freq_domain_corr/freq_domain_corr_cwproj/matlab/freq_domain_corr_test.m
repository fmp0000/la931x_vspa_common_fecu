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
freq_domain_corr_testplan;

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
    num_sbc     = TC_ARRAY(tcInd).numSbc;
    num_streams = TC_ARRAY(tcInd).numStreams;
    phase_init  = TC_ARRAY(tcInd).phaseInit;
    
    % Generate random input
    inp_m = randn(num_sbc, 1, num_streams);
    inp_v = inp_m;
    
    % Generate random gains
    gain_m = complex(randn(), randn());
    gain_v = gain_m;
    
    % Generate random frequency (int32)
    phase_ramp_m = randi([0,100]);
    phase_ramp_v = phase_ramp_m;
    
    % Phase init
    phase_init_m = phase_init;
    phase_init_v = phase_init;
    
    % ---------------------- Frequency Domain Correction ------------------
    % Perform correction
    [out_v, out_m] = r_freq_domain_corr(inp_v, gain_v, phase_ramp_v, phase_init_v, inp_m, gain_m, phase_ramp_m, phase_init_m);

    % Verify the difference between the models - pilot multiplication
    m_v_err = mean(abs(out_v(:) - out_m(:)));
    fprintf('\t Matlab vs VSPA model: error = %e \n', m_v_err);
    assert(m_v_err < 1e-2, 'Matlab vs VSPA model mistmatch for %s !', tcName);

    % ---------------------- Export input data ----------------------------
    % Export input pilot symbols
    filePath = [tcInDir, 'inp.bin'];
    vspaExportComplex(inp_v, 'half', filePath);
    
    % Export complex gain
    filePath = [tcInDir, 'gain.bin'];
    vspaExportComplex(gain_v, 'single', filePath);
    
    % Export control structure
    filePath = [tcInDir, 'ctrl.bin'];   
    fid = fopen(filePath, 'w');
    fwrite(fid, num_sbc,      'uint32');
    fwrite(fid, num_streams,  'uint32');
    fwrite(fid, phase_ramp_v, 'int32');
    fwrite(fid, phase_init_v, 'int32');
    fclose(fid);
    
    % --------------------- Export reference data -------------------------  
    % Export input pilot symbols
    filePath = [tcRefDir, 'out.bin'];
    vspaExportComplex(out_v, 'half', filePath);

end

fprintf('\n Testcase generation done ...\n\n\n');

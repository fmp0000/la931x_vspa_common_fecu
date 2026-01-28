% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
clear all
close all
clc

%Add paths - To Be Changed
addpath('..\..\..\common\matlab\utils');
addpath('..\..\..\common\matlab\vspa');

%Set xls
TC_XLS_FILENAME = '..\..\doc\fd_qec_Testplan.xlsx';
TC_XLS_SHEET    = 'fd_qec';
TC_IN_PATH      = '../vector/in/';
TC_OUT_PATH     = '../vector/out/';
TC_REF_PATH     = '../vector/ref/';
TCL_PATH        = '../script/';
TC_FORMAT       = 'TC%03d';

[Num, Text, Raw] = xlsread(TC_XLS_FILENAME, TC_XLS_SHEET);

%Keep only relevant information
Raw = Raw(2:end,:);
Raw(:,1) = cellfun(@(x) sprintf( TC_FORMAT, x),Raw(:,1),'uni',false);

TC_ARRAY = cell2struct(Raw,Text,2);

for tcIdx = 1:length(TC_ARRAY)
    tcIdx
    % Current testcase name
    tcName = TC_ARRAY(tcIdx).tcName;
    fprintf('-> Generating testcase %s ...\n', tcName);
    
    % Set testcase directories
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
    bufLen   = TC_ARRAY(tcIdx).bufLen;
    
    % Set input
    inputBuf = randn(1,bufLen)+ 1i* randn(1,bufLen);
    inputBuf = inputBuf/ max(inputBuf);
    inputBuf = inputBuf -2^-15;
    
    % Convert input precision
    temp = r_convert(  inputBuf(:), 'half_fixed');
    inputBuf = reshape(temp, size( inputBuf ));
    
    %Mirror signal
    inputBuf_mirror = [];
    for i = 0:bufLen-1
        inputBuf_mirror(i+1) = inputBuf(bufLen-i);
    end
    temp = r_convert(inputBuf_mirror(:), 'half_fixed');
    inputBuf_mirror = reshape(temp, size(  inputBuf_mirror));
    
    %Set weights
    weightBuf_a = randn(1,bufLen)+ 1i* randn(1,bufLen);
    weightBuf_a = weightBuf_a/ max(weightBuf_a);
    weightBuf_a = weightBuf_a -2^-15;
    temp = r_convert(  weightBuf_a(:), 'half_fixed');
    weightBuf_a = reshape(temp, size( weightBuf_a ));
    
    weightBuf_b = randn(1,bufLen)+ 1i* randn(1,bufLen);
    weightBuf_b = weightBuf_b/ max(weightBuf_b);
    weightBuf_b = weightBuf_b -2^-15;
    temp = r_convert(  weightBuf_b(:), 'half_fixed');
    weightBuf_b = reshape(temp, size( weightBuf_b));
    
    % FD QEC
    [outputBuf, outputBuf_bx] = fd_qec(inputBuf, inputBuf_mirror, weightBuf_a, weightBuf_b); %

    % Export input data
    inputBuf = [inputBuf inputBuf_mirror weightBuf_a weightBuf_b];
    filePath = [tcInDir, 'input.bin'];
    vspaExportComplex(inputBuf, 'half_fixed', filePath);
    
    % Export control
    filePath = [tcInDir, 'ctrl.bin'];
    ctrlData = [bufLen];
    vspaExportComplex(ctrlData, 'uint', filePath);
    
    % Export reference data
    filePath = [tcRefDir, 'output.bin'];
    vspaExportComplex(outputBuf_bx, 'half_fixed', filePath);
    
end


% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%------------------------------ DEFINES -----------------------------------    
LOG_PREC = {'single'};                      % In/out precision types for log computation
LOG_FACT = [1, 10*log10(2), 20*log10(2)];   % Logarithm factors arrays
LOG_ERR_MAX = 1e-3;                         % Logarithm maximum error (log scale)

%----------------------------- TESTPLAN -----------------------------------
% Testcase parameters
TC_XLS_PATH  = '../../doc/Log_Testplan.xlsx';
TC_XLS_SHEET = 'Log';
TC_IN_PATH   = '../vector/in/';
TC_OUT_PATH  = '../vector/out/';
TC_REF_PATH  = '../vector/ref/';
TCL_PATH     = '../script/';
TC_FORMAT    = 'TC%03d';
TC_NUM_COLS  = 3;
TC_NUM       = 3;

% Derive XLS range
alphabet = {'','A','B','C','D','E','F','G','H','I','J','K','L','M', ...
               'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'  };
range_start = 'A2';
range_end   = [alphabet{TC_NUM_COLS + 1}, num2str(TC_NUM + 1)];
TC_XLS_RANGE = [range_start, ':', range_end];

% Testcase default structure
TC_STRUCT.tcName   = '';          % Testcase name
TC_STRUCT.inputLen = NaN;         % Input length (complex samples)
TC_STRUCT.logFact  = NaN;         % Logarithm factor

%-------------------------- READ TESTCASES --------------------------------
% Testplan initializations
TC_ARRAY = repmat(TC_STRUCT, 1, TC_NUM);

% Read raw data from XLS file
[Num, Text, Raw] = xlsread(TC_XLS_PATH, TC_XLS_SHEET, TC_XLS_RANGE);

for tcInd = 1 : TC_NUM

    % Testcase general params
    TC_ARRAY(tcInd).tcName   = sprintf(TC_FORMAT, tcInd - 1);
    TC_ARRAY(tcInd).inputLen = Raw{tcInd, 2}; 
    TC_ARRAY(tcInd).logFact  = eval(num2str(Raw{tcInd, 3}));
    
    % XLS parameter validation
    if ~ismember(TC_ARRAY(tcInd).logFact, LOG_FACT)
        error('Log factor invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    
end


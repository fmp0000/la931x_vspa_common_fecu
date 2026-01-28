% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%------------------------------ DEFINES -----------------------------------
PREC_TYPES = {'half_fixed', 'half', 'single', 'double'}; % Precision types

%----------------------------- TESTPLAN -----------------------------------
% Testcase parameters
TC_XLS_PATH  = '../../doc/DFT_Testplan.xlsx';
TC_XLS_SHEET = 'DFT';
TC_IN_PATH   = '../vector/in/';
TC_OUT_PATH  = '../vector/out/';
TC_REF_PATH  = '../vector/ref/';
TC_LUT_PATH  = '../../src/';
TC_FORMAT    = 'TC%03d';
TC_NUM_COLS  = 4;
TC_NUM       = 23;

% Derive XLS range
alphabet = {'','A','B','C','D','E','F','G','H','I','J','K','L','M', ...
               'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'  };
range_start = 'A2';
range_end   = [alphabet{TC_NUM_COLS + 1}, num2str(TC_NUM + 1)];
TC_XLS_RANGE = [range_start, ':', range_end];

% Testcase default structure
TC_STRUCT.tcName   = '';          % Testcase name
TC_STRUCT.n_dft    = NaN;
TC_STRUCT.inp_prec = '';
TC_STRUCT.out_prec = '';

%-------------------------- READ TESTCASES --------------------------------
% Testplan initializations
TC_ARRAY = repmat(TC_STRUCT, 1, TC_NUM);

% Read raw data from XLS file
[Num, Text, Raw] = xlsread(TC_XLS_PATH, TC_XLS_SHEET, TC_XLS_RANGE);

for tcInd = 1 : TC_NUM

    % Testcase general params
    TC_ARRAY(tcInd).tcName = sprintf(TC_FORMAT, Raw{tcInd, 1});
    TC_ARRAY(tcInd).n_dft      = Raw{tcInd, 2};
    TC_ARRAY(tcInd).inp_prec   = Raw{tcInd, 3};
    TC_ARRAY(tcInd).out_prec   = Raw{tcInd, 4};
    
end

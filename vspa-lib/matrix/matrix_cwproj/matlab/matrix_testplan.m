% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%------------------------------ DEFINES -----------------------------------
PREC_TYPES = {'half_fixed', 'half', 'single', 'double'}; % Precision types

%----------------------------- TESTPLAN -----------------------------------
% Testcase parameters
TC_XLS_PATH  = '../../doc/Matrix_Testplan.xlsx';
TC_XLS_SHEET = 'Matrix';
TC_IN_PATH   = '../vector/in/';
TC_OUT_PATH  = '../vector/out/';
TC_REF_PATH  = '../vector/ref/';
TC_FORMAT    = 'TC%03d';
TC_NUM_COLS  = 9;
TC_NUM       = 50;

% Derive XLS range
alphabet = {'','A','B','C','D','E','F','G','H','I','J','K','L','M', ...
               'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'  };
range_start = 'A2';
range_end   = [alphabet{TC_NUM_COLS + 1}, num2str(TC_NUM + 1)];
TC_XLS_RANGE = [range_start, ':', range_end];

% Testcase default structure
TC_STRUCT.tcName    = '';          % Testcase name
TC_STRUCT.vecPrec   = '';
TC_STRUCT.matPrec   = '';
TC_STRUCT.outPrec   = '';
TC_STRUCT.dim1      = NaN;
TC_STRUCT.dim2      = NaN;
TC_STRUCT.dim3      = NaN;
TC_STRUCT.matInterp = NaN;
TC_STRUCT.desc      = '';

%-------------------------- READ TESTCASES --------------------------------
% Testplan initializations
TC_ARRAY = repmat(TC_STRUCT, 1, TC_NUM);

% Read raw data from XLS file
[Num, Text, Raw] = xlsread(TC_XLS_PATH, TC_XLS_SHEET, TC_XLS_RANGE);

for tcInd = 1 : TC_NUM

    % Testcase general params
    TC_ARRAY(tcInd).tcName    = sprintf(TC_FORMAT, Raw{tcInd, 1});
    TC_ARRAY(tcInd).vecPrec   = Raw{tcInd, 2};
    TC_ARRAY(tcInd).matPrec   = Raw{tcInd, 3};
    TC_ARRAY(tcInd).outPrec   = Raw{tcInd, 4};
    TC_ARRAY(tcInd).dim1      = Raw{tcInd, 5};
    TC_ARRAY(tcInd).dim2      = Raw{tcInd, 6};
    TC_ARRAY(tcInd).dim3      = Raw{tcInd, 7};
    TC_ARRAY(tcInd).matInterp = Raw{tcInd, 8};
    TC_ARRAY(tcInd).desc      = Raw{tcInd, 9};
    
    % XLS parameter validation
    if ~ismember(TC_ARRAY(tcInd).vecPrec, PREC_TYPES)
        error('Vector precision invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    if ~ismember(TC_ARRAY(tcInd).matPrec, PREC_TYPES)
        error('Matrix precision invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    if ~ismember(TC_ARRAY(tcInd).outPrec, PREC_TYPES)
        error('Output precision invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
        
end


% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%------------------------------ DEFINES -----------------------------------
DECIM_FACT_ARRAY = [2,4,8];

FILTER_LEN_MIN  = 16;
FILTER_LEN_MAX  = 32;
FILTER_LEN_BUFF = FILTER_LEN_MIN : 2 : FILTER_LEN_MAX;
FILTER_PREC     = 'single';

MAX_NUM_BLOCKS = 4;

%----------------------------- TESTPLAN -----------------------------------
% Testcase parameters
TC_XLS_PATH  = '../../doc/Decimator_Testplan.xlsx';
TC_XLS_SHEET = 'Decimator';
TC_IN_PATH   = '../vector/in/';
TC_OUT_PATH  = '../vector/out/';
TC_REF_PATH  = '../vector/ref/';
TCL_PATH     = '../script/';
TC_FORMAT    = 'TC%03d';
TC_NUM_COLS  = 5;
TC_NUM       = 24;

% Derive XLS range
alphabet = {'','A','B','C','D','E','F','G','H','I','J','K','L','M', ...
               'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'  };
range_start = 'A2';
range_end   = [alphabet{TC_NUM_COLS + 1}, num2str(TC_NUM + 1)];
TC_XLS_RANGE = [range_start, ':', range_end];

% Testcase default structure
TC_STRUCT.tcName    = '';          % Testcase name
TC_STRUCT.decimFact = '';
TC_STRUCT.numBlocks = NaN;
TC_STRUCT.outputLen = NaN;
TC_STRUCT.filterLen = NaN;

%-------------------------- READ TESTCASES --------------------------------
% Testplan initializations
TC_ARRAY = repmat(TC_STRUCT, 1, TC_NUM);

% Read raw data from XLS file
[Num, Text, Raw] = xlsread(TC_XLS_PATH, TC_XLS_SHEET, TC_XLS_RANGE);

for tcInd = 1 : TC_NUM

    % Testcase general params
    TC_ARRAY(tcInd).tcName      = sprintf(TC_FORMAT, Raw{tcInd, 1});
    TC_ARRAY(tcInd).decimFact   = Raw{tcInd, 2};
    TC_ARRAY(tcInd).numBlocks   = Raw{tcInd, 3};
    TC_ARRAY(tcInd).outputLen   = Raw{tcInd, 4};
    TC_ARRAY(tcInd).filterLen   = Raw{tcInd, 5};
    
    % XLS parameter validation
    if ~ismember(TC_ARRAY(tcInd).decimFact,  DECIM_FACT_ARRAY)
        error('Decimator factor invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    if ~ismember(TC_ARRAY(tcInd).filterLen, FILTER_LEN_BUFF)
        error('Filter length invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    if (TC_ARRAY(tcInd).numBlocks > MAX_NUM_BLOCKS)
        error('Number of blocks invalid for %s !', TC_ARRAY(tcInd).tcName);    
    end    
end


% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%------------------------------ DEFINES -----------------------------------    
ATAN_NUM_COEFF_ARRAY = 3 : 10;                             % Range of polynomial coefficients number
ATAN_PREC            = {'half_fixed', 'half', 'single'};   % Precision types

% Type of input to test with:
% random   - random input
% linear   - linear span of full circle
% phase_cc - input with corner case phases
% cplx_cc  - input with corner case complex values
ATAN_INP_TYPES  = {'RANDOM', 'LINEAR', 'PHASE_CC', 'COMPLEX_CC'};  

%----------------------------- TESTPLAN -----------------------------------
% Testcase parameters
TC_XLS_PATH  = '../../doc/Atan_Testplan.xlsx';
TC_XLS_SHEET = 'Atan';
TC_IN_PATH   = '../vector/in/';
TC_OUT_PATH  = '../vector/out/';
TC_REF_PATH  = '../vector/ref/';
TCL_PATH     = '../script/';
TC_FORMAT    = 'TC%03d';
TC_NUM_COLS  = 6;
TC_NUM       = 56;      % Total number of testcases

% Derive XLS range
alphabet = {'','A','B','C','D','E','F','G','H','I','J','K','L','M', ...
               'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'  };
range_start = 'A2';
range_end   = [alphabet{TC_NUM_COLS + 1}, num2str(TC_NUM + 1)];
TC_XLS_RANGE = [range_start, ':', range_end];

% Testcase default structure
TC_STRUCT.tcName   = '';          % Testcase name
TC_STRUCT.inputLen = NaN;         % Input length (complex samples)
TC_STRUCT.numCoeff = NaN;         % Number of polynomial coefficients
TC_STRUCT.inpPrec  = '';          % Atan input precision
TC_STRUCT.outPrec  = '';          % Atan output precision
TC_STRUCT.inpType  = '';          % Input testing type

%-------------------------- READ TESTCASES --------------------------------
% Testplan initializations
TC_ARRAY = repmat(TC_STRUCT, 1, TC_NUM);

% Read raw data from XLS file
[Num, Text, Raw] = xlsread(TC_XLS_PATH, TC_XLS_SHEET, TC_XLS_RANGE);

for tcInd = 1 : TC_NUM

    % Testcase general params
    TC_ARRAY(tcInd).tcName    = sprintf(TC_FORMAT, tcInd - 1);
    TC_ARRAY(tcInd).inputLen  = Raw{tcInd, 2}; 
    TC_ARRAY(tcInd).numCoeff  = Raw{tcInd, 3};
    TC_ARRAY(tcInd).inpPrec   = Raw{tcInd, 4};
    TC_ARRAY(tcInd).outPrec   = Raw{tcInd, 5};
    TC_ARRAY(tcInd).inpType   = Raw{tcInd, 6};
    
    % XLS parameter validation
    if ~ismember(TC_ARRAY(tcInd).numCoeff, ATAN_NUM_COEFF_ARRAY)
        error('Number of coefficients invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    if ~ismember(TC_ARRAY(tcInd).inpPrec, ATAN_PREC)
        error('Atan input precision is invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    if ~ismember(TC_ARRAY(tcInd).outPrec, ATAN_PREC)
        error('Atan output precision is invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    if ~ismember(TC_ARRAY(tcInd).inpType, ATAN_INP_TYPES)
        error('Atan testing input type is invalid for %s !', TC_ARRAY(tcInd).tcName);
    end
    
end

%-------------------------- CORNER CASES TO TEST --------------------------
% Matlab has a poor support for -0. Use complex() function for such cases.
INP_CPLX_TEST = complex([+1, -1, +0, +0, +1, -1, -0, -0, +1, -1, +1, -1], ...
                        [+0, +0, +1, -1, -0, -0, +1, -1, +1, +1, -1, -1]  );
            
INP_PHASE_TEST = [-pi, -3*pi/4, -pi/2, -pi/4, 0, pi/4,  pi/2,  3*pi/4,  pi];

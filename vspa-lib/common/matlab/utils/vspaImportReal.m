% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [out] = vspaImportReal(filePath, prec)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [out] = vspaImportReal(filePath, prec)
%
% DESCRIPTION:
%   Imports VSPA specific data from binary file. 
%
% INPUTS:
%   filePath - full name of input file to import
%   prec     - export precision ('uint','half_fixed', 'half','single','double')
%
% OUTPUTS:
%   out      - output buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Export
fid = fopen(filePath, 'r');
data = fread(fid, 'uint32');
fclose(fid);

% Number of values to read
elem_size = precSize(prec);
elem_num  = floor(2 * length(data) / elem_size);

% Read data
dmemIn = dmemCreate(0, length(data));
dmemIn.data = data;
out = dmemReadReal(dmemIn, 0, elem_num, prec);



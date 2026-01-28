% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [roundSize] = dmemRoundSize(size, gran)
% Dmem utility to round (ceil) a size with given granularity.
% INPUTS:
%   size: input size
%   gran: granularity
% OUTPUTS:
%   roundSize : size rounded with given granularity

roundSize = ceil(size / gran) * gran;












% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function output = r_bitRev256( input_reOrd)
% DESCRIPTION:
%           Performs shifting and bit-reversal of the input
%
% INPUTS:
%   input_reOrd   : input buffer with 256 sub-carriers in bit-reverded order.
% OUTPUTS:
%   output   :  output buffer with 256 sub-carriers that are DC centered and in
%   linear order
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output] = r_bitRev256( input_reord)

if length(input_reord)~=256
    error('Input sub-carrier vector length must be 256.');
end

br_index = bitrevorder(0:255) + 1;
input_linear = input_reord(br_index);

output = [input_linear(129:end); ...
              input_linear(1:128)];
end










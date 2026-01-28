% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function output = r_bitRev( input)
% DESCRIPTION:
%           Performs shifting and bit-reversal of the input
%
% INPUTS:
%   input_reOrd   : input buffer with of various size (64,128,256 and 1024
%   samples)
% OUTPUTS:
%   output   :  output buffer of the same size as input, and is DC centered and in
%   linear order
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = r_bitRev( input)

N=length(input);

switch N
    case 64
        output=r_bitRev64(input);
    case 128
        output=r_bitRev128(input);
    case 256
        output=r_bitRev256(input);
    case 1024
        output=r_bitRev1024(input);
    otherwise
        error('fft size not supported')
end

end










% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright that - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION NAME: fix = custom_flt2fix (flt, bit, flag)
%
% DESCRIPTION: This function is equivalent to custom_flt2fix in ISS. It simulates the
% quantization effects that occur in the hardware's float to fixed conversion. The input
% real-valued floating-point values are converted into 32-bit fixed-point values after
% scaling depending on the position of the binary point specified.
%
% ARGUMENTS:
%    Inputs:
%      (1) flt: real-valued matrix of floating-point numbers
%      (2) bit: scalar integer, binary point is to the right of the bit specified,
%               acceptable values in the range [0, 31], defaults to 15
%      (3) flag:scalar integer, indicates whether the bit-width of fixed-point number
%               is 32 (flag=0, default) or 16 (flag=1) bits
%
%    Outputs:
%      (1) fxp: real-values matrix of fixed-point values
%
% IMPORTANT NOTES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REVISION HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  -------    -------------------    ------------    -------------------------------------
%  REV No.          AUTHOR               DATE                DESCRIPTION OF CHANGE
%  -------    -------------------    ------------    -------------------------------------
%  00.01       Paul Pawawongsak       2008.06.05      Initial version
%  00.10          Raja Tamma          2008.08.05      Corrected and added functionality
%  00.11          Raja Tamma          2009.04.09      Changed for RTI support
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  fix = custom_flt2fix(flt, bit, flag)
% assumed total bit-width of 32 bits with 1 sign bit and 15 fractional bits
MAX = 2^16 - 1/2^15;
MIN = -2^16;
if (nargin==3)
    if (flag)
        % assumed total bit-width of 16 bits with 1 sign bit and 15 fractional bits
        MAX = 1 - 1/2^15;
        MIN = -1;
    end
elseif (nargin==1)
    bit = 15;
end
if (bit>31 | bit<0)
    error ('Arg2 should be in the range [0, 31]');
end
flt = flt * 2^(bit-15); % pre-scaling operation
fix = floor((flt*2^15) + 0.5)/2^15;
fix = (fix > MAX)*MAX + (fix <= MAX).*fix;
fix = (fix < MIN)*MIN + (fix >= MIN).*fix;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

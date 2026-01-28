% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright that - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION NAME: flt = custom_fix2flt (fix, bit)
%
% DESCRIPTION: This function is equivalent to custom_fix2flt in ISS. It simulates the
% quantization effects that occur in the hardware's fixed to float conversion. The input
% real-valued 16-bit fixed-point values are converted into floating-point values and
% scaled depending on the position of the binary point specified.
%
% ARGUMENTS:
%    Inputs:
%      (1) fix: real-valued matrix of fixed-point numbers
%      (2) bit: scalar integer, binary point is to the right of the bit specified,
%               acceptable values in the range [0, 31], defaults to 15
%
%    Outputs:
%      (1) flt: real-values matrix of floating-point values
%
% IMPORTANT NOTES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REVISION HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  -------    -------------------    ------------    -------------------------------------
%  REV No.          AUTHOR               DATE                DESCRIPTION OF CHANGE
%  -------    -------------------    ------------    -------------------------------------
%  00.10          Raja Tamma          2008.08.05      Initial version
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  flt = custom_fix2flt(fix, bit)
MAX = 1 - 1/2^15;
MIN = -1;
fix = (fix > MAX)*MAX + (fix <= MAX).*fix;
fix = (fix < MIN)*MIN + (fix >= MIN).*fix;

int = real2float (fix);
flt = float2real (int);

if (nargin==1)
    bit = 15;
elseif (bit>31 | bit<0)
    error ('Arg2 should be in the range [0, 31]');
end
flt = flt * 2^(15 - bit); % post-scaling operation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

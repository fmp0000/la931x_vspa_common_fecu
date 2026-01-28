% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright that - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION NAME: fix = float2fix (flt)
%
% DESCRIPTION: This function is equivalent to float2fix in ISS. It simulates the
% quantization effects that occur in the hardware's float to fixed conversion. The input
% real-valued matlab float values are converted into 32-bit fixed-point
% values. The lower 15 bits represent the fractional part and the upper 17
% bits are for the integer part, which is in two's complements format.
%
% ARGUMENTS:
%    Inputs:
%      (1) flt: real-valued matrix of floating-point numbers
%
%    Outputs:
%      (1) fix: non-negative integer-valued matrix of fixed-point values.
%      Same size as flt.
% 
%
% IMPORTANT NOTES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REVISION HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  -------    -------------------    ------------    -------------------------------------
%  REV No.          AUTHOR               DATE                DESCRIPTION OF CHANGE
%  -------    -------------------    ------------    -------------------------------------
%  00.01           Sili Lu              2012.10.03      Initial version
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  fix = float2fix(flt)

flt=r_single(flt); %convert the matlab float format to single precision format

MAX = 2^16 - 2^-15;
MAX_fix=2^31-1;  % Max = 0x7fffffff

MIN = -2^16;
MIN_fix = 0; %NOTE: later we need to change this to Min = 2^31 (0x80000000)

frac_part=flt-floor(flt);
int_part=floor(flt);

frac_part=round(frac_part/2^-15);
int_part(sign(int_part)==-1)=2^17+int_part(sign(int_part)==-1);

fix=int_part*2^15+frac_part;


fix = (flt > MAX)*MAX_fix + (flt <= MAX).*fix;
fix = (flt < MIN)*MIN_fix + (flt >= MIN).*fix;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

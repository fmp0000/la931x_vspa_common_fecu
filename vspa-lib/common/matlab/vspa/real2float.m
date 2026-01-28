% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2006 - 2025   Freescale Semiconductor
% -------------------------------------------------------------------------------
% Freescale Confidential Proprietary
% -------------------------------------------------------------------------------
% Authur  : Paul Pawawongsak - R00119
% Desc    : This function converts Matlab's number to custom 16-bit floating
%           point format.  1-bit sign, 5-bit offsetted exponent, and 10-bit
%           mantissa.
% Usage   : Support input as vector too!
%           [s, eb, m] = real2float(real_in) returns s,e,m separately
%           y = real2float(real_in) returns s,e,m combined into a number
% -------------------------------------------------------------------------------
function  [s, eb, m] = real2float(real_in)

MAX = 2^16 - 32;
MIN = 2^(-16) + 2^(-26);
EBIAS = 16;

  s = (real_in < 0);

  abs_in = abs(real_in);
  abs_in_old = abs_in; 

  abs_in = (abs_in <= MAX).*abs_in + (abs_in > MAX).*MAX;

  abs_in = (abs_in >= MIN).*abs_in + (abs_in < MIN).*MIN;

  e  = floor(log2(abs_in));
  eb = e + EBIAS;


  m  = round(abs_in ./ (2.^e) * 1024) - 1024;
  m = m .* (abs_in_old >= (MIN - (2^-27)) );     %Zero Exception
  


% if used #arg out = 1, combine sign, exp, and mantissa into single  (16-bit) number
if (nargout <= 1)
  s =  s*2^15 + eb*2^10 + m;
end

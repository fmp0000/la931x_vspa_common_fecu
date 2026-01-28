% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2006 - 2025   Freescale Semiconductor
% -------------------------------------------------------------------------------
% Freescale Confidential Proprietary
% -------------------------------------------------------------------------------
% Authur  : Paul Pawawongsak - R00119
% Desc    : This function converts custom 16-bit floating point format to
%           Matlab's mumber.  1-bit sign, 5-bit offsetted exponent, and 
%           10-bit mantissa.
% Usage   : Support input as vector too!
%         : Can accept either 3 arguments specifying sign, exp, and mantissa
%         : or just 1 argument representing a 16-bit floating point number.
% -------------------------------------------------------------------------------
function  real_out = float2real(s, eb, m)
  if (nargin == 1)
    m  = bitand(s, 1023);
    eb = bitand(s, 31744)/1024;
    s  = bitget(s, 16);
  end

  e = eb - 16;
  
  %conver s to multiplying factor
  % s=0 -> 1, s=1 -> -1
  s_factor = (s==0)*2 - 1;

  real_out = s_factor .* (1 + m/1024) .* (2.^e);

  real_out = real_out .* ~(eb==0 & m==0);  %zero exception

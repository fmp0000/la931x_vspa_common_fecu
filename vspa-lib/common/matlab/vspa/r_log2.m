% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [y,y_dbl] = r_log2(x)

% r_log2: Ruby base 2 logarithm.  
% [y,y_dbl] = r_log2(x) for the input real array, x, returns an array of 
% real numbers, y, congruent with the Ruby hardware implementation. Each
% element of y is in a 32-bit fixed point representation with 1 sign, 
% 15 integer, and 16 fractional bits. The optional output, y_dbl is the 
% double precision result from the Matlab log2(x) function.  
% x - Real array.
% y - Real array of base 2 logarithms in Ruby representation. 
% y_dbl - Optional real array of base 2 logarithms in double precision
% representation. 

persistent y_log m_log M Q
if isempty(y_log)
    % Base 2 Log Table
    % Table Size 2^M
    M=5;
    % Number of bits for each entry in the table
    Q=16;
    % y-intercept & slope tables; even exponent
    x1=1:2^(-M):2-2^(-M);
    e=log2(x1+2^(-M-1))-interp1([x1 2],[log2(x1) 1],x1+2^(-M-1));
    e(1)=0;
    e(2:end)=e(2:end)+0.42e-4;
    y=log2(x1)+e/2;
    y_log=round(y*2^Q);
    m_log=round(diff([y 1])*2^Q);
end

% Exponent of the input
exp_x = floor(log2(x));
% Mantissa of the input
man_x = x./(2.^exp_x);

% Integer portion of the output
int_y = exp_x;

% Fractional portion of the output
x_rnd=floor((man_x-1)*2^(Q+1))/2^(Q+1);
frac_y = (2^(Q-M)*y_log(1+floor(x_rnd*2^M))+m_log(1+floor(x_rnd*2^M)).*floor(mod(x_rnd*2^Q,2^(Q-M))))/2^(2*Q-M);
frac_y = floor(frac_y*2^Q)/2^Q;

y = int_y+frac_y;
y_dbl = log2(x);

















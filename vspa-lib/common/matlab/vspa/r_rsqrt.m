% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [y,y_dbl] = r_rsqrt(x,prc_in)

% r_rsqrt: Ruby Reciprocal Square Root.
% [y,y_dbl] = r_rsqrt(x,prc) for the input real array, x, returns an array
% of real numbers, y, congruent with the Ruby hardware implementation. The 
% precision of the calculation is set using the optional input, prc. The 
% optional output, y_dbl is the double precision result from the Matlab 
% 1./sqrt(x) function.
% x - Real array.
% prc - 'hi' = high precision, if present. 
% y - Real array of reciprocal-sqrt(x) in Ruby representation.
% y_dbl - Optional real array of double precision, 1./sqrt(x).

x=double(x);

if nargin == 1
        prc_in = 'lo';
end

persistent y_rsqrt m_rsqrt M Q prc
if isempty(prc)
    prc='lo';
end
if (isempty(y_rsqrt) | (prc_in~=prc))
    prc = prc_in;
    % Reciprocal Square root Table
    if prc == 'hi'
        % Table Size 2^M
        M=9;
        % Number of bits for each entry in the table
        Q=25;
    else
        % Table Size 2^M
        M=5;
        % Number of bits for each entry in the table
        Q=16;
    end
    % y-intercept & slope tables; even exponent
    x1=1:2^(-M):2-2^(-M);
    e=2./sqrt(x1+2^(-M-1))-interp1([x1 2],[2./sqrt(x1) sqrt(2)],x1+2^(-M-1));
    y=2./sqrt(x1)+e/2;
    y_rsqrt=round((y-1)*2^Q);
    m_rsqrt=round(diff([y sqrt(2)])*2^Q);
end

column=0;
if size(x,2)==1
    x=x';
    column=1;
end

% Handling of zero, INF, NAN
if prc_in =='lo'
    i_inf = abs(x)>realmax('single');
    x(i_inf) = 1;
    i_sub = abs(x)<realmin('single');
    x(i_sub) = 0;
else
    i_inf = isinf(x);
    x(i_inf) = 1;
    i_sub = abs(x)<realmin('double');
    x(i_sub) = 0;
end
i_zero = x==0;
x(i_zero) = 1;
i_nan = isnan(x);
x(i_nan) = 1;

% Handling of negative numbers
i_neg = x<0;
x(i_neg) = -x(i_neg);

% Exponent & Mantissa of the input
[man_x, exp_x] = log2(x);
man_x = 2*man_x;
exp_x=exp_x-1;

% Indices of even exponents
i = (exp_x/2==floor(exp_x/2));

% Exponent of the output
exp_y = exp_x;
% Even exponent case
exp_y(i) = -exp_x(i)/2-1;
% Odd exponent case
exp_y(~i) = -(exp_x(~i)+1)/2;

% Output mantissa
man_y = man_x;
x_rnd=floor((man_x-1)*2^(Q+1))/2^(Q+1);
% Even exponent case
man_y = (2^(Q-M)*y_rsqrt(1+floor(x_rnd*2^M))+m_rsqrt(1+floor(x_rnd*2^M)).*floor(mod(x_rnd*2^Q,2^(Q-M))))/2^(2*Q-M);
man_y = 1 + floor(man_y*2^(Q+2))/2^(Q+2);
% Odd exponent case
man_y(~i) = max(floor(round((sqrt(2)/2)*2^Q)*man_y(~i)*2^(Q+1)/2^Q)/2^(Q+1),1.0);

if (man_y>=2)
    error('Mantissa >=2'), 
end

y = man_y.*(2.^(exp_y));

% Handling of zero, INF, & NAN
if prc_in =='lo'
    y(i_zero) = 2^128;
    y(y>realmax('single'))=2^128;
else
    y(i_zero) = inf;
end
y(i_nan) = 0;
y(i_inf) = 0;

if column==1
    y=y';
    x=x';
end

if nargout == 2
    y_dbl = 1./sqrt(x);
end















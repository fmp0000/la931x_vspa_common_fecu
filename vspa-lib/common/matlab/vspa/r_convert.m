% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ out ] = r_convert( in, prec, str )
% 
% DESCRIPTION:
%   Converts an input buffer in Matlab double precision into an output
%   buffer with given VSPA precision.
%
% INPUT:
%   in  : input matrix of numbers in double precision
%   prec: output precision with the following 
%             - 'half_fixed': 16 bit fixed point
%             - 'half'      : 16 bit floating point
%             - 'single'    : 32 bit floating point 
%             - 'double'    : 64 bit floating point
% 
%   str: string to denominate buffer name for error string output, default 
%        is 'buffer'
%
% OUTPUT:
%   out: output matrix with given VSPA precision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ out ] = r_convert( in, prec, str )

% Default buffer name
if (nargin < 3)
    str = 'buffer';
end

% Perform conversion
if strcmp(prec, 'half_fixed')
    r_half_validate(in, sprintf('VSPA Half Fixed saturation occurred for %s!', str));
    out = r_half(in);
elseif strcmp(prec, 'half')
    out = r_half_flt(in);
elseif strcmp(prec, 'single')
    out = r_single(in);
elseif strcmp(prec, 'double')
    out = r_double(in);
else
    error('Precision invalid!');
end

end


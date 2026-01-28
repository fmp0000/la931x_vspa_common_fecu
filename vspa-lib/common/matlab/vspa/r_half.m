% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function Y = r_half(X)
% 
% DESCRIPTION:
%   Rounds an input double precision number to half precision fixed point
%   representation format (Ruby)
% 
% INPUT:
%   X: input matrix of numbers in double format
% 
% OUTPUT:
%   Y: output matrix of fixed point half precision "rounded" numbers in
%   double format (matrix dimensions same as input matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y = r_half(X)

Y = r_round(X, 0);
return;

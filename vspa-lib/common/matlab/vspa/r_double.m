% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function Y = r_double(X)
% 
% DESCRIPTION:
%   Rounds an input double precision number to ruby double precision 
%   representation format
% 
% INPUT:
%   X: input matrix of numbers in double format
% 
% OUTPUT:
%   Y: output matrix of single precision "rounded" numbers in
%   double format (matrix dimensions same as input matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y = r_double(X)

Y = r_round(X, 3);
return;

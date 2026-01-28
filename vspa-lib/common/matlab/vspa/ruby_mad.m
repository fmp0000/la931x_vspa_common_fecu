% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y = ruby_mad(x1, x2, x3, Mi, E, Aext, sn_on)
%
% DESCRIPTION:
%   Matrix multiply and add
%   y = x1*x2 + x3
%   where x1, x2, x3 are [MxN], [NxK], [MxK] matrices. x3 can be a scalar
% 
% INPUTS:
%   x1: input matrix x1 of dimensions [MxN]
%   x2: input matrix x2 of dimensions [NxK]
%   x3: input matrix x3 of dimensions [MxK]. Can be a scalar.
%   Mi: number of implicit mantissa bits in precision format
%   E: number of exponent bits in precision format
%   Aext: number of additional accumulator bits (including impllicit bit)
%   sn_on (OPTIONAL): 0=>sub-normalization OFF; 1=>sub-normalization ON [DEFAULT]
%
% OUTPUTS:
%   y: output matrix of dimensions [MxK]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = ruby_mad(x1, x2, x3, Mi, E, Aext, sn_on) 

%% config
if ~exist('sn_on', 'var')
    sn_on = 1;
end

%% input checks
% check and adjust dimensions
szx1 = size(x1);
szx2 = size(x2);
szx3 = size(x3);

if (numel(szx1) ~= 2) || (numel(szx2) ~= 2) || (numel(szx3) ~= 2)
    error('All inputs must be 2 dimensional');
end
M = szx1(1);
K = szx2(2);

if szx1(2) ~= szx2(1)
    error('Matrix dimension mismatch between inputs x1 and x2');
end
N = szx1(2);

if ~((szx3(1) == M) && (szx3(2) == K))
    if ~((szx3(1) == 1) && (szx3(2) == 1))
        error('x3 must either be MxK or scalar');
    else
        x3 = ones(M, K).*x3;
    end
end

y = zeros(M, K);
for ii = 1:M
    for jj = 1:K
        y(ii, jj) = ruby_mac(x1(ii, :).', x2(:, jj), x3(ii, jj), Mi, E, Aext, sn_on);
    end
end

return;

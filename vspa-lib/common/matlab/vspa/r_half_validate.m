% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright This - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function r_half_validate( X, error_msg )
% 
% DESCRIPTION:
%   Validates that an input matrix has all elements in the range (-1,1).
%   This should be used before conversion to fix point to assure that no
%   saturation will occur.
% INPUT:
%   X: input matrix of numbers in floating point format
%   error_msg: error message to display in case saturation will occur
% OUTPUT:
%   none
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r_half_validate( X, error_msg )

if isempty(X)
    return
end

HF16_MAX = 1 - 2^(-15);
HF16_MIN = -HF16_MAX;

max_val = max([real(X(:)); imag(X(:))]);
min_val = min([real(X(:)); imag(X(:))]);

if (max_val > HF16_MAX) || (min_val < HF16_MIN)
    error(error_msg);
end

end


% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [size] = precSize(precType)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [size] = precSize(precType)
% 
% DESCRIPTION:
% Returns the size of a precision type (in 16bit Half Words).
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(precType, 'uint')
    size = 2;
elseif strcmp(precType, 'half_fixed')
    size = 1;
elseif strcmp(precType, 'half')
    size = 1;
elseif strcmp(precType, 'single')
    size = 2;
elseif strcmp(precType, 'double')
    size = 4;
else
    error('Precision type invalid!');
end

end


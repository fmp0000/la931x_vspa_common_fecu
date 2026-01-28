% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [size] = vspaExportReal(in, prec, filePath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [size] = vspExportReal(in, prec, filePath)
%
% DESCRIPTION:
% 
% INPUTS:
%   in       - input real buffer
%   prec     - export precision ('uint','half_fixed', 'half','single','double')
%   filePath - full name of output file to export
%
% OUTPUTS:
%   exportSize - output size in Half Words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameter validation
elem_size = precSize(prec);

% Convert precision
sizeHW = length(in(:)) * elem_size;   % Size (in Half Words)
sizeFW = ceil(sizeHW / 2);            % Size (in Full Words)
dmemIn = dmemCreate(0, sizeFW);
dmemIn = dmemWriteReal(dmemIn, 0, in(:), prec);

% Export
fid = fopen(filePath, 'w');
fwrite(fid, uint32(dmemIn.data), 'uint32');
fclose(fid);

% Output size (in HalfWords)
size = sizeHW;

end


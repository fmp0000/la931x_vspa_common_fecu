% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function out = mat2vspa(in,precision)

switch precision
    case 'uint'
        out = uint32(inputVec);
        
    case 'half_fixed'
        out = r_dbl2cust(in,0);
        
    case 'half'
        out = r_dbl2cust(in,1);
        
    case 'single'
        out = typecast(single(r_single(in)) , 'uint32');

    case 'double'
        out = typecast(r_double(in),'uint32');
        
    otherwise
        error('unrecognized precision');
end

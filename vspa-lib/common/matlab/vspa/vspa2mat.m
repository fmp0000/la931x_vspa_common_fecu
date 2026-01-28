% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function out = vspa2mat(in,precision)

in1 = double(in);

switch precision
    case 'uint'
        out = in1;
        
    case 'half_fixed'
        rep32 = in1;
        rep16 = zeros(2,1);
        loHalfWordMask = hex2dec('ffff');
        rep16(1) = bitand( rep32, loHalfWordMask );
        rep16(2) = floor(rep32/2^16);
        
        out = r_cust2dbl(uint64(rep16), 0);

    case 'half'
        rep32 = dmemIn.data( startIndex:endIndex );
        rep16 = zeros(2,1);
        loHalfWordMask = hex2dec('ffff');
        rep16(1) = bitand( rep32, loHalfWordMask );
        rep16(2) = floor(rep32/2^16);
        
        out = r_cust2dbl(uint64(rep16), 1);
        
    case 'single'
        rep = in1;
        s = bitand( rep, hex2dec('80000000')) /2^31;
        m = bitand( rep, hex2dec('007fffff')) /2^23;
        e = bitand( rep, hex2dec('7f800000')) /2^23;
        out = ( ( s >  0 ) * ( -1 - m ) * 2^(e-127) + ...
                      ( s == 0 ) * (  1 + m ) * 2^(e-127) );
        out = ( ~and( and(m==0, s==0), e==0) ) * out;  % handle zero exception 
    case 'double'
        out = typecast(uint32( in1 ),'double');
        
    otherwise
        error('unrecognized precision');
end

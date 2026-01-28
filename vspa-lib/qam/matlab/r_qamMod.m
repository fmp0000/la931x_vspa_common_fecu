% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function  y_bx= r_qamMod(bitsIn,M,normalization)
%
% DESCRIPTION:
%   This function provides the bit-exact function for QAM modulation
%
% INPUTS:
%   bitsIn: input bit stream
%   M: qam modulation order: 1: BPSK, 2: QPSK, 4: 16-QAM 6: 64-QAM, ...
%   normalization: a scalar to normalize the energy of constellation points
%
% OUTPUTS:
%   y_bx: Output of modulated QAM symbol, same size as of the input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y_bx= r_qamMod(bitsIn,M,normalization)


bits=reshape(bitsIn,M,[]);

if M>1
    bitsI=bits(1:M/2,:);
    bitsQ=bits((M/2+1):M,:);
    symbI=2.^[0:(M/2-1)]*bitsI;
    symbQ=2.^[0:(M/2-1)]*bitsQ;
else
    symbI=bits;
end
    
switch (M)
    case 1
        mapTable=[-1 1];
    case 2
        mapTable=[-1 1];
    case 4
        mapTable=[-3 3 -1 1];
    case 6
        mapTable=[-7 7 -1 1 -5 5 -3 3];
    case 8
        mapTable=[-15 15 -1 1 -9 9 -7 7 -13 13 -3 3 -11 11 -5 5];
    case 10
        mapTable=[-31 31 -1 1 -17 17 -15 15 -25 25 -7 7 -23 23 -9 ...
                 9 -29 29 -3 3 -19 19 -13 13 -27 27 -5 5 -21 21 -11 11];
end

if M>1
    sym=complex(mapTable(symbI+1),mapTable(symbQ+1));
else
    sym=mapTable(symbI+1);
end

y_bx=r_half_flt(r_smad(sym,r_single(normalization),0));


end

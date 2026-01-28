% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y_bx= r_qamDemodV4(qamIn,M,snr)
%
% DESCRIPTION:
%   This function takes input QAM symbols, calculates the llrs with the
%   scaling of SNR, and quantize the llr value to 8-bit 2's compliment number
%   as the output
%
% INPUTS:
%   qamIn: input vector of qam symbols
%   M:     qam modulation order: 1: BPSK, 2: QPSK, 4: 16-QAM 6: 64-QAM, ...
%   snr:   snr vector of same size as qamIn
%
% OUTPUTS:
%   y_bx:  Output vector of llrs in HFixed format
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y_bx= r_qamDemodV4(qamIn,M,snr)

qamIn=reshape(qamIn,1,[]);
snr=reshape(snr,1,[]);

if length(qamIn)~=length(snr)
    error('input vectors must have the same length')
end

scaling = 1/128;

snr1=r_half_flt(r_smad(r_half_flt(snr), r_single(scaling)*ones(size(snr)), zeros(size(snr))));
llrs=zeros(length(qamIn)*M,1);
    
switch (M)
    case 2
        llrs=reshape(llrs,[],64);
        qamIn=r_half_flt(qamIn);
        b0=r_half(r_smad(real(qamIn), snr1, zeros(size(snr1))));
        b1=r_half(r_smad(imag(qamIn), snr1, zeros(size(snr1))));
        llrs=zeros(1,2*length(qamIn));
		llrs(1:2:end)=b0;
		llrs(2:2:end)=b1;        
end

y_bx=llrs;

end

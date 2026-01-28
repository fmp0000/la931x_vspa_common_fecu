% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y_bx= r_qamDemodv2(qamIn,M,snr)
%
% DESCRIPTION:
%   This function takes input QAM symbols, calculates the llrs with the
%   scaling of SNR, and quantize the llr value to 8-bit 2's compliment number
%   as the output
%
% INPUTS:
%   qamIn: input vector of qam symbols
%   M:     qam modulation order: 1: BPSK, 2: QPSK, 4: 16-QAM 6: 64-QAM, ...
%   snr:   snr scalar in linear order
%
% OUTPUTS:
%   y_bx:  Output vector of llrs, each of which is a 8-bit  in decimal format.
%   For example, if the output llr bits are 0b10011010, the output will be 154
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y_bx= r_qamDemodV2(qamIn,M,snr)

qamIn=reshape(qamIn,[],1);
snr1=r_single(r_single(snr)/16);
llrs=zeros(length(qamIn)*M,1);
    
switch (M)
    case 8
        Normalization=1/sqrt(170);
        K1=r_single(r_single(Normalization*8));
        K1=r_smad(K1, snr1, 0);
        K2=K1/2;
        K3=K1/4;
        llrs=reshape(llrs,[],64);
        N=size(llrs,1);
        
        qamIn=r_half_flt(qamIn);
        a1=r_smad(reshape(real(qamIn),32,[])',snr1*ones(N/4,32),zeros(N/4,32));
        a2=r_smad(reshape(imag(qamIn),32,[])',snr1*ones(N/4,32),zeros(N/4,32));
        a=zeros(N/4,64);
        a(:,1:2:end)=a1;
        a(:,2:2:end)=a2;
        llrs(1:4:end,:)=r_half(a);
        
        a=r_smad(-abs(r_half_flt(a)),ones(N/4,64),K1);
        llrs(2:4:end,:)=r_half(a);
        
        a=r_smad(-abs(r_half_flt(a)),ones(N/4,64),K2);
        llrs(3:4:end,:)=r_half(a);
        
        a=r_smad(-abs(r_half_flt(a)),ones(N/4,64),K3);
        llrs(4:4:end,:)=r_half(a);
end

llr_16bits=r_dbl2cust(llrs,0);
sign_bit=bitget(llr_16bits,16);
bits=bitand(llr_16bits,2^15-1);
y_bx=bitget(bits,8)+bitshift(bits,-8);

y_bx(sign_bit==1)=bitxor(y_bx(sign_bit==1),127)+1+2^7;
y_bx(bitshift(llr_16bits,-8)==127)=127;
y_bx(bitshift(llr_16bits,-8)==255)=129;
y_bx(y_bx==256)=0;
y_bx=reshape(y_bx',[],1);

end

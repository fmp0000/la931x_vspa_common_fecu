% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y_bx= r_qamDemod(qamIn,M,snr)
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

function y_bx= r_qamDemod(qamIn,M,snr)

qamIn=reshape(qamIn,[],1);
snr1=r_single(r_single(snr)/16);
llrs=zeros(length(qamIn)*M,1);
    
switch (M)
    case 1
        llrs=real(qamIn);
    case 2
        llrs(1:2:end)=real(qamIn);
        llrs(2:2:end)=imag(qamIn);
    case 4
        Normalization=1/sqrt(10);
        K=r_single(r_single(Normalization*2));
        llrs=reshape(llrs,[],64);
        llrs(1:2:end,1:2:end)=r_half_flt(reshape(real(qamIn),32,[])');
        llrs(1:2:end,2:2:end)=r_half_flt(reshape(imag(qamIn),32,[])');
        llrs(2:2:end,:)=r_half_flt(r_smad(-abs(llrs(1:2:end,:)),ones(size(llrs(2:2:end,:))),K));
    case 6
        Normalization=1/sqrt(42);
        K1=r_single(r_single(Normalization*4));
        K2=r_single(r_single(Normalization*2));
        llrs=reshape(llrs,[],64);
        llrs(1:3:end,1:2:end)=r_half_flt(reshape(real(qamIn),32,[])');
        llrs(1:3:end,2:2:end)=r_half_flt(reshape(imag(qamIn),32,[])');
        llrs(2:3:end,:)=r_half_flt(r_smad(-abs(llrs(1:3:end,:)),ones(size(llrs(2:3:end,:))),K1));
        llrs(3:3:end,:)=r_half_flt(r_smad(-abs(llrs(2:3:end,:)),ones(size(llrs(2:3:end,:))),K2));
    case 8
        Normalization=1/sqrt(170);
        K1=r_single(r_single(Normalization*8));
        K2=r_single(r_single(Normalization*4));
        K3=r_single(r_single(Normalization*2));
        llrs=reshape(llrs,[],64);
        llrs(1:4:end,1:2:end)=r_half_flt(reshape(real(qamIn),32,[])');
        llrs(1:4:end,2:2:end)=r_half_flt(reshape(imag(qamIn),32,[])');
        llrs(2:4:end,:)=r_half_flt(r_smad(-abs(llrs(1:4:end,:)),ones(size(llrs(2:4:end,:))),K1));
        llrs(3:4:end,:)=r_half_flt(r_smad(-abs(llrs(2:4:end,:)),ones(size(llrs(2:4:end,:))),K2));
        llrs(4:4:end,:)=r_half_flt(r_smad(-abs(llrs(3:4:end,:)),ones(size(llrs(2:4:end,:))),K3)); 
    case 10
        Normalization=1/sqrt(682);
        K1=r_single(r_single(Normalization*16));
        K2=r_single(r_single(Normalization*8));
        K3=r_single(r_single(Normalization*4));
        K4=r_single(r_single(Normalization*2));
        llrs=reshape(llrs,[],64);
        llrs(1:5:end,1:2:end)=r_half_flt(reshape(real(qamIn),32,[])');
        llrs(1:5:end,2:2:end)=r_half_flt(reshape(imag(qamIn),32,[])');
        llrs(2:5:end,:)=r_half_flt(r_smad(-abs(llrs(1:5:end,:)),ones(size(llrs(2:5:end,:))),K1));
        llrs(3:5:end,:)=r_half_flt(r_smad(-abs(llrs(2:5:end,:)),ones(size(llrs(2:5:end,:))),K2));
        llrs(4:5:end,:)=r_half_flt(r_smad(-abs(llrs(3:5:end,:)),ones(size(llrs(2:5:end,:))),K3));
        llrs(5:5:end,:)=r_half_flt(r_smad(-abs(llrs(4:5:end,:)),ones(size(llrs(4:5:end,:))),K4));
end

llrs=r_half(r_smad(r_half_flt(llrs), snr1, 0));

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

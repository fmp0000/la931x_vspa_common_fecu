% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y_bx= r_qamDemodV5(qamIn,M,snr)
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

function y_bx= r_qamDemodV5(qamIn,M,snr)

qamIn=reshape(qamIn,1,[]);
snr=reshape(snr,1,[]);
if length(qamIn)~=length(snr)
    error('input vectors must have the same length')
end

scaling = 1/16;
snr_vsp=r_half_flt(snr);
    
switch (M)
    case 1
        qamIn=r_half_flt(qamIn);
        b0=r_half_flt(r_smad(real(qamIn), snr_vsp, zeros(size(snr_vsp))));
        llrs=b0;
     
    case 2
        qamIn=r_half_flt(qamIn);
        b0=r_half_flt(r_smad(real(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b1=r_half_flt(r_smad(imag(qamIn), snr_vsp, zeros(size(snr_vsp))));
        
        llrs=zeros(1,2*length(qamIn));
        llrs(1:2:end)=b0;
        llrs(2:2:end)=b1;

        
    case 4
        K1=r_half_flt(2/sqrt(10));
        
        qamIn=r_half_flt(qamIn);
        b0=r_half_flt(r_smad(real(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b2=r_half_flt(r_smad(imag(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b1=r_half_flt(r_smad(K1*ones(size(snr_vsp)), snr_vsp, -abs(b0)));
        b3=r_half_flt(r_smad(K1*ones(size(snr_vsp)), snr_vsp, -abs(b2)));
        
        llrs=zeros(1,4*length(qamIn));
        llrs(1:4:end)=b0;
        llrs(2:4:end)=b2;
        llrs(3:4:end)=b1;
        llrs(4:4:end)=b3;
        
    case 6
        K1=r_half_flt(4/sqrt(42));
        K2=r_half_flt(2/sqrt(42));
        
        qamIn=r_half_flt(qamIn);
        b0=r_half_flt(r_smad(real(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b3=r_half_flt(r_smad(imag(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b1=r_half_flt(r_smad(K1*ones(size(snr_vsp)), snr_vsp, -abs(b0)));
        b4=r_half_flt(r_smad(K1*ones(size(snr_vsp)), snr_vsp, -abs(b3)));
        b2=r_half_flt(r_smad(K2*ones(size(snr_vsp)), snr_vsp, -abs(b1)));
        b5=r_half_flt(r_smad(K2*ones(size(snr_vsp)), snr_vsp, -abs(b4)));
        
        llrs=zeros(1,6*length(qamIn));
        llrs(1:6:end)=b0;
        llrs(2:6:end)=b3;
        llrs(3:6:end)=b1;
        llrs(4:6:end)=b4;
        llrs(5:6:end)=b2;
        llrs(6:6:end)=b5;
        
    case 8
        K1=r_half_flt(8/sqrt(170));
        K2=r_half_flt(4/sqrt(170));
        K3=r_half_flt(2/sqrt(170));
        
        qamIn=r_half_flt(qamIn);
        b0=r_half_flt(r_smad(real(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b4=r_half_flt(r_smad(imag(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b1=r_half_flt(r_smad(K1*ones(size(snr_vsp)), snr_vsp, -abs(b0)));
        b5=r_half_flt(r_smad(K1*ones(size(snr_vsp)), snr_vsp, -abs(b4)));
        b2=r_half_flt(r_smad(K2*ones(size(snr_vsp)), snr_vsp, -abs(b1)));
        b6=r_half_flt(r_smad(K2*ones(size(snr_vsp)), snr_vsp, -abs(b5)));
        b3=r_half_flt(r_smad(K3*ones(size(snr_vsp)), snr_vsp, -abs(b2)));
        b7=r_half_flt(r_smad(K3*ones(size(snr_vsp)), snr_vsp, -abs(b6)));
        
        llrs=zeros(1,8*length(qamIn));
        llrs(1:8:end)=b0;
        llrs(2:8:end)=b4;
        llrs(3:8:end)=b1;
        llrs(4:8:end)=b5;
        llrs(5:8:end)=b2;
        llrs(6:8:end)=b6;
        llrs(7:8:end)=b3;
        llrs(8:8:end)=b7;
     
    case 10
        K1=r_half_flt(16/sqrt(682));
        K2=r_half_flt(8/sqrt(682));
        K3=r_half_flt(4/sqrt(682));
        K4=r_half_flt(2/sqrt(682));
        
        qamIn=r_half_flt(qamIn);
        b0=r_half_flt(r_smad(real(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b5=r_half_flt(r_smad(imag(qamIn), snr_vsp, zeros(size(snr_vsp))));
        b1=r_half_flt(r_smad(K1*ones(size(snr_vsp)), snr_vsp, -abs(b0)));
        b6=r_half_flt(r_smad(K1*ones(size(snr_vsp)), snr_vsp, -abs(b5)));
        b2=r_half_flt(r_smad(K2*ones(size(snr_vsp)), snr_vsp, -abs(b1)));
        b7=r_half_flt(r_smad(K2*ones(size(snr_vsp)), snr_vsp, -abs(b6)));
        b3=r_half_flt(r_smad(K3*ones(size(snr_vsp)), snr_vsp, -abs(b2)));
        b8=r_half_flt(r_smad(K3*ones(size(snr_vsp)), snr_vsp, -abs(b7)));
        b4=r_half_flt(r_smad(K4*ones(size(snr_vsp)), snr_vsp, -abs(b3)));
        b9=r_half_flt(r_smad(K4*ones(size(snr_vsp)), snr_vsp, -abs(b8)));
        
        llrs=zeros(1,10*length(qamIn));
        llrs(1:10:end)=b0;
        llrs(2:10:end)=b5;
        llrs(3:10:end)=b1;
        llrs(4:10:end)=b6;
        llrs(5:10:end)=b2;
        llrs(6:10:end)=b7;
        llrs(7:10:end)=b3;
        llrs(8:10:end)=b8;
        llrs(9:10:end)=b4;
        llrs(10:10:end)=b9;
end

llrs=r_half_flt(r_smad(scaling*ones(size(llrs)), llrs, zeros(size(llrs))));
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

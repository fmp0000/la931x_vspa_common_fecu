% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y_bx= r_qamDemodv3(qamIn,M,snr,SignInv)
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
%   SignInv: Boolean flag indicating whether a sign inversion of LLRs is needed
%            SignInv = 1: Sign Inversion (LTE/5G std)
%            SignInv = 0: No sign Inversion (WiFi std)
%
% OUTPUTS:
%   y_bx:  Output vector of llrs, each of which is a 8-bit  in decimal format.
%   For example, if the output llr bits are 0b10011010, the output will be 154
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y_bx_reordered, y_bx] = r_qamDemodV3(qamIn,M,snr,SignInv)

qamIn = reshape(qamIn,1,[]);
snr = reshape(snr,1,[]);

if length(qamIn)~=length(snr)
    error('input vectors must have the same length')
end

if SignInv
    scaling = 1/128;
else
    scaling = -1/16;
end

snr1 = r_half_flt(r_smad(r_half_flt(snr), r_single(scaling)*ones(size(snr)), zeros(size(snr))));
llrs = zeros(length(qamIn)*M, 1);
llrs_reordered = zeros(length(qamIn)*M, 1);
    
switch (M)
    case 8
        K1=r_half_flt(8/sqrt(170));
        K2=r_half_flt(4/sqrt(170));
        K3=r_half_flt(2/sqrt(170));
        llrs = reshape(llrs,[],64);
       
        qamIn=r_half_flt(qamIn);
        b0=r_smad(real(qamIn), snr1, zeros(size(snr1)));
        b4=r_smad(imag(qamIn), snr1, zeros(size(snr1)));
        if ~SignInv
            b1= r_smac([K1*ones(size(snr1)); abs(r_half_flt(b0))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b5= r_smac([K1*ones(size(snr1)); abs(r_half_flt(b4))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b2= r_smac([K2*ones(size(snr1)); abs(r_half_flt(b1))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b6= r_smac([K2*ones(size(snr1)); abs(r_half_flt(b5))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b3= r_smac([K3*ones(size(snr1)); abs(r_half_flt(b2))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b7= r_smac([K3*ones(size(snr1)); abs(r_half_flt(b6))], [snr1; ones(size(snr1))],zeros(size(snr1)));
        else
            b1= r_smac([K1*ones(size(snr1)); -abs(r_half_flt(b0))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b5= r_smac([K1*ones(size(snr1)); -abs(r_half_flt(b4))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b2= r_smac([K2*ones(size(snr1)); -abs(r_half_flt(b1))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b6= r_smac([K2*ones(size(snr1)); -abs(r_half_flt(b5))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b3= r_smac([K3*ones(size(snr1)); -abs(r_half_flt(b2))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b7= r_smac([K3*ones(size(snr1)); -abs(r_half_flt(b6))], [snr1; ones(size(snr1))],zeros(size(snr1)));
        end
        
        llrs(1:4:end,1:2:end)=reshape(b0,32,[]).';
        llrs(2:4:end,1:2:end)=reshape(b1,32,[]).'; 
        llrs(3:4:end,1:2:end)=reshape(b2,32,[]).';
        llrs(4:4:end,1:2:end)=reshape(b3,32,[]).'; 
        llrs(1:4:end,2:2:end)=reshape(b4,32,[]).';
        llrs(2:4:end,2:2:end)=reshape(b5,32,[]).'; 
        llrs(3:4:end,2:2:end)=reshape(b6,32,[]).';
        llrs(4:4:end,2:2:end)=reshape(b7,32,[]).'; 
        
        llrs_reordered(1:8:end) = reshape(b0, [], 1);
        llrs_reordered(2:8:end) = reshape(b4, [], 1);
        llrs_reordered(3:8:end) = reshape(b1, [], 1);
        llrs_reordered(4:8:end) = reshape(b5, [], 1);
        llrs_reordered(5:8:end) = reshape(b2, [], 1);
        llrs_reordered(6:8:end) = reshape(b6, [], 1);
        llrs_reordered(7:8:end) = reshape(b3, [], 1);
        llrs_reordered(8:8:end) = reshape(b7, [], 1);
    
    case 6
        K1=r_half_flt(4/sqrt(42));
        K2=r_half_flt(2/sqrt(42));
        llrs=reshape(llrs,[],64);
        
        qamIn=r_half_flt(qamIn);
        b0=r_smad(real(qamIn), snr1, zeros(size(snr1)));
        b3=r_smad(imag(qamIn), snr1, zeros(size(snr1)));
        if ~SignInv
            b1= r_smac([K1*ones(size(snr1)); abs(r_half_flt(b0))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b4= r_smac([K1*ones(size(snr1)); abs(r_half_flt(b3))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b2= r_smac([K2*ones(size(snr1)); abs(r_half_flt(b1))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b5= r_smac([K2*ones(size(snr1)); abs(r_half_flt(b4))], [snr1; ones(size(snr1))],zeros(size(snr1)));
        else
            b1= r_smac([K1*ones(size(snr1)); -abs(r_half_flt(b0))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b4= r_smac([K1*ones(size(snr1)); -abs(r_half_flt(b3))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b2= r_smac([K2*ones(size(snr1)); -abs(r_half_flt(b1))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b5= r_smac([K2*ones(size(snr1)); -abs(r_half_flt(b4))], [snr1; ones(size(snr1))],zeros(size(snr1)));
        end
        llrs(1:3:end,1:2:end)=reshape(b0,32,[]).';
        llrs(2:3:end,1:2:end)=reshape(b1,32,[]).'; 
        llrs(3:3:end,1:2:end)=reshape(b2,32,[]).';
        llrs(1:3:end,2:2:end)=reshape(b3,32,[]).'; 
        llrs(2:3:end,2:2:end)=reshape(b4,32,[]).';
        llrs(3:3:end,2:2:end)=reshape(b5,32,[]).'; 
        
        llrs_reordered(1:6:end) = reshape(b0, [], 1);
        llrs_reordered(2:6:end) = reshape(b3, [], 1);
        llrs_reordered(3:6:end) = reshape(b1, [], 1);
        llrs_reordered(4:6:end) = reshape(b4, [], 1);
        llrs_reordered(5:6:end) = reshape(b2, [], 1);
        llrs_reordered(6:6:end) = reshape(b5, [], 1);
        
    case 4
        K1=r_half_flt(2/sqrt(10));
        llrs=reshape(llrs,[],64);
        qamIn=r_half_flt(qamIn);
        b0=r_smad(real(qamIn), snr1, zeros(size(snr1)));
        b2=r_smad(imag(qamIn), snr1, zeros(size(snr1)));
        if ~SignInv
            b1= r_smac([K1*ones(size(snr1)); abs(r_half_flt(b0))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b3= r_smac([K1*ones(size(snr1)); abs(r_half_flt(b2))], [snr1; ones(size(snr1))],zeros(size(snr1)));
        else
            b1= r_smac([K1*ones(size(snr1)); -abs(r_half_flt(b0))], [snr1; ones(size(snr1))],zeros(size(snr1)));
            b3= r_smac([K1*ones(size(snr1)); -abs(r_half_flt(b2))], [snr1; ones(size(snr1))],zeros(size(snr1)));
        end
        llrs(1:2:end,1:2:end)=reshape(b0,32,[]).';
        llrs(2:2:end,1:2:end)=reshape(b1,32,[]).'; 
        llrs(1:2:end,2:2:end)=reshape(b2,32,[]).';
        llrs(2:2:end,2:2:end)=reshape(b3,32,[]).'; 
        
        llrs_reordered(1:4:end) = reshape(b0, [], 1);
        llrs_reordered(2:4:end) = reshape(b2, [], 1);
        llrs_reordered(3:4:end) = reshape(b1, [], 1);
        llrs_reordered(4:4:end) = reshape(b3, [], 1);
        
    case 2
        llrs=reshape(llrs,[],64);
        qamIn=r_half_flt(qamIn);
        b0=r_smad(real(qamIn), snr1, zeros(size(snr1)));
        b1=r_smad(imag(qamIn), snr1, zeros(size(snr1)));
        llrs(:,1:2:end)=reshape(b0,32,[]).';
        llrs(:,2:2:end)=reshape(b1,32,[]).'; 
        
        llrs_reordered = llrs;
        
    case 1
        qamIn = r_half_flt(qamIn);
        b0 = r_smad(real(qamIn), snr1, zeros(size(snr1)));
        llrs = reshape(b0,32,[]).';
        
        llrs_reordered = llrs;
end

%% format LLRs
llr_16bits = r_dbl2cust(llrs, 0);
sign_bit = bitget(llr_16bits, 16);
bits = bitand(llr_16bits, 2^15-1);
y_bx = bitget(bits, 8) + bitshift(bits, -8);

y_bx(sign_bit==1) = bitxor(y_bx(sign_bit==1), 127) + 1 + 2^7;
y_bx(bitshift(llr_16bits, -8)==127) = 127;
y_bx(bitshift(llr_16bits, -8)==255) = 129;
y_bx(y_bx==256) = 0;
y_bx = reshape(y_bx', [], 1);

%% format reordered LLRs
llr_16bits = r_dbl2cust(llrs_reordered,0);
sign_bit = bitget(llr_16bits, 16);
bits = bitand(llr_16bits, 2^15-1);
y_bx_reordered = bitget(bits, 8) + bitshift(bits, -8);

y_bx_reordered(sign_bit==1) = bitxor(y_bx_reordered(sign_bit==1), 127) + 1 + 2^7;
y_bx_reordered(bitshift(llr_16bits, -8)==127) = 127;
y_bx_reordered(bitshift(llr_16bits, -8)==255) = 129;
y_bx_reordered(y_bx_reordered==256) = 0;
y_bx_reordered = reshape(y_bx_reordered', [], 1);


end

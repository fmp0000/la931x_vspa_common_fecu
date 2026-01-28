% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
pkg load signal
addpath('.\lib')
%%addpath('DNGNR\5g_l1sp_ker\common\matlab\vspa')

%% test FIR filter
close all;
clear all;
clf;

%%Config
N = 2048*20;
M = 8192;
L = 8;
prec = 'half_fixed' ;
mode = 'real' ;
type = 0 ;
in_offset = 9 ;

fs=122880000  %% sampling clock
fc=20000000   %% frec cut off 20Mhz
wc=fc/(fs/2); %% freq cut normalized vs max freq.

%% generate test vectors

% -- Function File: B = fir1 (N, W)
%     Produce an order N FIR filter with the given frequency cutoff W,
%     returning the N+1 filter coefficients in B.  
	 
if strcmp(mode,'real')
	h=fir1(L-1,wc);
else
  h=complex(0.5*fir1(L-1,wc),0.5*fir1(L-1,1-wc));
end

% diplay taps
stem(h);

% -- [H, W] = freqz (B)
%    Return the complex frequency response H of the rational IIR filter
%    whose numerator and denominator coefficients are B and A respectively.
%    The response is evaluated at N angular frequencies between 0 and  2*pi.
%    If N is omitted, a value of 512 is assumed.
figure;
freqz (h,1,2^12,fs);

[H, f] = freqz (h,1,2^12,fs);
figure;
plot ( f/1000000, abs(H));
xlabel('Frequency (MHz)');
ylabel('Frequency Response');
box off;grid on;axis tight;

% implement this filter using bitexact VSPA model
% and generate random input vector and output vector (ref and bitexact)
figure;
x = 1/2*complex(1-2*rand(N,1), 1-2*rand(N,1));
plot ( x, ";random input complex;");
box off;grid on;axis tight;


%% taps, data, and precision
% y_mat reference output from matlab, use to assess effect of quantization error
% y_vsp is bit exact output vector
[y_vsp, y_mat, dbg_s]=r_firFilter(h,x,prec);

% [spectra,freq] = 		pwelch(x,window,overlap,Nfft,Fs,range,plot_type,detrend,sloppy)
% [spectra,Pxx_ci,freq] = 	pwelch(x,window,overlap,Nfft,Fs,conf,range,plot_type,detrend,sloppy)
% [PxxV,FxxV]=pwelch(y_vsp,blackman(2048),round(0.4*2048),2048,122.88e6,'centered','power');
% [PxxM,FxxM]=pwelch(y_mat,blackman(2048),round(0.4*2048),2048,122.88e6,'centered','power');
[PxxV,FxxV]=pwelch(y_vsp,hanning(2048),0.5,2048,122.88e6,'half','plot','none','sloppy');
[PxxM,FxxM]=pwelch(y_vsp,hanning(2048),0.5,2048,122.88e6,'half','plot','none','sloppy');

figure;
plot(FxxV*1e-6,10*log10(PxxV),'r',FxxM*1e-6,10*log10(PxxM),'b');
legend('VSP bit exact response','MATLAB native response');
grid on; box off;grid on;axis tight;

%figure;
%plot(1:N-L+1, real(y_mat),'b*-',1:N-L+1,real(y_vsp),'rc-');
%grid on;
%

%% quantization noise ratio
qns=10*log10(mean(abs(y_vsp-y_mat).^2)/mean(abs(y_mat).^2));
fprintf('QNS for FIR filter output = %.2f dB\n',qns);
%

%%create test_vectors

% export input vector
drInVec=dmemCreate(0,128);
if strcmp(mode,'real')
	if mod(L,2)==0
		drInVec=dmemWriteReal(drInVec,0,dbg_s.h,prec);
	else	
		drInVec=dmemWriteReal(drInVec,0,[dbg_s.h 0],prec);
	end
else
	drInVec=dmemWriteComplex(drInVec,0,dbg_s.h,prec);
end
filename=sprintf('../test_vectors/firFilter_input_h.hex');
dmemSaveHexFile(drInVec,filename);
clear drInVec;

% export config in
drInVec=dmemCreate(0,4);
drInVec=dmemWriteReal(drInVec,0,[M L type in_offset], 'uint');
filename=sprintf("../test_vectors/firFilter_input_config.hex");
dmemSaveHexFile(drInVec,filename);
clear drInVec;

% config in compplex
drInVec=dmemCreate(0,64+M);
drInVec=dmemWriteComplex(drInVec,in_offset,dbg_s.x(1:M+L-1),prec);
filename=sprintf("../test_vectors/firFilter_input_x.hex");
dmemSaveHexFile(drInVec,filename);
clear drInVec;

% config output compplex
drOutVec=dmemCreate(0,M);
drOutVec=dmemWriteComplex(drOutVec,0,y_vsp(1:M),prec);
filename=sprintf("../test_vectors/firFilter_output_y_ref.hex");
dmemSaveHexFile(drOutVec,filename);
clear drOutVec;
%

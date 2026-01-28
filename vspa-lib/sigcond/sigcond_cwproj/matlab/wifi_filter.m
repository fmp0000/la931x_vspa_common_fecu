% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% Adjacent channel spec = 16 dB for MCS0. Assume SNR=3dB for MCS0.
% Adjacent channel filter rejection = 16+3 ~ 20dB minimum. 

df=100e3;
Fs=160e6;

% Analog filter rejection
[B,A]=butter(5,0.625*80e6*2*pi,'s');
Wa=2*pi*[0:df:0.5*Fs-df];
Ha = freqs(B,A,Wa);
Ipass = 39e6/df;
Istop1 = 41e6/df;
Istop2 = (0.5*Fs-df)/df;
Pstop = sum(abs(Ha(Istop1:Istop2)).^2);
Ppass = sum(abs(Ha(1:Ipass)).^2);
Ra=10*log10(0.5*Pstop/Ppass);

h=firpm(5,[0 39 65 80]/80,[1 1 0 0],[1 10]);

[Hd,Wd] = freqz(h,1,0.5*Fs/df);
Pstop = sum(abs(Hd(Istop1:end)).^2);
Ppass = sum(abs(Hd(1:Ipass)).^2);
Rd=10*log10(0.5*Pstop/Ppass);

Hc=transpose(Ha).*Hd;
Rc=Ra+Rd;

% Plot results
% Passband
figure(1)
plot(0.5*Wd(1:Ipass+1)*Fs/pi/1e6,20*log10(abs(Hd(1:Ipass+1))),'r')
xlabel('Frequency(MHz)')
ylabel('Magnitude Response (dB)')
grid on
hold on
plot(0.5*Wa(1:Ipass+1)/pi/1e6,20*log10(abs(Ha(1:Ipass+1))),'b')

plot(0.5*Wa(1:Ipass+1)/pi/1e6,20*log10(abs(Hc(1:Ipass+1))),'k')
hold off

% Stopband
figure(2)
plot(0.5*Wd*Fs/pi/1e6,20*log10(abs(Hd)),'r')
xlabel('Frequency(MHz)')
ylabel('Magnitude Response (dB)')
grid on
hold on
plot(0.5*Wa/pi/1e6,20*log10(abs(Ha)),'b')
Hc=transpose(Ha).*Hd;
plot(0.5*Wa/pi/1e6,20*log10(abs(Hc)),'k')
legend('Digital Response','Analog Response','Composite Response')
title(['Adjacent Channel Rejection = ' num2str(Rc) 'dB'])
hold off




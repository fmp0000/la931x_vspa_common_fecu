% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors

clear;

%% config
fracdel_numerator = 1;
upR = 10;
N = 100;
q_lag = 1;              % whether q lags i or vice versa. q_lag = 1 => q lags i

alpha = 1;
psi = 0;
%

frac_delay = fracdel_numerator/upR;
N_hr = N*upR;
padding = 1000;

frac_offset = 1/upR;
% x_hr = exp(-sqrt(-1)*2*pi*(0:N_hr+padding-1)'/500);
x_hr = complex(rand(N_hr+padding*2, 1) - 0.5, rand(N_hr+padding*2, 1) - 0.5);
h_lpf = fir1(32, 0.05);
x_hr = filter(h_lpf, 1, x_hr);
x_hr = x_hr(32+(1:N_hr+padding));

x_hr = x_hr/rms(x_hr)*10^(-12/20);
x_hr = complex(real(x_hr), real(x_hr));

%% ideal signal
x = resample(x_hr, 1, upR);

%% impaired signal
% introduce sub-sample lag
if q_lag == 0
    frac_offs = -frac_delay;
    x_ss_i = resample(real(x_hr(fracdel_numerator+1:end)), 1, upR);
    x_ss_q = resample(imag(x_hr), 1, upR);
    
    frac_n0 = fracdel_numerator/upR;
else
    frac_offs = frac_delay;
    x_ss_i = resample(real(x_hr), 1, upR);
    x_ss_q = resample(imag(x_hr(fracdel_numerator+1:end)), 1, upR);
    
    frac_n0 = (upR-fracdel_numerator)/upR;
end

x = r_half(x(10+(1:N+32)));
x_ss = complex(x_ss_i, x_ss_q);
x_ss = r_half(x_ss(10+(1:N+32)));

% apply I/Q impairment
x_imp_i = alpha*real(x_ss);
x_imp_q = sin(psi)*real(x_ss) + cos(psi)*imag(x_ss);
x_imp = complex(x_imp_i, x_imp_q);

figure(1);
if q_lag == 0
    plot(frac_offs + (0:N-1), imag(x(1:N)), 'r*-', (0:N-1), real(x_imp(1:N)), 'bo-'); 
else
    plot((0:N-1), real(x(1:N)), 'r*-', frac_offs + (0:N-1), imag(x_imp(1:N)), 'bo-'); 
end
legend('ideal', 'impaired');
grid on;

%% compensation for impairments
% calculate imbalance coefficients
f1 = 1/alpha;
f2 = -tan(psi)/alpha;
f4 = sec(psi);

% calculate fractional delay filter
n = (-2+frac_n0:1:2+frac_n0);
B = 0.5;
fsT = 2*(1-B);
h = sinc(n/fsT).*cos(pi*B*n/fsT)./(1-(2*B*n/fsT).^2);
h_ssf = h/sum(h);

h_ssf = f4*h_ssf;

len_ssfilt = length(h_ssf);
if q_lag == 0
    ssfilt_delay = floor((len_ssfilt-1)/2);
else
    ssfilt_delay = floor((len_ssfilt-1)/2) - 1;
end

% compensate delay & imbalance
temp_i = [zeros(len_ssfilt-1, 1); real(x_imp)];
temp_q = [zeros(len_ssfilt-1, 1); imag(x_imp)];
x_corr_i = r_half(r_smad(r_single(f1), temp_i(len_ssfilt - 1 - ssfilt_delay + (1:N)), 0));
x_corr_q = r_smad(r_single(f2), temp_i(len_ssfilt - 1 - ssfilt_delay + (1:N)), 0);
for ii = 1:len_ssfilt
    x_corr_q = r_smad(r_single(h_ssf(len_ssfilt - ii + 1)), temp_q(ii - 1 + (1:N)), x_corr_q);
end
x_corr_q = r_half(x_corr_q);

x_corr = complex(x_corr_i, x_corr_q);

% extract
M = N - 16;
x = x(10 + (1:M));
x_imp = x_imp(10 + (1:M));
x_corr = x_corr(10 + ssfilt_delay+(1:M));
[x x_imp x_corr]

figure(2);
plot((0:M-1), real(x_corr), 'r*-', (0:M-1), imag(x_corr), 'bo-'); 
legend('ideal', 'corrected');
grid on;

evm = 10*log10(mean(abs(real(x_corr)).^2)/mean(abs(real(x_corr) - imag(x_corr)).^2));
fprintf('SQNR = %.2fdB\n', evm);


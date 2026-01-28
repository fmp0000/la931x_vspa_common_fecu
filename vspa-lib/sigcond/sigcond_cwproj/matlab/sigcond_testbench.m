% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function sigcond_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname)
% custom  front end processing chain 
% DESCRIPTION:
%   Generates test vectors for signal conditioning processing chain
% 
% INPUTS:
%   BW: Bandwidth of output signal. One of {160, 80, 40, 20}
%   N: Number of input samples per batch
%   n_batches: Number of batches
%   freq: Center frequency of carrier
%   fegain: Front end complex gain 
%   dcoff: DC offset
%   n_iqsstaps: Number of fractional delay filter taps for I/Q Imb Comp
%   testname: Name of test
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sigcond_testbench(BW, N, n_batches, freq, fegain, dcoff, n_iqsstaps, testname)

%% config
opmode = 0;                                     % 0=>regular, 1=>debug
fn_type = 1;
Fs = 160;                                       % sampling frequency in MHz
L1 = 6;                                         % number of taps for first stage of decimation
L2 = 8;                                         % number of taps for second stage of decimation
L3 = 12;                                        % number of taps for third stage of decimation

frac_delay = -0.2;                               % fraction delay of q branch wrt i branch
alpha = 0.9;
psi = 0.1;

% frac_delay = 0;
% alpha = 1;
% psi = 0;
%

%% generate inputs
% generate input waveform
n_samples_in1 = N*n_batches;

% x = exp(-sqrt(-1)*2*pi*(0:n_samples_in1-1)'*0.2/Fs);
x = complex(rand(n_samples_in1, 1), rand(n_samples_in1, 1));
x = x/rms(x)*10^(-12/20) + dcoff;
x_vsp = r_half(x);

% generate decimator taps
% h1_dbl = fir1(L1-1, 150/160).';
h1taps_struct = load('h1_opt_dbl');
h1_dbl = h1taps_struct.h1_dbl/sum(h1taps_struct.h1_dbl);
h2_dbl = fir1(L2-1, 20/80).';
h3_dbl = fir1(L3-1, 20/40).';

h1_vsp = r_half(h1_dbl);
h2_vsp = r_half(h2_dbl);
h3_vsp = r_half(h3_dbl);

% generate mixer and gain parameters
normfreq = -freq/(Fs/2);
normfreq = round(normfreq*2^32)/2^32;
normphase = 0;

% generate I/Q imbalance taps
% calculate 
f1 = 1/alpha;
f2 = -tan(psi)/alpha;
f4 = sec(psi);

if n_iqsstaps == 4
    iqimb_ssdelayfilt = fir1(3, 150/160).';
else
    if frac_delay == 0
        h = [0 0 1 0 0];
    else
        if frac_delay < 0
            frac_n0 = 1 - abs(frac_delay);
        else
            frac_n0 = frac_delay;
        end
        n = (-2+frac_n0:1:2+frac_n0);
        B = 0.5;
        fsT = 2*(1-B);
        h = sinc(n/fsT).*cos(pi*B*n/fsT)./(1-(2*B*n/fsT).^2);
    end
    iqimb_ssdelayfilt = h/sum(h);
end

len_ssfilt = length(iqimb_ssdelayfilt);     
del_ssfilt = floor((len_ssfilt-1)/2);            % delay of SS delay filter

iqimb_f1 = f1;
iqimb_ssdelayfilt = f4*iqimb_ssdelayfilt;
iqimb_f2 = f2;
if frac_delay <= 0
    iqimb_intdelay = del_ssfilt;
else
    iqimb_intdelay = del_ssfilt - 1;
end

%% generate bit-exact results
filt_taps = struct('h1', h1_dbl, 'h2', h2_dbl, 'h3', h3_dbl);

% generate normalized frequency and round to 2^32 representation
sigcondcfg_struct = struct('normfreq', normfreq, 'normphase', normphase, 'fegain', fegain, 'dcoff', dcoff, ...
                            'iqimb_ssdelayfilt', iqimb_ssdelayfilt, 'iqimb_f1', iqimb_f1, 'iqimb_f2', iqimb_f2, 'iqimb_intdelay', iqimb_intdelay);

if BW == 160
    x_input = x_vsp;
else
    x_input = [zeros(L1-1, 1); x_vsp; zeros(32-L1+1, 1)];
end

if opmode == 1
    [temp, tempmat, opstruct] = r_customsigcond(x_input, BW, filt_taps, sigcondcfg_struct);
else
    [temp, tempmat, ~] = r_customsigcond(x_input, BW, filt_taps, sigcondcfg_struct);
end

switch (BW)
   case 160
        n_samples_out = n_samples_in1;
        Nout = N;
        
    case 80
        n_samples_out = n_samples_in1/2;
        Nout = N/2;
        
    case 40
        n_samples_out = n_samples_in1/4;
        Nout = N/4;
        
    case 20
        n_samples_out = n_samples_in1/8;
        Nout = N/8;
        
    otherwise
        error('Specified BW not supported');
end
M = Nout;
y_out = temp(1:n_samples_out, 1);
y_out_mat = tempmat(1:n_samples_out, 1);
sqnr = 10*log10(mean(abs(y_out_mat).^2)/mean(abs(y_out_mat-y_out).^2));
fprintf('SQNR for sigcond = %.2f dB\n', sqnr);

%% generate CW test vectors
for jj = 1:n_batches
    drCW = dmemCreate(0, N);
    drCW = dmemWriteComplex(drCW, 0, x_vsp((jj-1)*N + (1:N)), 'half_fixed');
    dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_x_batch%d.hex', testname, jj));
    clear drCW;
end

% order filter taps
ph0_taps = h1_vsp(2:2:end);
ph1_taps = h1_vsp(1:2:end);
ph0_taps = ph0_taps(L1/2:-1:1);
ph1_taps = ph1_taps(L1/2:-1:1);
ord_filttaps_stage1 = reshape([ph0_taps.'; ph1_taps.'], [], 1);

ph0_taps = h2_vsp(2:2:end);
ph1_taps = h2_vsp(1:2:end);
ph0_taps = ph0_taps(L2/2:-1:1);
ph1_taps = ph1_taps(L2/2:-1:1);
ord_filttaps_stage2 = reshape([ph0_taps.'; ph1_taps.'], [], 1);

ph0_taps = h3_vsp(2:2:end);
ph1_taps = h3_vsp(1:2:end);
ph0_taps = ph0_taps(L3/2:-1:1);
ph1_taps = ph1_taps(L3/2:-1:1);
ord_filttaps_stage3 = reshape([ph0_taps.'; ph1_taps.'], [], 1);

filt_taps_dmemvec = [ord_filttaps_stage1; ord_filttaps_stage2; ord_filttaps_stage3];
drCW = dmemCreate(0, length(filt_taps_dmemvec)/2);
drCW = dmemWriteReal(drCW, 0, filt_taps_dmemvec, 'half_fixed');
dmemSaveHexFile(drCW, sprintf('../test_vectors/input_filtertaps.hex'));
clear drCW;

if opmode == 1 
    M = 128;
    for jj = 1:n_batches
        drCW = dmemCreate(0, M);
        drCW = dmemWriteComplex(drCW, 0, opstruct.y_stage2a((jj-1)*M + (1:M)), 'half_fixed');
        dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_output_y_batch%d_ref.hex', testname, jj));
        clear drCW;
    end
else
    for jj = 1:n_batches
        drCW = dmemCreate(0, Nout);
        drCW = dmemWriteComplex(drCW, 0, y_out((jj-1)*Nout + (1:Nout)), 'half_fixed');
        dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_output_y_batch%d_ref.hex', testname, jj));
        clear drCW;
    end
end

drCW = dmemCreate(0, 4);
drCW = dmemWriteReal(drCW, 0, [N; BW; n_batches; fn_type], 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_config.hex', testname));
clear drCW;

% set input structure
nco_freq = (normfreq >= 0).*round(normfreq*2^32) + (normfreq < 0).*(2^32 + round(normfreq*2^32));
nco_phase = normphase;
drCW = dmemCreate(0, 116);
drCW = dmemWriteComplex(drCW, 97, r_single([fegain; -dcoff]), 'single');
drCW = dmemWriteReal(drCW, 101, [nco_freq; nco_phase], 'uint');

len_iqtaps = length(iqimb_ssdelayfilt);
itaps_vec = zeros(1, len_iqtaps);
itaps_vec(iqimb_intdelay+1) = iqimb_f1;
iqtaps_vector = [itaps_vec(end:-1:1); reshape(iqimb_ssdelayfilt(end:-1:1), 1, [])];
iqtaps_vector = r_single([0; iqimb_f2; reshape(iqtaps_vector, [], 1)]);
drCW = dmemWriteReal(drCW, 103, iqtaps_vector, 'single');
drCW = dmemWriteReal(drCW, 115, 64-iqimb_intdelay*2-1, 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/%s_input_sigcondstruct.hex', testname));
clear drCW;

% create sizing tcl file
fpt = fopen('../scripts/szconfig.tcl', 'wt');
fprintf(fpt, 'set n_batches %d\n', n_batches);
fprintf(fpt, 'set input_offset_word %d\n', N);
fprintf(fpt, 'set output_size_word %d\n', M);
fprintf(fpt, 'set output_offset_word %d\n', ceil(M/32)*32);
fprintf(fpt, 'set opmode %d\n', opmode);
fclose(fpt);


return;





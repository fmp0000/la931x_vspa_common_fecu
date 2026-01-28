% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [y_out_vsp, y_out_mat, opstruct]  = r_customsigcond2(x, bw, decim_taps, ipstruct)
% 
% DESCRIPTION:
%   Custom signal conditioning chain for 160Msps input signal defined in
%   doc/customsigcond_function_description.docx 
%
% INPUTS:
%   x: Vector of complex input samples. In half fixed precision.
%
%   bw: Bandwidth of output signal. One of {160, 80, 40, 20}
% 
%   decim_taps: Structure containing DDC taps for 3 stages with following
%   fields
%       h1: Taps for first stage of 2x decimation
%       h2: Taps for second stage of 2x decimation
%       h3: Taps for third stage of 2x decimation
% 
%   ipstruct: Configuration structure with following fields
%       normfreq: Normalized frequency for mixer stage
%       normphase: Starting phase for mixer stage
%       fegain: Front end complex gain
%       dcoff: DC offset
%       iqimb_ssdelayfilt: Filter taps for fractional delay compensation in
%       the I/Q imbalance correction stage
%       iqimb_f1: Factor "f1" for I/Q imbalance compensation stage
%       iqimb_f2: Factor "f2" for I/Q imbalance compensation stage
%       iqimb_intdelay: Integer delay for I/Q imabalance stage
% 
% OUTPUTS:
%   y_out_vsp: Vector of complex output samples (in VSPA half fixed precision). 
%   y_out_mat: Vector of complex output samples (in MATLAB double precision). 
% 
%   opstruct: Struct containing intermediate and rounded inputs with the
%   following fields
%       y_stage1: Output of DC offset and gain stage
%       y_stage2: Output of 1st DDC stage (only for BW 80, 40, 20}
%       y_stage2a: Output of mixer stage (only for BW 80, 40, 20}
%       y_stage3: Output of 2nd DDC stage (only for BW 40, 20}
%       y_stage4: Output of 3rd DDC stage (only for BW 20}
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y_out_vsp, y_out_mat, opstruct]  = r_customsigcond2(x, bw, decim_taps, ipstruct)

% extract inputs
normfreq = ipstruct.normfreq;
normphase = ipstruct.normphase;
fegain = ipstruct.fegain;
dcoff = ipstruct.dcoff;
iqimb_ssdelayfilt = ipstruct.iqimb_ssdelayfilt;
iqimb_f1 = ipstruct.iqimb_f1;
iqimb_f2 = ipstruct.iqimb_f2;
iqimb_intdelay = ipstruct.iqimb_intdelay;

n_samples_in = length(x);
switch (bw)
    case 160
        n_samples_out = n_samples_in;
        n_samples_in2 = n_samples_in;
    case 80
        n_samples_out = floor(n_samples_in/2);
        n_samples_in2 = n_samples_out*2;
        n_samples_in3 = n_samples_out;
    case 40
        n_samples_out = floor(n_samples_in/4);
        n_samples_in2 = n_samples_out*4;
        n_samples_in3 = n_samples_out*2;
        n_samples_in4 = n_samples_out;
    case 20
        n_samples_out = floor(n_samples_in/8);
        n_samples_in2 = n_samples_out*8;
        n_samples_in3 = n_samples_out*4;
        n_samples_in4 = n_samples_out*2;
    otherwise
        error('Specified BW not supported');
end
x_vsp = r_half(x);

h1_dbl = decim_taps.h1;
h2_dbl = decim_taps.h2;
h3_dbl = decim_taps.h3;
h1_vsp = r_half(h1_dbl);
h2_vsp = r_half(h2_dbl);
h3_vsp = r_half(h3_dbl);

opstruct = struct('y_stage1', [], 'y_stage2', [], 'y_stage3', [], 'y_stage3a', [], 'y_stage4', []);

%% Stage 1: IQ imbalance compensation stage
n_ssfilter_taps = length(iqimb_ssdelayfilt);

% MATLAB implementation
temp = [x; zeros(32, 1)];
y_out_real = iqimb_f1*real(temp(n_ssfilter_taps - 1 - iqimb_intdelay + (1:n_samples_in2)));
y_out_imag = iqimb_f2*real(temp(n_ssfilter_taps - 1 - iqimb_intdelay + (1:n_samples_in2)));
for ii = 1:n_ssfilter_taps
    y_out_imag = y_out_imag + iqimb_ssdelayfilt(n_ssfilter_taps - ii + 1)*imag(temp(ii - 1 + (1:n_samples_in2)));
end
y_stage1_mat = complex(y_out_real, y_out_imag);

% VSPA implementation
temp = [x_vsp; zeros(32, 1)];
y_out_real = r_half(r_smad(r_single(iqimb_f1), real(temp(n_ssfilter_taps - 1 - iqimb_intdelay + (1:n_samples_in2))), 0));
y_out_imag = r_smad(r_single(iqimb_f2), real(temp(n_ssfilter_taps - 1 - iqimb_intdelay + (1:n_samples_in2))), 0);
for ii = 1:n_ssfilter_taps
    y_out_imag = r_smad(r_single(iqimb_ssdelayfilt(n_ssfilter_taps - ii + 1)), imag(temp(ii - 1 + (1:n_samples_in2))), y_out_imag);
end
y_out_imag = r_half(y_out_imag);
y_stage1_vsp = complex(y_out_real, y_out_imag);
opstruct.y_stage1 = y_stage1_vsp;

%% Stage 2: DC offset and gain stage
% MATLAB implementation
y_stage2_mat = fegain*y_stage1_mat - dcoff;

% VSPA implementation
y_stage2_vsp = r_half(r_smad(r_single(fegain), y_stage1_vsp, -r_single(dcoff)));
opstruct.y_stage2 = y_stage2_vsp;

if (bw == 160)
    y_lastddcstage_mat = y_stage2_mat;
    y_lastddcstage_vsp = y_stage2_vsp;
end

%% Stage 3: Decimate and mix
if (bw <= 80)
    % first decimation stage: MATLAB implementation
    [~, temp] = r_decim2x([zeros(32, 1); y_stage2_mat], h1_dbl);
    y_stage3_mat = temp(1:n_samples_in3);
        
    % first decimation stage: VSPA implementation
    temp = r_decim2x([zeros(32, 1); y_stage2_vsp], h1_vsp);
    y_stage3_vsp = temp(1:n_samples_in3);
    opstruct.y_stage3 = y_stage3_vsp;

    % mixer stage: MATLAB implementation
    ncoSeq = exp(-sqrt(-1)*2*pi*(normphase + (0:n_samples_in3-1))*normfreq).';
    y_stage3a_mat = y_stage3_mat.*ncoSeq;
        
    % mixer stage: VSPA implementation
    ncoSeq = r_nco(normfreq, n_samples_in3, normphase).';
    y_stage3a_vsp = r_half(r_smad(y_stage3_vsp, ncoSeq, 0));
    opstruct.y_stage3a = y_stage3a_vsp;
    
    y_lastddcstage_mat = y_stage3a_mat;
    y_lastddcstage_vsp = y_stage3a_vsp;
end

% Stage 4: Decimate
if (bw <= 40)
    % second decimation stage: MATLAB implementation
    [~, temp] = r_decim2x([zeros(32, 1); y_stage3a_mat(1:n_samples_in3-1)], h2_dbl);
    y_stage4_mat = temp(1:n_samples_in4);
    
    % second decimation stage: VSPA implementation
    temp = r_decim2x([zeros(32, 1); y_stage3a_vsp(1:n_samples_in3-1)], h2_vsp);
    y_stage4_vsp = temp(1:n_samples_in4);
    opstruct.y_stage4 = y_stage4_vsp;
    
    y_lastddcstage_mat = y_stage4_mat;
    y_lastddcstage_vsp = y_stage4_vsp;
end

% Stage 5: Decimate
if (bw == 20)
    % third decimation stage: MATLAB implementation
    [~, temp] = r_decim2x([zeros(32, 1); y_stage4_mat(1:n_samples_in4-1)], h3_dbl);
    y_stage5_mat = temp(1:n_samples_out);
    
    % third decimation stage: VSPA implementation
    temp = r_decim2x([zeros(32, 1); y_stage4_vsp(1:n_samples_in4-1)], h3_vsp);
    y_stage5_vsp = temp(1:n_samples_out);
    
    y_lastddcstage_mat = y_stage5_mat;
    y_lastddcstage_vsp = y_stage5_vsp;
end

y_out_mat = y_lastddcstage_mat;
y_out_vsp = y_lastddcstage_vsp;

return;


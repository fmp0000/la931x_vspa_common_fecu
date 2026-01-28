% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function  [y_vsp, y_mat] = r_txiqcomp2(x_vsp, x_mat, txiqcomp_struct)
% 
% DESCRIPTION:
%   TX IQ compensation chain including IQ compensation and DC offset compensation.
%
% INPUTS:
%   x_vsp: Vector of complex input samples (in VSPA half fixed precision). 
%
%	x_mat: Vector of complex input samples (in MATLAB double precision
% 
%   txiqcomp_struct: Configuration structure with following fields
%       gain:              Real gain to be applied for IQ imbalance taps
%       dcoff:             DC offset
%       iqimb_ssdelayfilt: Filter taps for fractional delay compensation in
%                          the I/Q imbalance correction stage
%       iqimb_f1:          Factor "f1" for I/Q imbalance compensation stage
%       iqimb_f2:          Factor "f2" for I/Q imbalance compensation stage
%       iqimb_intdelay:    Integer delay for I/Q imabalance stage
% 
% OUTPUTS:
%   y_vsp: Vector of complex output samples (in VSPA half fixed precision). 
%   y_mat: Vector of complex output samples (in MATLAB double precision). 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [y_vsp, y_mat] = r_txiqcomp2(x_vsp, x_mat, txiqcomp_struct)

% Params
gain              = txiqcomp_struct.gain;
dcoff             = txiqcomp_struct.dcoff;
iqimb_ssdelayfilt = txiqcomp_struct.iqimb_ssdelayfilt;
iqimb_f1          = txiqcomp_struct.iqimb_f1;
iqimb_f2          = txiqcomp_struct.iqimb_f2;
iqimb_intdelay    = txiqcomp_struct.iqimb_intdelay;

num_samples = length(x_vsp);
num_taps    = length(iqimb_ssdelayfilt);

% MATLAB implementation
x_mat = x_mat .* gain;  % Apply gain
temp = [zeros(num_taps-1,1); x_mat];
y_out_real = iqimb_f1 * real(temp(num_taps - 1 - iqimb_intdelay + (1:num_samples))) + real(dcoff);
y_out_imag = iqimb_f2 * real(temp(num_taps - 1 - iqimb_intdelay + (1:num_samples))) + imag(dcoff);
for ii = 1 : num_taps
    y_out_imag = y_out_imag + iqimb_ssdelayfilt(num_taps - ii + 1) * imag(temp(ii - 1 + (1:num_samples)));
end
y_mat = complex(y_out_real, y_out_imag);

% VSPA implementation
iqimb_ssdelayfilt = r_smad(gain, iqimb_ssdelayfilt, 0); % Apply gain
iqimb_f1          = r_smad(gain, iqimb_f1, 0);          % Apply gain
iqimb_f2          = r_smad(gain, iqimb_f2, 0);          % Apply gain
temp = [zeros(num_taps-1,1); x_vsp];
y_out_real = r_smad(r_single(iqimb_f1), real(temp(num_taps - 1 - iqimb_intdelay + (1:num_samples))), r_single(real(dcoff)));
y_out_imag = r_smad(r_single(iqimb_f2), real(temp(num_taps - 1 - iqimb_intdelay + (1:num_samples))), r_single(imag(dcoff)));
for ii = 1 : num_taps
    y_out_imag = r_smad(r_single(iqimb_ssdelayfilt(num_taps - ii + 1)), imag(temp(ii - 1 + (1:num_samples))), y_out_imag);
end
y_vsp = complex(y_out_real, y_out_imag);
y_vsp = r_half(y_vsp);

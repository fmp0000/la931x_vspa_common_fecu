% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2017 - 2025 the original authors
%**************************************************************************
% Scope:
% Test bench for generate nco phase ramp
%
%**************************************************************************
%
% Revision History:
%  - version 1.0 : 6 June 2017
%**************************************************************************



%% Test bench init
close all
clc
clear all

%% Paths to other folders
addpath('./../../../common/matlab/vspa')      %path to common functions

%% inputs
norm_freq = 0.0102;
initial_phase = -122;
g = 1.0;
size = 256;  %number of samples
%% double precision phase ramp generation 
v_full_precision =g * exp(-1j*2*pi*(initial_phase+(0:(size-1)).')*norm_freq);
%% bit-exact phase ramp generation
nco_freq_vsp = round((norm_freq)*2^32);
nco_freq_matlab = nco_freq_vsp/2^32;
initial_phase_int32 = int32(initial_phase);
nco_phase_vsp = typecast(initial_phase_int32, 'uint32');
nco_phase_matlab =double(nco_phase_vsp);        % ex: 4294967174 corresponds to phase=-122.
                                         % if phase is negative, the value will be 1's
                                         % complement of phase+1
v = r_nco(nco_freq_matlab, size, nco_phase_matlab).';
v = r_smad(v,g,0);
v_hfl=r_half_flt(v);

error=sum(abs(v_full_precision-v_hfl));

%% save input vector for VSPA
dram1 = dmemCreate( 0, length(v_hfl) );
dram1 = dmemWriteComplex( dram1, 0, v_hfl, 'half' );
dmemSaveHexFile(dram1, sprintf('../test_vectors/output_matlab.hex'));

dram1 = dmemCreate( 0, 1 );
dram1 = dmemWriteComplex( dram1, 0, g, 'single' );
dmemSaveHexFile(dram1, sprintf('../test_vectors/g.hex'));

dram1 = dmemCreate( 0, 1 );
dram1 = dmemWriteReal( dram1, 0, nco_phase_vsp, 'uint' );
dmemSaveHexFile(dram1, sprintf('../test_vectors/nco_phase.hex'));

dram1 = dmemCreate( 0, 1 );
dram1 = dmemWriteReal( dram1, 0, nco_freq_vsp, 'uint' );
dmemSaveHexFile(dram1, sprintf('../test_vectors/nco_freq.hex'));

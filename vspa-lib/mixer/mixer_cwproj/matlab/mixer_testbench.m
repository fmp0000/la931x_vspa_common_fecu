% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
addpath('..\..\..\common\matlab\vspa')

%% random seed, test_vector path
clear all;     % do not clear memory because r_nco.m could have built a persistent table in memory
close all;
rng('default'); rng(60);
path_test_vectors = '../test_vectors/';
[~,~,~]=mkdir(strrep([path_test_vectors],'/',filesep)); % test vector folder

%% set up
num_cHF_per_line    = 32;           % number of complex 16-bit half-fixed per DMEM line in 16AU
l_L_each_call       = 1:8;          % number of DMEM lines used by each mixer call
L           = sum(l_L_each_call);   % number of DMEM lines occupied by x. 36 lines = sum(1:8).
N           = L * num_cHF_per_line; % number of samples in x, in complex HFix16
l_ppm       = [-32 -16 16 64];      % some freq (esp. negative freq) will cause minor mismatch due to an NCO issue.
l_freqin    = ceil( l_ppm * 2^-20 * 2^32 / 2^24 * 2^32 );   % 2^-20~= 1e-6; 2^32 ~= 6.5GHz, 2^24 ~= 16.8MSPS; "*2^32" because NCO use freqin/2^32. 
l_phasein   = [ 2^32-[170 1 253 17 16 2] 0   ];             % 170 to trigger overflow when subtracting phaseOut with extra "rd S1"

% quick debug
 %l_freqin = 1/4 * 2^32;
 %l_freqin = [-1/2048 -1/2048 1/2048 1/2048]* 2^32;

%% same input for all tests
if 1
    x  = r_half(   complex(2*rand(N,1)-1,  2*rand(N,1)-1)  ); % test bench    
elseif 0
    x  = r_half(   complex((1:N).'/32768, (1:N).'/32768) ); % debug
else
    x  = r_half(   complex(ones(N,1), zeros(N,1)) ); % check NCO sequence
end

%% bit-exactness check
nFreq   = length(l_freqin);
nPhas   = length(l_phasein);
nCase   = nFreq * nPhas;
nLcall  = length(l_L_each_call);

% hex files for x, freqin, phasein
dram = dmemCreate(0,N);     dram = dmemWriteComplex( dram, 0, x, 'half_fixed' );   dmemSaveHexFile( dram, strrep( [path_test_vectors 'x_in.hex']  ,'/',filesep) );
l_freqin_write =l_freqin;
l_freqin_write(l_freqin<0) = bitcmp( abs(l_freqin(l_freqin<0)),'uint32'); % 1's complement for freqin
dram = dmemCreate(0,nFreq);     dram = dmemWriteReal( dram, 0, l_freqin_write, 'uint' );     dmemSaveHexFile( dram, strrep( [path_test_vectors 'freq_in.hex']  ,'/',filesep) );
dram = dmemCreate(0,nPhas);     dram = dmemWriteReal( dram, 0, l_phasein, 'uint' );          dmemSaveHexFile( dram, strrep( [path_test_vectors 'phas_in.hex']  ,'/',filesep) );

for iFreq=1:nFreq
for iPhase=1:nPhas
    freqin  = l_freqin(iFreq);
    phasein = l_phasein(iPhase);
    
    y_vsp = zeros(size(x));
    y_mat = zeros(size(x));
    phaseout_record = zeros(size(l_L_each_call));
    idx_beg = 1;
    for iL = 1 : nLcall
        idx = idx_beg + (0 : l_L_each_call(iL) * num_cHF_per_line -1);
        
        str_case = num2str([iFreq iPhase],'fIdx%d_pIdx%d_');
        
        % Please replace "-freqin" with "freqin" after NCO issue in compiler/simulator is fixed
        [y_vsp(idx), y_mat(idx), dbg] = r_mixer(x(idx), phasein, -freqin);
        phaseout_record(iL) = dbg.PhaseOut;
        phasein = dbg.PhaseOut;
        idx_beg = idx(end) + 1;
        
        % sanity check
        if 0 && nCase < 10
            figure;
            subplot(121); err=(y_mat  - y_vsp);     loglog(abs(real(err)),abs(imag(err)),'.'); title(num2str(N,'N=%d: y_{mat}-y_{vsp}')); xlabel('abs(real)'); ylabel('abs(imag)')
            subplot(122); err=(y_mat./y_vsp -1);    loglog(abs(real(err)),abs(imag(err)),'.'); title(num2str(N,'N=%d: y_{mat}./y_{vsp} -1')); xlabel('abs(real)'); ylabel('abs(imag)')            
        end
    end 
    
    %% save test vectors in hex
    disp(['  Saving outputs for ' str_case]);
    
    dram = dmemCreate(0,N);     dram = dmemWriteComplex( dram, 0, y_vsp, 'half_fixed' );    dmemSaveHexFile( dram, strrep( [path_test_vectors str_case 'y_BE.hex']  ,'/',filesep) );
    dram = dmemCreate(0,nLcall);dram = dmemWriteReal( dram, 0, phaseout_record, 'uint' );   dmemSaveHexFile( dram, strrep( [path_test_vectors str_case 'phaseout_BE.hex']  ,'/',filesep) );
end
end

disp(num2str(nCase,'%d cases generated'));

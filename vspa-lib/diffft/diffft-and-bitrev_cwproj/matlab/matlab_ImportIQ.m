% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% sim_dram_save "test_vectors/input_sav.hex" [evaluate #x input_buffer] 8320
% export 0x4600 16512bytes
% export 0x4340 16512bytes

clear all

fp = fopen("../test_vectors/input-3.bin");  
inputVec=fread(fp,(128+32)*2,'int16','l');

% 2's comp negative values 
signIN=(sign(inputVec));
negEntries=min(signIN,0);
PosEntries=max(signIN,0);
negEntriesAbsVal=negEntries.*inputVec;
cmp1=32767.*negEntries+negEntriesAbsVal;
R=PosEntries.*inputVec + cmp1;

A=R(1:2:end);
B=R(2:2:end);

% whatever other finalization you need to do
fclose(fp);
figure(2)
subplot(2,1,1)
plot(A);
subplot(2,1,2)
plot(B);

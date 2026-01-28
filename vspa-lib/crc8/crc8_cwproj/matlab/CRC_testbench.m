% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% bitwise_CRC8 calculates the CRC8 bitwise based on geneator
% polynomial 0x107 for input data stream
% inputs:
%%%%%%%%
% size              size of input data stream in bits
%                   =20, 21, 23, or 34
% data1             input data if size = 20 , 21 , or 23 
%                   most significant 32 bits of input bits if size = 34
% data2             zeros if size = 20 , 21 , or 23 
%                   least significant 2 bits of input bits if size = 34
% output:
%%%%%%%%%
% crc8              8 CRC bits corresponding to the input data stream
%% input configuration
addpath('./../../../common/matlab/vspa')      %path to common functions

size=34;
data1=[1 1 1 1 0 0 0 1 0 0 1 0 0 1 1 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0];
data2=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
%%
generator_polynomial = [0 0 0 0 0 1 1 1]; % CRC polynomial 0x107
if size==34
    data_temp=xor(data1,[ones(1,8) zeros(1,24)]);
    for ii = 1:-1:0
        data_temp = circshift(data_temp,-1,2);
        bit_out=data_temp(end);
        data_temp(end) = data2(end-ii);
        if bit_out == 1
            data_temp = xor(data_temp,[generator_polynomial zeros(1,24)]);
        end
    end
    for ii = 1:32
        data_temp = circshift(data_temp,-1,2);
        bit_out=data_temp(end);
        data_temp(end) = 0;
        if bit_out == 1
            data_temp = xor(data_temp,[generator_polynomial zeros(1,24)]);
        end
    end
    crc=xor(data_temp(1:8),ones(1,8));
     
elseif size==23
    data_temp=[data1(10:32) zeros(1,9)];
    data_temp=xor(data_temp,[ones(1,8) zeros(1,24)]);
    for ii = 1:23
        data_temp = circshift(data_temp,-1,2);
        bit_out=data_temp(end);
        data_temp(end) = 0;
        if bit_out == 1
            data_temp = xor(data_temp,[generator_polynomial zeros(1,24)]);
        end
    end
    crc=xor(data_temp(1:8),ones(1,8));
    
elseif size==21
    data_temp=[data1(12:32) zeros(1,11)];
    data_temp=xor(data_temp,[ones(1,8) zeros(1,24)]);
    for ii = 1:21
        data_temp = circshift(data_temp,-1,2);
        bit_out=data_temp(end);
        data_temp(end) = 0;
        if bit_out == 1
            data_temp = xor(data_temp,[generator_polynomial zeros(1,24)]);
        end
    end
    crc=xor(data_temp(1:8),ones(1,8));
    
elseif size==20
    data_temp=[data1(13:32) zeros(1,12)];
    data_temp=xor(data_temp,[ones(1,8) zeros(1,24)]);
    for ii = 1:20
        data_temp = circshift(data_temp,-1,2);
        bit_out=data_temp(end);
        data_temp(end) = 0;
        if bit_out == 1
            data_temp = xor(data_temp,[generator_polynomial zeros(1,24)]);
        end
    end
    crc=xor(data_temp(1:8),ones(1,8));
else
    msg = 'please enter a valid size';
    error(msg)
end



%% create cw data files
input_config = [size];
drCW = dmemCreate(0, 1);
drCW = dmemWriteReal(drCW, 0, input_config, 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/size.hex'));
clear drCW;

data1_new=data1;
if size ==34
    data1_new=fliplr(data1_new);
else
    data1_new=[zeros(1,32-size) fliplr(data1_new(end-size+1:end))];
end
data1_hex = bits2hex(data1_new);
data1_dec=hex2dec(data1_hex);
drCW = dmemCreate(0, 1);
drCW = dmemWriteReal(drCW, 0, data1_dec, 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/data1.hex'));
clear drCW;

data2_new=data2;
if size ==34
    data2_new=[zeros(1,30) fliplr(data2_new(end-1:end))];
end
data2_hex = bits2hex(data2_new);
data2_dec=hex2dec(data2_hex);
drCW = dmemCreate(0, 1);
drCW = dmemWriteReal(drCW, 0, data2_dec, 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/data2.hex'));
clear drCW;

crc_hex = bits2hex([zeros(1,24) fliplr(crc)]);
crc_dec=hex2dec(crc_hex);
drCW = dmemCreate(0, 1);
drCW = dmemWriteReal(drCW, 0, crc_dec, 'uint');
dmemSaveHexFile(drCW, sprintf('../test_vectors/crc_matlab.hex'));
clear drCW;

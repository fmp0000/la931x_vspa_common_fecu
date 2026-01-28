% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [ codeword ] = createHexCodeword( bitfields )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

numLeftShift = 0;
codewordValDec = 0;
currentLeftmostBit = 32;

% for each BITFIELD
for i = 1:numel( bitfields )  
   numLeftShift = currentLeftmostBit - bitfields(i).length ;
   currentLeftmostBit = numLeftShift;
   %  % it is decimal
   if isnumeric( bitfields(i).value ) 
       codewordValDec = codewordValDec + bitsll( bitfields(i).value, numLeftShift );             
   else  % it is hex
      codewordValDec = codewordValDec + bitsll(  hex2dec(bitfields(i).value), numLeftShift );
   end
end

%fprintf( 'hex = %s \n', dec2hex( codewordValDec ));
%fprintf( 'dec = %d \n', codewordValDec );
%fprintf( 'bin = %s \n', dec2bin( codewordValDec ));

codeword = dec2hex( codewordValDec );
end


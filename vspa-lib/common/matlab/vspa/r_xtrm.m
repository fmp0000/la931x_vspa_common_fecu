% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [value, index] = r_xtrm(x, type)
% 
% DESCRIPTION:
%   VSPA Comparator model function 
%   
% INPUTS:
%   x: N element input vector where N has to be in [2 4 8 16 32 64 128*I] for
%   integer I > 0. The inputs should be rounded to half precision using
%   r_half() to ensure accuracy with hardware
% 
%   type: 
%       'MAX': find signed maximum 
%       'MIN': find signed minimum
%       'ABS_MAX': find unsigned maximum
%       'ABS_MIN': find unsigned minimum
% 
% OUTPUTS:
%   value: extreme value
%   index: index corresponding to extreme value (zero based)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [value, index] = r_xtrm(x, type)

%% config
M = 128;
% 


%% input checks
if ~isvector(x)
    error('Input data must be a vector.');
end

if (size(x, 1) == 1)
    x = x.';
end

N = length(x);
maxL = log2(M)-1;
if (mod(N, M) ~= 0) && (~ismember(N, 2.^(1:maxL)))
    error('Length of input vector has to be either a power of 2 or a multiple of %d', M);
end

if N > M
    K = N/M;
    Ne = M;
else
    K = 1;
    Ne = N;
end

%% initializations
if strcmp(type, 'MAX')
    bnd_value = -1;
elseif strcmp(type, 'MIN')
    bnd_value = 1;
elseif strcmp(type, 'ABS_MAX')
    bnd_value = 0;
    x = abs(x);
elseif strcmp(type, 'ABS_MIN')
    bnd_value = 1;
    x = abs(x);
end
    
pg_ind_reg = zeros(M, 1);
pg_st = 0;

cmp_out = ones(M, 1)*bnd_value;

if Ne < M
    x_in = [x; zeros(M-Ne, 1)];
else
    x_in = x;
end

elem_ind_reg = (0:M/2-1)'*2;

pg_offset = 0;
el_start_bit = 1;
while (Ne > 1)
    if K > 0
        % PG mode
        A = cmp_out;
        B = x_in(pg_offset + (1:M));
        
        cmp_out = A;
        s = zeros(M, 1);
        if (strcmp(type, 'MAX') || strcmp(type, 'ABS_MAX'))
            winindex = (B > A);
        else
            winindex = (B < A);
        end
        cmp_out(winindex) = B(winindex);
        s(winindex) = 1;
        
        pg_ind_reg(s == 1) = pg_st;
        pg_st = pg_st + 1;
        
        K = K - 1;
        pg_offset = pg_offset + M;
    else
        % EL mode
        A = cmp_out(1:2:end);
        B = cmp_out(2:2:end);
        
        cmp_out(1:M/2) = A;
        s = zeros(M/2, 1);
        if (strcmp(type, 'MAX') || strcmp(type, 'ABS_MAX'))
            winindex = (B > A);
        else
            winindex = (B < A);
        end
        cmp_out(winindex) = B(winindex);
        s(winindex) = 1;
        
        if el_start_bit
            elem_ind_reg = bitor(elem_ind_reg, s);
            el_start_bit = 0;
        else
            elem_ind_reg(1:M/4) = elem_ind_reg(1:2:M/2).*(s(1:M/4)==0) + elem_ind_reg(2:2:M/2).*(s(1:M/4)==1);
        end
        
        Ne = Ne/2;
    end
end

%% calculate final index
index = pg_ind_reg(elem_ind_reg(1)+1)*M + elem_ind_reg(1) + 1;
value = x(index);

return;

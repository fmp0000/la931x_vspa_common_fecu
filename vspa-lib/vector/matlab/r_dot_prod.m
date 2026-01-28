% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright inp2: - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [dot_prod_v, dot_prod_m] = r_dot_prod(inp1, inp2, ctrl)
% 
% DESCRIPTION:
%   Performs dot product between two input complex buffers ('inp1' and 'inp2') 
%   in both Matlab and VSPA precision. The array 'inp1' is conjugated in
%   the dot product.
%
% INPUTS:
%   inp1: Nx1 complex input vector in Matlab double precision; conversion to 
%         VSPA precision is performed inside this function.
% 
%   inp2: Nx1 complex input vector in Matlab double precision; conversion to 
%         VSPA precision is performed inside this function.
%
%   ctrl: control structure with the following fields:
%             - inp1_prec - 1st input precision for VSPA implementation
%             - inp2_prec - 2nd input precision for VSPA implementation
%             - out_prec  - output precision for VSPA implementation
%
% NOTE: The inputs/output precision is one of the following:
%             - 'half_fixed': 16 bit fixed point
%             - 'half'      : 16 bit floating point
%             - 'single'    : 32 bit floating point
%             - 'double'    : 64 bit floating point
%
% OUTPUTS:
%   dot_prod_v: 1x1 complex dot product in VSPA precision
% 
%   dot_prod_m: 1x1 complex dot product in Matlab double precision
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dot_prod_v, dot_prod_m] = r_dot_prod(inp1, inp2, ctrl)

% Input validation
if length(inp1) ~= length(inp2)
    error('The 2 input buffers are not the same length!');
end

% If columns make rows
inp1 = inp1(:).';
inp2 = inp2(:).';

% -------------------------- Matlab implementation ------------------------
% Compute
dot_prod_m = sum(conj(inp1) .* inp2);

% --------------------------- VSPA implementation -------------------------
% VSPA # AU
VSPA_NUM_AU = 16;

% Convert input1 precision
inp1_v = r_convert(inp1, ctrl.inp1_prec, 'input1 buffer');

% Convert input2 precision
inp2_v = r_convert(inp2, ctrl.inp2_prec, 'input2 buffer');

% Padd input with zeros for multiple of VSPA_NUM_AU samples
inp_len  = length(inp1_v);
num_zero = ceil(inp_len / VSPA_NUM_AU) * VSPA_NUM_AU - inp_len;
inp1_v = [inp1_v, zeros(1, num_zero)];
inp2_v = [inp2_v, zeros(1, num_zero)];

% Sum block-wise the conjugate multiplication in blocks of VSPA_NUM_AU samples
V = zeros(1, VSPA_NUM_AU);

for block_start_idx = 0 : VSPA_NUM_AU : (length(inp1_v) - 1)

    % Block index
    idx = block_start_idx + (1 : VSPA_NUM_AU);
    
    % S0mode = 'S0conj', 'S0hlinecplx'
    S0 = conj(inp1_v(idx));
    
    % S1mode = 'S1hlinecplx'
    S1 = inp2_v(idx);     
    
    % Perform complex cmac
    V = r_smac(S0, S1, V);

end

% Sum element-wise
for idx = 2 : VSPA_NUM_AU
    
    S0 = V(idx);
    S1 = r_single(1);
    
    V(1) = r_smac(S0, S1, V(1));
end

% Convert output precision
dot_prod_v = r_convert(V(1), ctrl.out_prec, 'output');

% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [out_v, out_m] = r_mat_bmult(vec, mat, ctrl)
% 
% DESCRIPTION:
%   Performs batch multiplication between: 
%   - a batch "vec" of D1 vectors (each of size 1 x D2)
%   - a batch "mat" of D1 matrices (each of size D3 x D2)
%   resulting in a batch "out" of D1 vectors (each of size 1 x D3). 
%   The in-out relation is (^T denotes the transpose operator):
%
%            out(k,:)^T = mat(k,:,:) * vec(k,:)^T     k = 1 ... D1
%
% INPUTS:
%   vec   - D1 x D2 complex input batch of vectors in Matlab double precision 
%         - conversion to VSPA precision is performed inside this function
%         - this matrix should be interpreted as a batch of D1 row vectors,
%           each row vector of size 1 x D2 will be multiplied with a different matrix
% 
%   mat   - D1 x D3 x D2 complex input batch of matrices in Matlab double precision 
%         - conversion to VSPA precision is performed inside this function.
%         - this structure should be interpreted as a batch of D1 matrices,
%           each of dimension D3 x D2 which will be multiplied with the
%           corresponding vector of length D2 from "vec"
%
%   ctrl - control structure with the following fields:
%             - vec_prec   - input vector precision for VSPA implementation
%             - mat_prec   - input matrix precision for VSPA implementation
%             - out_prec   - output precision for VSPA implementation
%             - mat_interp - (optional) matrix interpolation along first dimension (D1)
%                          - (default) if not explicitly given, assumed 1                
%        - the allowed precisions are:
%             - 'half_fixed': 16 bit fixed point
%             - 'half'      : 16 bit floating point
%             - 'single'    : 32 bit floating point
%             - 'double'    : 64 bit floating point
%
% OUTPUTS:
%   out_v - D1 x D3 complex output batch of vectors in VSPA precision 
%         - this matrix should be interpreted as a batch of D1 row vectors,
%           each row vector of size 1 x D3 is the result of one multiplication
% 
%   out_m - D1 x D3 complex output batch of vectors in Matlab double precision 
%         - this matrix should be interpreted as a batch of D1 row vectors,
%           each row vector of size 1 x D3 is the result of one multiplication
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out_v, out_m] = r_mat_bmult(vec, mat, ctrl)

% Input sizes
[vec_dim1, vec_dim2]           = size(vec);
[mat_dim1, mat_dim3, mat_dim2] = size(mat);

% Matrix interpolation factor
if ~isfield(ctrl, 'mat_interp') || isempty(ctrl.mat_interp)
    mat_interp = 1;
else
    mat_interp = ctrl.mat_interp;
end

% Interpolate matrix along first dimension
mat = repmat(mat, [mat_interp, 1, 1]);
mat_interp_idx = repmat(1 : mat_dim1, mat_interp, 1) + mat_dim1 .* repmat((0 : (mat_interp - 1)).', [1, mat_dim1]);
mat_interp_idx = mat_interp_idx(:);
mat = mat(mat_interp_idx, :, :);
mat_dim1 = mat_dim1 * mat_interp;

% Size validation
if (vec_dim1 ~= mat_dim1) || (vec_dim2 ~= mat_dim2)
    error('Dimension mismatch between vector and matrix !');
end
    
% Dimension values
dim1 = vec_dim1;
dim2 = vec_dim2;
dim3 = mat_dim3;

% -------------------------- Matlab implementation ------------------------
% Initialize output
out_m = zeros(dim1, dim3);

% Batch multiplication
for idx = 1 : dim1
    v = vec(idx, :);
    m = reshape(mat(idx,:,:), dim3, dim2);    % Remove 1st singleton dimension
    out_m(idx, :) = (m * v.').';
end

% --------------------------- VSPA implementation -------------------------
% Convert vector and matrix precision
vec_v = r_convert(vec(:), ctrl.vec_prec, 'input vector');
vec_v = reshape(vec_v, size(vec));

mat_v = r_convert(mat(:), ctrl.mat_prec, 'input matrix');
mat_v = reshape(mat_v, size(mat));

% Initialize output
out_v = zeros(dim1, dim3);

for out_idx = 1 : dim3
    for inp_idx = 1 : dim2
        
        S0 = vec_v(:, inp_idx);
        S1 = mat_v(:, out_idx, inp_idx);
        V  = out_v(:, out_idx);
        
        out_v(:, out_idx) = r_smad(S0, S1, V);
    end
end

% Convert output precision
out_v = r_convert(out_v, ctrl.out_prec, 'output vector');
